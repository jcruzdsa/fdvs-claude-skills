---
name: fev-pr-review
description: >-
  Structured PR review for FEV/FFV dbt model changes in the dbt_analytics repo.
  Use WHEN Jeff shares a PR link touching the FEV/FFV pipeline: metrics/fan_by_fiscal_year,
  intermediate/future_fan_value_dashboard, marts/future_fan_value_dashboard,
  staging/unified, or any model that references FFV_PROPENSITY, FFV_CLUSTERS,
  metrics_fev_by_fan_id, or metrics_by_fan_by_fiscal_year.
  Reads all changed files via Azure DevOps REST API, applies the FEV checklist,
  and produces a structured review with block/comment/approve recommendation.
  Triggers: PR, pull request, FFV, FEV, dbt, fan_by_fiscal_year, fev_by_fan_id,
  ffv_clusters, ffv_propensity, future_fan_value, touchpoints, agg_revenue,
  agg_cohort, agg_fan_profiles, Aryan, dbt_analytics, 52611.
---

# FEV/FFV PR Review — dbt_analytics

## How to Fetch PR Files

Use Azure DevOps REST API with a bearer token. The token must be refreshed each session:

```bash
TOKEN=$(az account get-access-token \
  --resource 499b84ac-1321-427f-aa17-267ca6975798 \
  --query accessToken -o tsv)
```

Fetch changed files list:
```bash
/opt/anaconda3/bin/curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/nbadev/DTC/_apis/git/repositories/dbt_analytics/pullRequests/<PR_ID>/iterations/<LATEST_ITER>/changes?api-version=7.1"
```

Fetch individual file content from the PR branch:
```bash
/opt/anaconda3/bin/curl -s -H "Authorization: Bearer $TOKEN" \
  "https://dev.azure.com/nbadev/DTC/_apis/git/repositories/dbt_analytics/items?path=<PATH>&versionDescriptor.version=<BRANCH>&versionDescriptor.versionType=branch&api-version=7.1"
```

**Note:** `curl` lives at `/opt/anaconda3/bin/curl`, not the system path.

---

## FEV Pipeline Map

Know this before reviewing any PR. Execution order:

```
1. Sources (_unified__sources.yml)
   └── DB_FANDATA_PRD._STG.FFV_PROPENSITY           (ML propensity scores)
   └── DB_FANDATA_PRD.DWH_FEATURE_STORE.FFV_CLUSTERS_20XX (fan clusters per FY)

2. Intermediate
   └── int_ffv_clusters_by_fan_by_fiscal_year
       - Unions FFV_CLUSTERS_2023/2024/2025/2026
       - Left joins FFV_PROPENSITY on fan_id + fiscal_year
       - Propensity filter: fiscal_year = max(fiscal_year) - 1
       - Grain: fan_id × fiscal_year

3. Metrics
   └── metrics_by_fan_by_fiscal_year
       - Jinja loop joins ~15 product aggregation models onto fan_id_spine
       - int_ffv_clusters joins in as alias 'ffv'
       - Grain: fan_id × fiscal_year

4. Gold (metrics_fev_by_fan_id → DB_FANDATA_GOLD_PRD.ANALYTICS_FANS)
   - Step 1-2: Get last 4 fiscal years dynamically via dbt_utils.get_column_values
   - Step 3: Jinja pivot → fy20XX_ prefixed columns for each metric
   - Step 4: fan_engagement_by_fan_id — pulls dim_fans profile + Infutor
   - Step 5: fan_interaction_flags_ever — lifetime flags + max(ffv_*) scores
   - Step 6: Final join of all three CTEs
   - Grain: fan_id (one row per fan, 4 years pivoted)

5. Mart (fct_us_all_data_touchpoints_by_fan_by_fiscal_year)
   - Filters: country_name = 'UNITED STATES', fiscal_year >= 2022
   - Adds: RSN, linear TV, indirect attribution (statistical estimation)
   - Grain: fan_id × fiscal_year, US only

6. Aggregations (3 mart models)
   - All filter: age_bin_2_year_intervals != '2--17', total_revenue < 11000
                 ffv_3yr_total is not null  ← SILENT population reduction
   - Discount formula: (ffv_1yr/1.08) + (ffv_2yr/1.66) + (ffv_3yr/1.26)
                       ⚠️ Year 2 divisor should be 1.1664, not 1.66
```

---

## Review Checklist

Work through every item. Mark ✅ PASS, ⚠️ WARN, or ❌ BLOCK.

### Layer 1 — Source Changes
- [ ] Are new `{{ source(...) }}` references pointing to `_PRD`, not sandbox/dev/QA databases?
- [ ] Is the source YAML description accurate and non-empty?
- [ ] If a source was renamed or moved, are all downstream `ref()` / `source()` calls updated?

### Layer 2 — Intermediate Model Changes
- [ ] Does `int_ffv_clusters` propensity join use `max(fiscal_year) - 1`? (Expected — but document if changed)
- [ ] Are all FFV_CLUSTERS years accounted for in the union? (Currently 2023–2026 hardcoded)
- [ ] If a new fiscal year cluster table was added, was the source declaration also added to `_unified__sources.yml`?
- [ ] Does the `fiscal_year || '-' || fan_id` uniqueness test still hold after changes?

### Layer 3 — Metrics Model Changes
- [ ] Is the FFV model still in the Jinja `models` list with alias `ffv`?
- [ ] Are FFV columns (`ffv_cluster`, `ffv_1yr`, `ffv_2yr`, `ffv_3yr`, `ffv_3yr_total`) still being passed through?
- [ ] Was any new model added to the Jinja loop? If so, does it have a matching join key (`fan_id + fiscal_year`)?

### Layer 4 — Gold Table Changes (`metrics_fev_by_fan_id`)
- [ ] Is `dbt_utils.get_column_values` still being used for dynamic fiscal year selection?
- [ ] Are FFV scores pulled with `max(ffv_*)` in `fan_interaction_flags_ever`? (Known limitation — takes max, not most recent)
- [ ] Are Infutor columns (`infutor_*`) being added or exposed? **Flag if yes** — these should not be used for modeling.
- [ ] Is `flag_is_bot_user` or `flag_is_test_user` exclusion present anywhere upstream? **Flag if not.**
- [ ] Does the model stamp `ffv_model_version` and `ffv_score_date`? (Currently missing — flag as P2 if not added)
- [ ] Are new columns documented in `_fan_by_fiscal_year_models.yml` with descriptions?

### Layer 5 — Mart / Touchpoints Changes
- [ ] Does `fct_us_all_data_touchpoints` still filter `country_name = 'UNITED STATES'`?
  - ⚠️ **Known issue:** US fans have null COUNTRY in ATTRIBUTES/dim_fans. Verify row count is nonzero.
  - Run: `select count(*) from fct_us_all_data_touchpoints_by_fan_by_fiscal_year limit 1`
- [ ] Is `fiscal_year >= 2022` still the lower bound? (Intentional — captures 4 full seasons)
- [ ] Were any indirect attribution models (RSN, linear TV, amplitude) changed? If so, check join keys.

### Layer 6 — Aggregation Changes
- [ ] Is the discount formula unchanged? `(ffv_1yr/1.08) + (ffv_2yr/1.66) + (ffv_3yr/1.26)`
  - ⚠️ **Known bug:** Year 2 divisor is `1.66` — should be `1.1664` at 8% annual discount. If PR fixes this, verify the correction: `1.08^2 = 1.1664`.
- [ ] Is `ffv_3yr_total is not null` filter still present in all three agg models? (This gate is intentional — fans without propensity scores are excluded from dashboards)
- [ ] Is `age_bin_2_year_intervals != '2--17'` still present? (Minor exclusion — intentional)
- [ ] Is `total_revenue < 11000` outlier cap still present?
- [ ] In `agg_cohort_comparison_by_productline`, is `ffv_cluster != 'NA'` still filtering the base CTE?

### Cross-Cutting Concerns
- [ ] **Bot/test population:** Is any `is_bot_user = false / is_test_user = false` filter present anywhere in the changed files? (~797K non-real fans currently flow through with no gate)
- [ ] **Metadata:** Do new or modified models have column descriptions in the accompanying `.yml`?
- [ ] **Hardcoded fiscal years:** If the PR hardcodes a new cluster year (e.g., `ffv_clusters_2027`), will this break when FY2028 arrives?
- [ ] **`SELECT *` in views:** No `SELECT *` in any view where per-column Snowflake COMMENTs are needed (comments don't propagate through `SELECT *`)

---

## Known Issues (Pre-Existing — Don't Block On These Unless PR Makes Them Worse)

| Issue | Location | Status |
|---|---|---|
| Year-2 discount divisor `1.66` should be `1.1664` | `agg_revenue_by_productline`, `agg_fan_profiles_4_year_ffv` | Pre-existing bug — flag if PR touches the formula |
| US fans have null COUNTRY — `country_name = 'UNITED STATES'` filter may return 0 rows | `fct_us_all_data_touchpoints` | Needs investigation |
| 797K non-real fans (bot/vendor/test) in gold table — no upstream filter | `metrics_by_fan_by_fiscal_year` | Pre-existing, no fix in current pipeline |
| FFV propensity `max(fiscal_year) - 1` means FY23/24 cluster fans get NULL scores | `int_ffv_clusters` | By design — but silent |
| `max(ffv_*)` in `fan_interaction_flags_ever` takes highest score, not most recent | `metrics_fev_by_fan_id` | Minor bug — only matters if fan appears in 2+ propensity years |
| FY2023 cluster joins in but `fy2023_ffv_cluster` is not exposed in gold table output | `metrics_fev_by_fan_id` | Inconsistency — only FY24/25/26 clusters surfaced |
| Fiscal year cluster tables hardcoded (2023–2026) | `int_ffv_clusters` | Manual update needed each year |
| No `ffv_model_version` or `ffv_score_date` stamp in gold table | `metrics_fev_by_fan_id` | Missing — can't distinguish which model run produced which scores |
| Infutor columns still in gold table | `metrics_fev_by_fan_id` via `dim_fans` | Not for modeling — should be flagged in column metadata |
| `agg_fan_profiles_4_year_ffv` catch-all `IS NULL` condition may never fire | `agg_fan_profiles_4_year_ffv` | Coalesced flags are never null |

---

## Review Output Format

```
# PR Review — [PR Title]
**PR:** #<number> | **Author:** <name> | **Branch:** <branch> → main
**Files changed:** <N> | **Reviewed:** <date>

## Summary
<2-3 sentence overview of what the PR does>

## Recommendation: [✅ APPROVE | ⚠️ APPROVE WITH COMMENTS | ❌ BLOCK]

## Blocking Issues (must fix before merge)
### ❌ [Issue Title]
**File:** `path/to/file.sql` | **Line:** ~N
**Problem:** ...
**Fix:** ...

## Non-blocking Comments (should fix, won't block)
### ⚠️ [Issue Title]
...

## Pre-existing Issues (not introduced by this PR — for awareness)
- ...

## Checklist Results
| Category | Status | Notes |
|---|---|---|
| Source references | ✅/⚠️/❌ | ... |
| int_ffv_clusters | ... | ... |
| metrics_by_fan | ... | ... |
| Gold table | ... | ... |
| Mart / touchpoints | ... | ... |
| Aggregations | ... | ... |
| Bot/test exclusion | ... | ... |
| Metadata | ... | ... |
```

---

## Jeff's Standards That Apply to All FEV PRs

1. **Metadata-first:** Every new or modified table/view should have a table-level COMMENT and column-level COMMENTs using `DEFINITION:` / `SOURCE:` / `VALIDATION:` format (see FFV 2026 Metadata-First Retrofit session)
2. **No Infutor for modeling:** `infutor_*` columns are third-party lifestyle signals — not organic fan behavior. Should be excluded from any training feature set
3. **Model version stamp:** Any change that updates the FFV scoring logic should add/update `ffv_model_version` and `ffv_score_date` columns in the gold output
4. **Bot exclusion:** Any PR that touches the population flowing into FEV metrics should include a check against `interaction_flags.is_bot_user` and `is_test_user`
5. **US filter verification:** Any change touching `fct_us_all_data_touchpoints` must verify the `country_name = 'UNITED STATES'` filter returns a nonzero population
