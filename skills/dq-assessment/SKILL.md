---
name: dq-assessment
description: >-
  Full data quality assessment for NBA FDP Snowflake tables. Use WHEN asked
  to QA, assess, audit, or validate a table. Runs a standardized test battery
  using claude-opus-4-5 for queries and Sonnet for the written report. Covers PK
  integrity, temporal logic, fill rates, ETL audit columns, row_hash collisions,
  value set anomalies, and FDP-specific gotchas (epoch-zero dates, fan_id > 0,
  UNKNOWN category, sentinel values). Produces a prioritized P1/P2/P3 findings
  report with row counts, business impact, and recommended actions.
  Triggers: QA, data quality, assess, audit, validate, anomalies, DQ, UAT,
  inconsistencies, weird data, what's wrong with this table.
---

# DQ Assessment — NBA Fan Data Platform

## Core Behavior

**Model switching (mandatory):**
- Use **claude-opus-4-5** to execute all Snowflake queries via `snow sql --connection NBA-DATA`
- Use **Sonnet** to write the findings report

**Scope:** Find inconsistencies and weird anomalies. Do NOT focus on fill rates for first-party data tables (ATTRIBUTES, DWH_* tables) — fill rates are expected to be low and are not findings unless combined with logical inconsistencies.

---

## Standard Test Battery

Run all applicable tests. Skip tests that don't apply to the table's grain or schema (e.g., skip temporal tests on lookup/reference tables). Label each test result clearly.

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

## Report Format

Write the report in Sonnet. Structure:

```
# Data Quality Assessment — `<SCHEMA>.<TABLE_NAME>`
**Date:** | **Environment:** | **Total rows:**

## Executive Summary
2–4 sentence overview of the most important findings.

## TEST N — [Test Name] [✅ CLEAN | ⚠️ ANOMALY | ❌ CRITICAL FINDING]
| Metric | Value |
Results table + 1–3 sentence interpretation.

...

## Prioritized Issue List
| Priority | Issue | Rows Affected | Action |
| 🔴 P1 | ... | ... | ... |
| 🟡 P2 | ... | ... | ... |
| 🟢 P3 | ... | ... | ... |
```

**Priority definitions:**
- 🔴 **P1** — Data integrity failure, privacy/compliance risk, or finding that actively corrupts downstream models/reports. Needs immediate action.
- 🟡 **P2** — Meaningful anomaly that affects analytical correctness or trust. Should be addressed in near term.
- 🟢 **P3** — Minor inconsistency, naming issue, or low-volume edge case. Document and address when convenient.

---

## Execution Notes

- Always run `fan_id > 0` filters when analyzing real fans — invalid IDs are expected at scale
- Use `APPROX_COUNT_DISTINCT` for COUNT DISTINCT queries on tables > 1B rows to avoid timeouts
- For tables with >500M rows, consider sampling CTEs before running distribution queries
- Always check `information_schema.columns` first to confirm column names before building the test queries
- The `--enable-templating NONE` flag is required when executing SQL files with COMMENT clauses via `snow sql`
