---
name: snowflake-sql
description: >-
  Master-level Snowflake SQL development for the NBA Fan Data Platform (FDP).
  Use WHEN writing Snowflake queries, CTEs, views, stored procedures, or DDL for any FDP table.
  Use WHEN you need FDP architecture, fan identity definitions, schema reference, PII rules,
  data dictionary, acronyms, or source system names — including when writing Jira tickets.
  Covers FDP SQL style conventions, fan identity (fan_id/fan_interaction_id/NKEY/CIAM),
  medallion architecture, environment/schema reference, PII architecture, audit columns,
  CI/CD file conventions, warehouse sizing, metadata standards, and query optimization.
  Triggers: fan_id, fan_interaction_id, NKEY, CIAM, FDP, Bronze, _STG, DWH, PRIVATE,
  GDR, DDI, LDI, Amplitude, Braze, Evergent, Kochava, Appsflyer, Hightouch, Snowpipe,
  dwh_, _stg, _stgpii, _config, _audit, medallion, ingest, egress, unification, row_hash,
  subscription, identity, PII, marketable, fan_classification, source_destination_fdl.
---

# Snowflake SQL — NBA Fan Data Platform

## FDP Architecture

Centralized Snowflake warehouse: 60+ sources, NBA + WNBA.

**Medallion flow:** `External → Bronze (raw, append-only) → _STG (transform views) → DWH (business-ready) → Mart (rollups/activation)`

### Environments

| Env | Database | Role | Warehouse |
|-----|----------|------|-----------|
| DEV | `DB_FANDATA_DEV` | `FR_DATAENGINEER_DEV` | `VWH_DE_DEV` |
| QA | `DB_FANDATA_QA` | `FR_DATAENGINEER_QA` | `VWH_DE_QA` |
| PRD | `DB_FANDATA_PRD` | `FR_DATAENGINEER_PRD` | `VWH_DE_ETL_PRD` |

**Jeff's current session role:** `FR_ANALYST` on `DB_FANDATA_DEV` / `VWH_DSA_DEV`

Other databases: `DB_WNBA_FANDATA_*`, `DB_FIVETRAN_PII`, `DB_SHARED_BRAZEDATALAKE`, `DB_SHARED_APPSFLYER_W`, `DB_RAW_PRD`, `DB_FANDATA_GOLD_PRD`, `DB_AI_SEMANTICS`, `DB_FANANALYTICS`

### Schemas

| Schema | Layer | Purpose |
|--------|-------|---------|
| `BRONZE` | Raw | Append-only ingestion. One table per feed. Never modify. |
| `_STG` | Staging | Transformation views (Bronze → DWH). Calculates ROW_HASH. Contains changelog comments. |
| `_STGPII` | Staging (PII) | PII staging — elevated role required. |
| `DWH_*` | Business-ready | Domain-specific cleaned tables. Deduped, typed, merge-loaded. 39 schemas. |
| `PRIVATE` | PII | Fan-level PII. Requires PII-authorized role. **Never in Bronze or DWH.** |
| `BRONZE_PRIVATE` | Raw PII | Raw PII ingestion. |
| `MART` | Activation | Aggregations, dimensions, fulfillment for marketing platforms. |
| `_DS_HIGHTOUCH` | Egress | Dynamic tables for Hightouch activation syncs. |
| `_CONFIG` | ETL Config | Source-destination mappings, load procedures, feed configs. |
| `_AUDIT` | ETL Control | Load tracking, last successful dates, execution logs. |
| `_ARCHIVE` | Deprecated | Retired tables/feeds kept for reference. |
| `_DSAR` | Privacy | GDPR/CCPA processing. |
| `SBX` | Sandbox | Ad-hoc/exploration. |

Key DWH schemas: `DWH_FAN_ID`, `DWH_IDENTITY`, `DWH_FAVORITES`, `DWH_TICKET`, `DWH_SOCIAL_DATA`, `DWH_FEATURE_STORE`, `DWH_MEMBERSHIP`, `DWH_SUBSCRIPTION`, `DWH_AMPLITUDE`, `DWH_APPSFLYER`, `DWH_KOCHAVA`, `DWH_ATTRIBUTION`, `DWH_KORE`, `DWH_LDI`, `DWH_MODELS`, `DWH_UNIFIED`, `DWH_CONSENT`

---

## Fan Identity Reference

### Core Identifiers

| Identifier | Type | Definition |
|---|---|---|
| `fan_id` | NUMBER | Unified master identity. One fan_id = one real person. Always > 0. Maps to many fan_interaction_ids. |
| `fan_interaction_id` | VARCHAR | Per-partner prefixed string. One per email/device/account from each feed. Format: `{PREFIX}_{value}`. |
| `nba_ciam_guid` | VARCHAR | Canonical identity anchor (Ping Identity / NBA ID). Highest-weight ID in resolution. |
| `NKEY` / `*_NKEY` | VARCHAR | Natural Key — unique business identifier for dedup and merge. Every DWH table has one. |
| `id_type` | VARCHAR | Type of identifier (EMAIL, DEVICE_ID, CIAM_GUID, AMPLITUDE_ID, BRAZE_ID). |
| `id_value` | VARCHAR | Actual value for the id_type. |
| `fan_category` | VARCHAR | KNOWN (has PII), UNKNOWN (device-only), HOUSEHOLD (household record). |

### Identity Resolution Weights

| ID Type | Weight |
|---|---|
| CIAM GUID | 10 |
| Email | 7 |
| Partner IDs | 3 |
| Device IDs | 1 |

**Flow:** `Source IDs → PRIVATE.FAN_INTERACTION_ID_HISTORY → Weighted matching → fan_id`

**Outputs:** `PRIVATE.UNIFIED_FAN_IDS`, `DWH_FAN_ID.UNIFIED_FAN_IDS_XREF`, `_CONFIG.UNIFICATION_CONFIG`

### fan_interaction_id Prefixes (top by volume)

`BRZ` Braze | `AMPL` Amplitude | `KCVA` Kochava | `CIAM` NBA ID | `WVSP` WNBA Vesper | `EVG` Evergent | `HTMD` Hightouch | `TRN` Turner | `N2K` NBA 2K | `WBRZ` WNBA Braze | `AAMPE` Aampe | `WKCVA` WNBA Kochava | `WAPFR` WNBA Appsflyer | `FNDL` FanDuel | `NIKE` Nike | `BTMV` Bitmovio | `KORET` Kore | `MDK` Medallia | `LDI` League Data | `OCT` Octane | `ASV` All-Star Voting | `MNTR` Monterosa

---

## FDP SQL Style Guide

### Core Rules

- **Lowercase** all keywords and identifiers
- **4-space** indent
- **snake_case** everywhere
- **Trailing commas**
- **`as`** on all aliases
- **`inner`** always explicit on joins
- **CTEs over subqueries** (use meaningful names)
- **Multiline comments only** (`/* */`) — never `--`
- **Qualify columns** with alias when joining
- `DB_FANDATA_*` tables: `schema.table` (db context set by `use database`); external DBs: fully qualified `db.schema.table`

### CTE Pattern

```sql
with
cte_one as
(
    select ...
),
final as
(
    select
        fan.fan_id,
        nvl(cte_one.some_flag, 0)::boolean as some_flag,
        hash(some_flag) as row_hash
    from
        dwh_fan_id.attributes fan left join
        cte_one on fan.fan_id = cte_one.fan_id
    where
        fan.fan_id > 0
)
select * from final
qualify row_number() over (partition by fan_id order by row_hash asc) = 1;
```

### View Header Pattern

```sql
create or replace view schema_name.object_name
comment = 'Purpose of this view'
as
/*
Date            Author          Ticket#     Comments
--------------------------------------------------------------
2024-01-15      jcruz           IDE-1234    Initial Version
*/
select ...
```

Use `create or alter view` (not `create or replace`) for **existing prod views** — preserves grants.

### Key Patterns

| Pattern | Implementation |
|---|---|
| Booleans | `nvl(source.col, 0)::boolean as is_flag` |
| Dedup | `qualify row_number() over (partition by nkey order by activity_datetime_est desc) = 1` |
| Row hash | `hash(col1, col2, ...) as row_hash` |
| Timestamps | Always EST, `_est` suffix |
| WHERE connectors | `and`/`or` at end of preceding line |
| Multi-condition JOINs | Use parentheses |
| fan_id filter | Always `where fan.fan_id > 0` when querying `dwh_fan_id.attributes` |

### Standard Column Order

**NKEY → fan_interaction_id → business columns → activity_datetime_est → audit columns**

### Audit Columns (always last, always in this order)

```sql
etl_source_file_name    varchar,
etl_source_file_date    date,
feed_name               varchar,
row_hash                number,
etl_insert_datetime_est timestamp_ntz,
etl_update_datetime_est timestamp_ntz,
execution_id            number
```

### Gotchas

1. Column alias not referenceable in same SELECT — use subquery or CTE
2. Always `fan_id > 0` when querying `DWH_FAN_ID.ATTRIBUTES`
3. `nvl` before boolean cast — never cast a NULL directly
4. All timestamps EST with `_est` suffix
5. WNBA views need league/registration filters
6. History tables are append-only — always dedup in _STG
7. `create or alter` for existing prod views
8. Cross-DB joins need fully qualified names
9. ROW_HASH must include all business columns — adding columns requires hash recalc and full reload

---

## Metadata-First Standards

Every object written must have:

- **Table**: `comment = 'Purpose, domain, refresh cadence'`
- **Column**: inline `comment 'Meaning, source, transformation applied'`
- **View**: changelog comment block after `as` keyword
- **Stored proc**: header comment with parameters and purpose

```sql
/* GOOD: Metadata-first DDL */
create or replace table dwh_subscription.evergent_order
(
    evergent_order_nkey     varchar(1000)   comment 'Natural key: hash of order_id + fan_interaction_id',
    fan_interaction_id      varchar(1000)   comment 'FDP fan interaction ID (EVG_ prefix)',
    subscription_status     varchar(255)    comment 'SUBSCRIPTION_ACTIVE, INACTIVE, LAPSED, IN_TRIAL_PERIOD, TRIAL_CANCEL, SUBSCRIPTION_CANCEL, GRACE_TRIAL, GRACE_SUB, PAUSED',
    activity_datetime_est   timestamp_ntz   comment 'Event timestamp converted to EST',
    etl_insert_datetime_est timestamp_ntz   comment 'Row first inserted by ETL'
)
comment = 'League Pass subscription orders from Evergent. One row per order. Merge-loaded nightly.';
```

---

## PII Architecture

**Rule: PII NEVER in Bronze or DWH — PRIVATE schema only.**

**Allowed in DWH:** city, state, country, device_type, platform, language, currency

**PRIVATE only (never surface outside PRIVATE):** email, phone, name, DOB, address, IP address

**Flow:** `Source → _STGPII → FAN_PII_INGEST → PRIVATE`

**PRIVATE tables:**
- Bronze: `FAN_INTERACTION_PROFILE_HISTORY`, `FAN_INTERACTION_ID_HISTORY`
- Silver: `FAN_INTERACTION_EMAIL`, `_PHONE`, `_ADDRESS`, `_DEVICE`, `_IP_ADDRESS`, `_ZIP_CODE`
- Unified: `UNIFIED_FAN_PII`, `UNIFIED_FAN_ID_EMAIL/PHONE/ADDRESS/NAME/DEVICE`
- Enrichment: `INFUTOR_DATA`, `TRANSUNION_*`

**Join pattern when PII is needed:**
```sql
from dwh_fan_id.attributes fan
inner join private.unified_fan_id_email pii
    on fan.fan_id = pii.fan_id
where
    fan.fan_id > 0
```

---

## Data Dictionary

### Acronyms & Terms

| Acronym | Full Name | Definition |
|---|---|---|
| **FDP** | Fan Data Platform | NBA's unified fan data infrastructure (Bronze → DWH → Gold). |
| **GDR** | Growth, Development, Retention | Fan classification model: Avid, Casual, Light, Non-Fan, Lapsed. |
| **DDI** | Direct Digital Interaction | First-party digital touchpoint (app login, web session, etc.). |
| **LDI** | Local Data Integration | Fan KPIs packaged and sent to individual teams for their CRM/activation. |
| **CIAM** | Customer Identity & Access Management | NBA ID system (PingIdentity). Fan registration, login, profiles. |
| **XREF** | Cross-Reference | Table bridging fan_id ↔ fan_interaction_id. The "rosetta stone" of the FDP. |
| **NKEY** | Natural Key | Unique business identifier for dedup and merge logic. Every DWH table has one. |
| **ASV** | All-Star Voting | All-Star ballot voting data. |
| **STM** | Season Ticket Member | A fan holding season tickets. |
| **DMA** | Designated Market Area | Geographic region for team territory assignment. |
| **LP** | League Pass | NBA's streaming subscription product. |
| **PII** | Personally Identifiable Information | Email, name, address, phone — PRIVATE schema only. |
| **ISM** | In-Season Mode | Fantasy basketball in-season game mode. |
| **FTC** | Fan-to-Customer | Model predicting fan conversion to paid customer. |
| **TM** | Ticketmaster | Ticketing platform (Archtics = B2B, Classic = legacy). |
| **KORE** | KORE Software | Team CRM/partnership platform. |
| **FFV** | Fan Future Value | Forward-looking lifetime value model. |
| **FEV** | Fan Engagement Value | Engagement-weighted fan value score. |

### fan_classification_value (GDR outputs)

`Avid` | `Casual` | `Light` | `Non-Fan` | `Lapsed`

### Source Systems (feed_name values)

| feed_name | Source System | Data Type |
|---|---|---|
| IDENTITY | CIAM / PingIdentity | Fan registration, profile, NBA ID |
| EVERGENT | Evergent | League Pass subscriptions, orders |
| AMAZON_LP | Amazon | Amazon-distributed League Pass |
| AMPLITUDE | Amplitude | App/web event analytics |
| APPSFLYER | AppsFlyer | Mobile attribution, installs |
| FANATICS_DOMESTIC | Fanatics (US) | Merchandise orders, customers |
| FANATICS_INTERNATIONAL | Fanatics (Intl) | International merchandise |
| SEATGEEK | SeatGeek | Ticketing (sales, attendance) |
| TM_ARCHTICS | Ticketmaster Archtics | Primary ticket sales, accounts |
| TM_CLASSIC | Ticketmaster Classic | Legacy ticketing |
| BRAZE | Braze | Email/push messaging engagement |
| CROWDTWIST | CrowdTwist | Loyalty program (NBA Rewards) |
| MONTEROSA | Monterosa | Interactive fan experiences, trivia |
| GAM | Google Ad Manager | Digital advertising impressions/clicks |
| YAHOO_FANTASY | Yahoo | Fantasy basketball |
| TRANSUNION | TransUnion | Third-party identity enrichment |
| KOCHAVA | Kochava | Mobile attribution |
| HIGHTOUCH | Hightouch | Reverse ETL / activation sync |

---

## Key Table Schemas

### DWH_FAN_ID.ATTRIBUTES
Fan-level demographics, geography, preferences, consent. PK: `fan_id`. **Always filter `fan_id > 0`.**

Key columns: `fan_id`, `nba_ciam_guid`, `fan_category` (KNOWN/UNKNOWN/HOUSEHOLD), `fan_classification_value` (GDR), `state`, `country`, `zip_code`, `email_domain`, `favorite_nba_team`, `favorite_wnba_team`, `email_consent_status`, `profile_status` (LITEREG/FULLREG), `first_activity_datetime_est`, `last_activity_datetime_est`

### DWH_FAN_ID.UNIFIED_FAN_IDS_XREF
Bridge table: fan_id ↔ fan_interaction_id. The "rosetta stone." PK: `fan_interaction_id`.

Columns: `fan_interaction_id`, `fan_id`, `row_hash`, `etl_insert_datetime_est`, `etl_update_datetime_est`, `execution_id`

### DWH_FAN_ID.INTERACTION_FLAGS
Boolean flags per fan_id. Key flags: `is_marketable_audience`, `is_emailable_segment`, `is_nbaid`, `is_wnba_fan`, `is_wnba_only`, `is_test_user`, `is_bot_user`, `is_do_not_sell`, `has_first_party_interaction`, `has_app`, `is_vip`, `is_fanduel`, `is_ticketing`, `is_merchandise`, `is_favorites`, `allow_notifications_flag`, `is_subscription_active_access`

### DWH_FAN_ID.MODELED_ATTRIBUTES
ML outputs per fan_id: `fan_classification_type`, `fan_classification_value`, `implicit_fav_team_abbr`, `lp_acquisition_propensity`, `next_best_action_array`, `stm_propensity_array`

### DWH_AMPLITUDE.AMPLITUDE_EVENTS_L30
Event-level data, last 30 days. ~5B rows. Clustered by `merged_event_name` + month.
Key columns: `fan_interaction_id`, `event_date_est`, `merged_event_name`, `event_type`, `platform`, `device_type`, `nba_digital_property`

### _CONFIG.SOURCE_DESTINATION_FDL
Bronze file ingest mapping. Key columns: `feed_source_name` (PK), `stage_name`, `source_location`, `file_type`, `is_full_incremental_flag` (i/f), `feed_name`, `fan_interaction_id`, `bronze_mapping`, `pii_mapping`, `id_mapping`, `is_private`, `is_dynamic_schema`

### _CONFIG.SOURCE_DESTINATION_DWH
Bronze → DWH transform config. 1,057 mappings. Maps staging views to DWH tables.

---

## Naming Conventions

| Pattern | Meaning |
|---|---|
| `*_nkey` | Natural key (unique business identifier) |
| `*_est` | Timestamp in Eastern Standard Time |
| `*_datetime_est` | Full timestamp EST |
| `*_date_est` | Date only EST |
| `ld_*_v` | Load view (staging view feeding a DWH table) |
| `*_history` | Append-only historical table |
| `*_latest` | Most recent record only |
| `*_bkp_*` | Backup table (clone before schema changes) |
| `*_l1m / _l3m / _l6m` | Last 1/3/6 months metric |
| `*_ever` | Lifetime/all-time metric |
| `w_*` | WNBA-specific object |
| `*_tsk` | Snowflake task |
| `*_xref` | Cross-reference table |

### Data Type Conventions

| Value Type | Snowflake Type |
|---|---|
| fan_id | NUMBER |
| fan_interaction_id | VARCHAR |
| Hashes (row_hash, bronze_hash) | NUMBER |
| Datetimes | TIMESTAMP_NTZ (always EST) |
| Boolean flags | BOOLEAN |
| Source IDs (even if numeric) | VARCHAR |
| JSON/nested | VARIANT or OBJECT |
| Arrays | ARRAY |

---

## ETL Orchestration

```sql
/* Schedule a multi-step job */
call _config.mst_config_job_scheduler(
    'dwh_partner_entity',
    '_config.mst_fdl_load([bronze_feed_source_name])|_config.mst_dwh_load([dwh_schema_table])'
);
```

Steps separated by `|` run sequentially.

Key procedures:
- `mst_fdl_load` — file → Bronze
- `mst_dwh_load` — _STG view → DWH table
- `mst_config_job_scheduler` — task creation/scheduling

---

## CI/CD Conventions

**Branch → Environment:**
- `main` → QA (requires principal approval)
- `release` → PRD (requires team head approval)

**Snowflake SQL file path:**
```
src/snowflake/db_fandata_dev_int/{schema}/{object_type}/{FILENAME}.sql
```

**Config file path:**
```
src/snowflake/db_fandata_dev_int/_config/config_files/{config_table_name}/{feed_source_name}.json
```

**Rules:**
- SQL filenames **UPPERCASE** (e.g., `DWH_EVERGENT_ORDER.sql`)
- Config filenames **lowercase** (e.g., `evergent_order.json`)
- Remove DB name from DDL — use `schema.table`, not `db.schema.table`
- Warehouse in DDL must match environment (DEV/QA/PRD)
- Never move files between `infra/` and `src/snowflake/` in the same PR
- Use `create or alter view` for existing prod views (preserves grants)
- Validate DDL with `_config.get_object_ddl` before PR

---

## General Snowflake Patterns

### Query Optimization
```sql
/* QUALIFY for dedup — more efficient than subquery */
select
    fan_id,
    event_type,
    activity_datetime_est
from dwh_amplitude.amplitude_events_l30
where event_date_est >= dateadd(day, -30, current_date())
qualify row_number() over (partition by fan_id order by activity_datetime_est desc) = 1;
```

### Security Patterns
```sql
/* Dynamic data masking for PII */
create masking policy email_mask as (val string) returns string ->
    case
        when current_role() in ('FR_PII_READER', 'FR_ADMIN') then val
        else regexp_replace(val, '.+@', '****@')
    end;

alter table private.unified_fan_id_email modify column email_address set masking policy email_mask;
```

---

## Warehouse Sizing

| Size | Use Case | When to Use |
|---|---|---|
| X-Small | Dev/testing, ad-hoc exploration | Default for Jeff's FR_ANALYST work (`VWH_DSA_DEV`) |
| Small | Production ETL (<100GB) | Nightly loads, small feeds |
| Medium | Production ETL (100GB–1TB) | Fan data aggregations, medium complexity |
| Large | Complex transformations (1TB+) | Historical backfills, ML feature engineering |

**Auto-suspend:** 60s for ETL warehouses, 300s for analyst/reporting warehouses.

---

## Validation Checklist

After writing any FDP SQL:

- [ ] All tables/views have `comment` clauses
- [ ] All columns have `comment` annotations
- [ ] Column order: NKEY → fan_interaction_id → business cols → activity_datetime_est → audit cols
- [ ] Audit columns present and in standard order
- [ ] ROW_HASH includes all business columns
- [ ] `fan_id > 0` filter on any `dwh_fan_id.attributes` join
- [ ] Timestamps use `_est` suffix and are TIMESTAMP_NTZ
- [ ] Booleans use `nvl(..., 0)::boolean` pattern
- [ ] No `--` comments — multiline `/* */` only
- [ ] Dedup uses `qualify row_number() over (partition by nkey ...)` pattern
- [ ] Prod view changes use `create or alter view` (not `create or replace`)
- [ ] SQL filename UPPERCASE, config filename lowercase
- [ ] No DB references in DDL (use `schema.table` only)
- [ ] PII never in Bronze or DWH — PRIVATE only

## Related Skills

- `fdvs-personal:ticket-builder` — Creates Jira tickets for Fan Data Value Stream work
- `nba-standard:jira` — Jira ticket management via Atlassian MCP
- `nba-standard:security-review` — Security audit patterns (complements RBAC/masking)
