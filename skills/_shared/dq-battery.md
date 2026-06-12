# Shared DQ Battery — FDP Snowflake Tables

> **Single source of truth.** This file holds the standardized data-quality test battery,
> the FDP-specific gotchas, and the execution contract shared by `dq-assessment`
> (exploratory mode) and `uat-validator` (ticket-anchored mode). Edit the battery here once;
> both skills inherit it. Do not duplicate these tests into the individual SKILL.md files.

---

## Execution contract (read first)

A DQ review is not "one LLM + one executor." It runs across **three layers** — and only the
last one is genuinely LLM-free:

| Layer | What it is | Owns |
|---|---|---|
| **Claude Code session** | the skill orchestrator | planning, interpretation, prioritization, narration |
| **CoCo (Cortex Code)** | a *second* LLM-backed agent (runs Claude **or** OpenAI models) | SQL generation + orchestrating the warehouse |
| **Snowflake warehouse** | the query engine | deterministic SQL execution — **no LLM** |

**Claude plans and interprets. CoCo generates & runs the SQL. The warehouse executes it.
Claude never runs SQL directly.**

- **Planning (Claude):** decide which tests apply to the table's grain/schema, choose categorical
  columns and numeric bounds, and — for ticket-anchored UAT — convert acceptance criteria into
  SQL-testable assertions.
- **SQL generation + execution (CoCo → warehouse):** every SQL statement — including column
  introspection via `information_schema` — is handed to CoCo, which writes the SQL and has the
  Snowflake warehouse run it. Do **not** use `snow sql`, SnowSQL, or any direct connection from Claude.
- **Interpretation + narration (Claude):** read CoCo's returned results, separate real findings
  from expected FDP gotchas, assign P1/P2/P3, and write the report.

This mirrors the repo's two-engine model (see `README.md`): *"The `snowflake-sql` skill routes SQL
tasks to Cortex — Claude does not execute SQL directly."*

**Why this is safe on production data:** CoCo runs inside Snowflake's governance perimeter — data
never leaves Snowflake, models are not trained on it, and your RBAC role is enforced. That is what
makes it acceptable to point this battery at prod tables.

---

## Model routing (capability tiers — never hardcoded ids)

Match the model to the task's *nature*, not a fixed id. **Route by capability tier**; the specific
model behind each tier changes over time (the old skill hardcoded `claude-opus-4-5` and went stale —
do not repeat that).

| DQ task | Nature | Tier | Where it runs |
|---|---|---|---|
| Skill routing (which DQ skill) | classification | **cheap** | harness / triggers |
| Battery planning (which tests fit the schema) | template-matching | **mid** | Claude session |
| Ticket → SQL-testable assertion (UAT) | reasoning / business judgment | **frontier** | Claude session |
| SQL generation | code synthesis | CoCo's choice (`auto`) | CoCo |
| **SQL execution** | deterministic | **no LLM** | warehouse |
| Result interpretation + P1/P2/P3 prioritization | judgment | **frontier** | Claude session |
| Report formatting | templating | **cheap** | Claude session |

**Principles:**
1. **Execution is never an LLM task.** The warehouse runs SQL; an LLM must not "compute" results.
2. **Spend frontier-tier tokens only on judgment** — ticket→assertion and anomaly prioritization.
   A wrong call there silently invalidates the whole review; that is where quality must not drop.
3. **Everything mechanical goes to the cheap tier** — routing, formatting.
4. **Never hardcode a model id in a skill.** Tiers are stable; ids drift.

**CoCo model selection.** CoCo defaults to `auto` (highest-quality model available to the account;
currently a frontier Claude model). It can run Claude *or* OpenAI models and accepts a per-invocation
override (`cortex -m <model>`, or `/model` mid-session). Leave it on `auto` for DQ work unless a
specific run needs a cheaper/faster model — in which case override at call time, never in the skill text.

**Today (single-session mode).** In practice the skill runs on the Claude Code session's model and
delegates SQL to CoCo. Because interpretation/prioritization (frontier tier) is the binding
constraint, run on the session's frontier model and don't downgrade — planning and formatting on the
same model is marginal cost since the heavy SQL work is already offloaded to CoCo.

**Config, not hardcoded values.** Read `role` and `connection` from `config.yaml`
(`snowflake.role`, `snowflake.connection`). Never hardcode a connection name or a model id.

---

## Standard Test Battery

Run all applicable tests. Skip tests that don't apply to the table's grain or schema (e.g., skip
temporal tests on lookup/reference tables). Label each test result clearly.

### TEST 1 — PK Integrity
```sql
select
    count(*)                                    as total_rows,
    count(distinct <pk_column>)                 as distinct_pks,
    count(*) - count(distinct <pk_column>)      as duplicate_pks,
    count(case when <pk_column> is null then 1 end) as null_pks,
    /* for fan tables: */
    count(case when fan_id <= 0 then 1 end)     as invalid_fan_ids
from <table>;
```

### TEST 2 — Temporal Ordering
For tables with multiple date columns, check logical order:
```sql
select
    count(case when first_activity > last_activity then 1 end)              as first_after_last,
    count(case when created_datetime > last_activity then 1 end)            as created_after_activity,
    count(case when last_activity < first_datetime_in_fdp_est then 1 end)   as activity_predates_fdp_entry,
    count(case when first_activity < '2000-01-01' then 1 end)               as pre_2000_activity,
    count(case when last_activity > current_date() then 1 end)              as future_activity
from <table>
where fan_id > 0;
```

### TEST 3 — Sentinel / Epoch-Zero Dates
```sql
select
    count(case when year(<date_col>) = 1900 then 1 end)     as epoch_zero_1900,
    count(case when year(<date_col>) = 1899 then 1 end)     as epoch_zero_1899,
    count(case when year(<date_col>) > 2050 then 1 end)     as far_future,
    count(case when year(<date_col>) > 2028 then 1 end)     as beyond_2yr_horizon,
    min(<date_col>)                                          as earliest,
    max(<date_col>)                                          as latest
from <table>;
```

### TEST 4 — ETL Audit Columns
Always run on every table:
```sql
select
    count(case when insert_datetime_est > update_datetime_est then 1 end)   as insert_after_update,
    count(case when insert_datetime_est > current_timestamp() then 1 end)   as future_insert,
    count(case when update_datetime_est > current_timestamp() then 1 end)   as future_update,
    min(insert_datetime_est)        as earliest_insert,
    max(insert_datetime_est)        as latest_insert,
    max(update_datetime_est)        as latest_update,
    datediff('day', max(update_datetime_est), current_timestamp())          as days_since_last_update,
    count(distinct feed_name)       as distinct_feed_names,
    count(distinct execution_id)    as distinct_execution_ids
from <table>;
```

### TEST 5 — ROW_HASH Uniqueness (DWH tables)
```sql
select
    count(*)                            as total_rows,
    count(distinct row_hash)            as distinct_hashes,
    count(*) - count(distinct row_hash) as hash_collisions
from <table>
where fan_id > 0;
```

### TEST 6 — Categorical Value Sets
For any column with a documented value set (fan_category, profile_status, email_consent_status, gender, etc.):
```sql
select <category_col>, count(*) as cnt,
    round(count(*) * 100.0 / sum(count(*)) over (), 2) as pct
from <table>
group by 1
order by 2 desc;
```
Flag: undocumented values, dual values for the same semantic state (e.g., OPTED_IN vs SUBSCRIBED), NULL vs explicit UNKNOWN distinction.

### TEST 7 — Numeric Range Anomalies
For age, revenue, counts, or any bounded numeric column:
```sql
select
    min(<col>)   as min_val,
    max(<col>)   as max_val,
    avg(<col>)   as avg_val,
    count(case when <col> < 0 then 1 end)       as negative_count,
    count(case when <col> > <reasonable_max> then 1 end) as over_max_count
from <table>;
```
Flag: negative values where impossible, biologically impossible ages (>120), revenue values exceeding known product price caps.

### TEST 8 — Timestamp Corruption (millisecond → second conversion bug)
```sql
select
    count(case when year(<timestamp_col>) > 2100 then 1 end) as corrupted_timestamps,
    max(<timestamp_col>)                                       as max_timestamp
from <table>;
```
This catches the millisecond-to-second epoch conversion bug seen in FULFILLMENT_TABLE (years 2757, 2784) and FAN_INTERACTION_ID_EVENT_V (year 3009).

### TEST 9 — Foreign Key Referential Integrity
For tables with fan_id that should join to ATTRIBUTES:
```sql
select count(distinct t.fan_id) as orphaned_fan_ids
from <table> t
left join db_fandata_prd.dwh_fan_id.attributes a on t.fan_id = a.fan_id
where t.fan_id > 0
  and a.fan_id is null;
```

### TEST 10 — Deleted / Suppressed Fans Still Active
For tables that should respect CIAM deletion:
```sql
select count(distinct a.fan_id) as deleted_fans_still_present
from <table> t
join db_fandata_prd.dwh_fan_id.attributes a on t.fan_id = a.fan_id
where a.profile_status = 'DELETED'
  and t.fan_id > 0;
```

### TEST 11 — Bot / Test User Presence
```sql
select
    count(case when f.is_bot_user  = true then 1 end)  as bot_users,
    count(case when f.is_test_user = true then 1 end)  as test_users,
    count(case when f.is_bot_user = true or f.is_test_user = true then 1 end) as bot_or_test_total
from <table> t
left join db_fandata_prd.dwh_fan_id.interaction_flags f on t.fan_id = f.fan_id
where t.fan_id > 0;
```

### TEST 12 — Stale Source / Feed Gap
For event or interaction tables, check for unexplained time gaps in feed activity:
```sql
select
    feed_name,
    max(event_datetime_est)                                         as latest_event,
    datediff('day', max(event_datetime_est), current_date())        as days_stale
from <table>
group by 1
order by 2 desc;
```
Flag: any feed > 30 days stale without a known explanation.

---

## FDP-Specific Gotchas

Always check these regardless of the table:

| Gotcha | What to look for |
|---|---|
| `fan_id <= 0` | UNKNOWN/device-only fans stored with non-positive IDs. Always filter `fan_id > 0` for real-fan analysis |
| Epoch-zero dates | `1900-01-01` and `1899-12-31` are sentinel dates from NeuLion-era backfills, not real timestamps |
| Millisecond timestamps | Years > 2100 indicate a Unix millisecond epoch mistakenly divided by 1000 instead of 1000000 |
| OPIN/Brazil sentinel | `active_to_date = 2099-12-31` = open-ended auto-renewing subscription, not a real end date |
| UNKNOWN fan_category | 91% of ATTRIBUTES rows are UNKNOWN (device-only). Expected, not a bug |
| KNOWN_ANONYMOUS / UNKNOWN_KNOWN_SOURCE | Undocumented fan_category values — flag if found, investigate definition |
| EMAIL_DOMAIN column | In ATTRIBUTES, stores masked full address (`xxxxx@domain.com`), NOT just the domain |
| US fans have null COUNTRY | `country = 'UNITED STATES'` has zero rows — domestic fans carry null country |
| Bot/test flag coverage | `is_bot_user` and `is_test_user` in INTERACTION_FLAGS are severely under-populated — domain-based detection is more reliable |
| Row_hash collisions | Expected on UNKNOWN fans with sparse/null profiles — check only `fan_id > 0` rows |
| Infutor columns | Third-party demographic appends — not organic fan behavior. Not for modeling. |

---

## Execution Notes

- Always run `fan_id > 0` filters when analyzing real fans — invalid IDs are expected at scale
- Use `APPROX_COUNT_DISTINCT` for COUNT DISTINCT queries on tables > 1B rows to avoid timeouts
- For tables with >500M rows, consider sampling CTEs before running distribution queries
- Always check `information_schema.columns` first to confirm column names before building the test queries
- The `--enable-templating NONE` flag is required when executing SQL files with COMMENT clauses
- **CoCo has a ~120s per-invocation wall-clock limit.** On very large tables (multi-billion rows),
  a single call that bundles several full-scan aggregations will time out. Mitigate by: (a) running
  one test per CoCo call rather than batching, and/or (b) using `TABLESAMPLE`/`SAMPLE (n)` to
  estimate rates on a representative slice. Confirmed on `FAN_ID_EVENT` (~14.4B rows): a batched
  4-test full-scan call timed out at 120s; a single `SAMPLE (1)` call returned in-window.
- **Adapt the battery to the actual schema.** Skip or rewrite tests whose columns don't exist
  (e.g. `FAN_ID_EVENT` has `ETL_INSERT_DATETIME_EST` but no `ETL_UPDATE_DATETIME_EST`, and its feed
  column is `SOURCE_NAME`, not `FEED_NAME`). Confirm columns via `information_schema` before building queries.
