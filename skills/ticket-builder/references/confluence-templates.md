# Confluence Templates — FDVS Style

These are the five canonical templates for NBA Confluence specification documents. Each emphasizes strategic business value for delivery managers and executives, with embedded Jira tickets, stakeholder confirmation, and clear timelines. Based on 4+ years of stakeholder-driven development patterns.

---

## Template A: Strategic Initiative (Data Integration) Spec

> Use for: New vendor feeds, API sources, partner data ingests that require executive visibility
> Examples: MediaKind, Rakuten, Yinzcam, Satisfi, Sports Radar, Jr NBA League Apps
> Pairs with Jira Template A: New Data Integration

```markdown
# [Initiative Name]: [Vendor/Source] Data Integration

## Executive Summary

**Business Impact:** [One-paragraph summary of strategic value. Answer: Why does this matter to the business? What capability does this unlock? What stakeholder need does this address?]

**Expected Outcome:** [Quantifiable business outcome — e.g., "Enables personalized fan engagement campaigns reaching 2M+ fans", "Unlocks $X revenue opportunity through targeted offers", "Reduces manual reporting effort by 80 hours/month"]

**Timeline:** [Start date] – [Go-live date] | **Status:** [Planning / In Progress / UAT / Live]

**Strategic Alignment:** [How this supports NBA/team strategic goals — e.g., "Supports 2026 Fan Data Value Stream goal of unified fan 360-degree view"]

---

## Stakeholder Confirmation

| Stakeholder | Role | Confirmation Status | Business Justification |
|---|---|---|---|
| [Name] | Business Owner | ✅ Confirmed [YYYY-MM-DD] | [Why they need this — the business problem being solved] |
| [Name] | Technical Lead | ✅ Confirmed [YYYY-MM-DD] | [Technical necessity or enablement] |
| [Name] | Executive Sponsor | ✅ Confirmed [YYYY-MM-DD] | [Strategic importance or budget justification] |

---

## Business Context

**Problem Statement:**
[What business gap exists today? What can't we do without this data? What manual workarounds are in place?]

**User Personas Impacted:**
- **[Persona 1 — e.g., Marketing Analyst]:** [How they will use this data and what decisions it enables]
- **[Persona 2 — e.g., Data Scientist]:** [How they will use this data and what decisions it enables]
- **[Persona 3 — e.g., Executive Leadership]:** [What visibility or insights this provides]

**Success Story (Post-Launch):**
> "After this integration, [stakeholder] can [action] in [timeframe], enabling [business outcome]. This eliminates [pain point] and unlocks [opportunity]."

---

## Implementation Timeline

| Milestone | Target Date | Value Delivered | Status | Owner |
|---|---|---|---|---|
| **Vendor API/File Access** | [Date] | Technical prerequisite unblocked | [Status] | [Name] |
| **Ingest Pipeline** | [Date] | Raw data available for validation | [Status] | [Name] |
| **Gold Layer Transformation** | [Date] | Business-ready data available in FDP | [Status] | [Name] |
| **Business UAT Sign-Off** | [Date] | Stakeholder confirms data meets needs | [Status] | [Name] |
| **Production Launch** | [Date] | Data available for operational use | [Status] | [Name] |
| **90-Day Health Check** | [Date] | Validate business outcome metrics | [Status] | [Name] |

**Hard Deadlines (if any):**
- [Date]: [Reason — e.g., "Partnership contract requires data integration by this date"]

---

## Technical Architecture

### Source Details

| Attribute | Value |
|---|---|
| **Vendor / Source** | [Name] |
| **Data Format** | [API / File / Database / Streaming] |
| **Ingestion Cadence** | [Real-time / Daily / Weekly / Ad hoc] |
| **Expected Volume** | [Approx row count per load] |
| **Technical POC (Vendor)** | [Name, contact] |
| **Technical POC (NBA)** | [Name] |
| **API Docs / Sample Files** | [Link or "Pending from vendor"] |

### Data Fields

| Field Name | Description | Sample Value | FDP Mapping | Business Use Case |
|---|---|---|---|---|
| [field] | [description] | [example] | [target column/table] | [How this field will be used] |

### Implementation Approach

**Target tables:**
- Ingest: `db_fandata_prd.[schema].[table]`
- Gold: `db_fandata_prd.[schema].[table]`

**Data Quality Rules:** [Key validation rules — nulls, duplicates, date range coverage]

[Reference specific FDP patterns being followed.]

---

## Jira Tickets

### Epic
- **[IDE-XXXX: Epic Title]** — Overall initiative tracking | [Status] | [Assignee]

### Implementation Stories
- **[IDE-YYYY: Ingest Pipeline]** — Raw data ingestion | [Status] | [Assignee]
- **[IDE-ZZZZ: Gold Layer Transformation]** — Business-ready transformation | [Status] | [Assignee]

### Data Quality Tickets
- **[IDE-BBBB: Data Quality Rules]** — Automated validation setup | [Status] | [Assignee]

**Ticket Board:** [Link to filtered Jira board view for this initiative — only include if link is confirmed to exist]

---

## Working Group

| Working Group | Stakeholders | Scope |
|---|---|---|
| **Business Owners** | [Names] | Requirements definition, UAT validation, sign-off |
| **Data Product Lead** | [Your Name] | Overall ownership, requirements, project management |
| **Data Engineering** | [Names] | Pipeline implementation, data quality, production support |
| **Data Platform** | [Names] | Infrastructure, permissions, governance |
| **Vendor / Partner** | [Names] | API access, documentation, troubleshooting |

---

## References

### Internal Documentation
- **Jira Epic:** [Link — only if confirmed to exist]
- **FDP Standards:**
  - [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
- **Vendor API Docs:** [Link — only if confirmed to exist]
- **Partnership Agreement:** [Link or "Confidential — contact [Data Product Lead]"]

---

## Change Log

| Date | Change | Author |
|---|---|---|
| [YYYY-MM-DD] | Initial spec created | [Name] |
| [YYYY-MM-DD] | [What changed] | [Name] |
```

---

## Template B: Analytics Engineering Technical Specification

> Use for: New or modified dbt models, staging/intermediate/mart layers, schema.yml definitions, gold table builds, AE layer refactors, semantic layer metrics
> Examples: FEV gold table build, FFV cluster mart, fan cohort intermediate model, new dbt source + staging pipeline
> Pairs with Jira Template B: Analytics Engineering

```markdown
# [Model/Layer Name]: [dbt Model / Mart / Metric] Technical Specification

## Executive Summary

**Business Objective:** [One-paragraph summary of what analytical capability this model enables. Answer: What can analysts and stakeholders do once this model exists that they couldn't before?]

**Model Output:** [What the model produces — e.g., "One row per fan per event date with fan lifetime value metrics", "Segment assignments for all active subscribers"]

**Downstream Use Cases:** [Who will use this model and for what — e.g., "FEV scoring pipeline", "Marketing campaign targeting", "Executive engagement dashboard"]

**Timeline:** [Start date] – [Launch date] | **Status:** [Planning / Development / Review / Live]

---

## Stakeholder Confirmation

| Stakeholder | Role | Confirmation Status | Business Justification |
|---|---|---|---|
| [Name] | Business Owner | ✅ Confirmed [YYYY-MM-DD] | [What analytical question they need answered] |
| [Name] | Analytics Engineer | ✅ Confirmed [YYYY-MM-DD] | [Technical feasibility and source availability] |
| [Name] | Data Product Lead | ✅ Confirmed [YYYY-MM-DD] | [Strategic value and priority] |

---

## Model Scope

**Model type:** [Staging / Intermediate / Mart / Semantic metric]
**Grain:** [One row per what — e.g., "one row per fan per event date"]
**Target table:** `db_fandata_prd.[schema].[model_name]`

**Source tables:**
| Source | Table | Role |
|---|---|---|
| [upstream model or raw source] | `[db.schema.table]` | [what data it provides] |

---

## Business Context

**Problem Statement:**
[What analytical gap exists today? What questions can't be answered? What manual work is being done as a workaround?]

**Current State (Without Model):**
[How is this analysis currently being done? What are the limitations?]

**Future State (With Model):**
[How will this change what analysts and stakeholders can do?]

---

## Technical Approach

[Transformation logic, key joins, filters, and business rules. Reference dbt conventions to follow.]

**Key business rules:**
- [Rule 1 — e.g., "Exclude fans with IS_TEST_USER = TRUE"]
- [Rule 2 — e.g., "Use TRANSACTION_DATE for grain, not LOAD_DATE"]

**schema.yml requirements:**
- All columns documented with descriptions
- dbt tests: unique + not_null on primary key, accepted_values where applicable
- Model-level description explaining grain and intended use

---

## Implementation Timeline

| Milestone | Target Date | Value Delivered | Status | Owner |
|---|---|---|---|---|
| **Source / Staging Models Ready** | [Date] | Upstream dependencies unblocked | [Status] | [Name] |
| **Model Development Complete** | [Date] | Logic implemented in DEV | [Status] | [Name] |
| **dbt Tests Passing** | [Date] | Data quality validated | [Status] | [Name] |
| **PR Review & Merge** | [Date] | Code approved and in QA | [Status] | [Name] |
| **Business UAT Sign-Off** | [Date] | Stakeholder confirms model output | [Status] | [Name] |
| **Production Launch** | [Date] | Model live for downstream use | [Status] | [Name] |

---

## Jira Tickets

### Epic
- **[IDE-XXXX: Epic Title]** — Overall initiative | [Status] | [Assignee]

### Implementation
- **[IDE-YYYY: dbt Model Build]** — [model_name] development | [Status] | [Assignee]
- **[IDE-ZZZZ: Business UAT]** — Stakeholder validation | [Status] | [Assignee]

**Ticket Board:** [Link — only if confirmed to exist]

---

## Working Group

| Working Group | Stakeholders | Scope |
|---|---|---|
| **Business Owners** | [Names] | Requirements, UAT, sign-off |
| **Data Product Lead** | [Your Name] | Overall ownership, requirements, project management |
| **Analytics Engineering** | [Names] | Model development, schema.yml, PR review |
| **Data Engineering** | [Names] | Upstream source availability |

---

## References

- **Jira Epic:** [Link — only if confirmed to exist]
- **Upstream ticket:** [IDE-XXXX — only if confirmed to exist]
- [dbt Guide](https://nba.atlassian.net/wiki/spaces/DPAE/pages/8861876661/dbt+Guide)

---

## Change Log

| Date | Change | Author |
|---|---|---|
| [YYYY-MM-DD] | Initial spec created | [Name] |
| [YYYY-MM-DD] | [What changed] | [Name] |
```

---

## Template C: Quality Investigation Report

> Use for: Broken pipelines, UAT findings, data mismatches, count discrepancies, PII exposure
> Examples: Evergent subscription status errors, Roku missing date ranges, exposed emails in db_fananalytics
> Pairs with Jira Template C: Data Quality Investigation

```markdown
# [Issue Name]: [System/Source] Data Quality Investigation

## Executive Summary

**Business Impact:** [One-paragraph summary of how this issue affects business operations, reporting, or decisions. Quantify if possible.]

**Current Status:** [Investigation / Root Cause Identified / Fix In Progress / Resolved]

**Affected Systems:** [List dashboards, reports, or downstream systems impacted]

**Timeline:**
- Issue Discovered: [Date]
- Root Cause Identified: [Date or "In progress"]
- Fix Deployed: [Date or "Target: [date]"]
- Validation Complete: [Date or "Target: [date]"]

**Severity:** [Critical / High / Medium / Low] — [Why this severity level]

---

## Stakeholder Confirmation

| Stakeholder | Role | Confirmation Status | Business Justification |
|---|---|---|---|
| [Name] | Business Owner | ✅ Confirmed [YYYY-MM-DD] | [Why this issue matters to them / what decisions are blocked] |
| [Name] | Technical Lead | ✅ Confirmed [YYYY-MM-DD] | [Technical urgency or downstream system impact] |
| [Name] | Reporter | ✅ Confirmed [YYYY-MM-DD] | [How they discovered the issue / what alerted them] |

---

## Problem Statement

**What's Wrong:**
[Clear description of the issue with quantitative evidence.]

**Evidence:**
```sql
-- Query that reproduces the issue
SELECT ...
FROM ...
WHERE ...
```

**Example of Incorrect Data:**

| Expected | Actual | Difference | Date Range |
|---|---|---|---|
| [value] | [value] | [delta] | [dates] |

**Scope:**
- **Date range affected:** [Start date] – [End date or "Ongoing"]
- **Estimated rows impacted:** [Count or percentage]
- **First occurrence:** [Date or "Unknown — investigating"]

---

## Business Impact Assessment

### Downstream Consumers Affected

| System/Report | Impact | Business Owner | Mitigation |
|---|---|---|---|
| [Dashboard name] | [How it's wrong] | [Name] | [What we're doing to limit damage] |

**Quantified Business Impact:**
- [e.g., "Inflates 'Churned - Voluntary' count by ~15%, causing inaccurate churn reporting in executive board deck"]
- [e.g., "Blocks Marketing from launching campaign due to unreliable audience segment"]

---

## Root Cause Analysis

**Status:** [Complete / In Progress]

**Root Cause:**
[What is known so far. If unknown, describe investigation approach. If complete, provide detailed technical explanation.]

**Contributing Factors:**
1. [Factor 1 — e.g., "Vendor changed API response format without notification"]
2. [Factor 2 — e.g., "Transformation logic didn't account for null values in edge case"]

**Timeline of Events:**
| Date/Time | Event | Source |
|---|---|---|
| [When] | [What happened] | [System/person] |

**Why It Wasn't Caught Earlier:**
[What monitoring gap or process failure allowed this to reach production/business users]

---

## Resolution Plan

### Immediate Actions (Mitigation)
- [ ] [Action to limit damage while permanent fix is being developed]
- [ ] [Communication plan — who needs to know, what do they need to do]

### Permanent Fix
**Technical Approach:**
[Step-by-step description of the fix. Include SQL, config changes, or code changes at high level.]

**Validation Method:**
```sql
-- Query that will confirm the fix worked
SELECT ...
```

**Rollback Plan:**
[If fix fails, how do we revert? What's the safe rollback window?]

---

## Implementation Timeline

| Milestone | Target Date | Value Delivered | Status | Owner |
|---|---|---|---|---|
| **Root Cause Identified** | [Date] | Understanding of what went wrong | [Status] | [Name] |
| **Fix Developed & Tested in DEV** | [Date] | Solution validated in lower environment | [Status] | [Name] |
| **Fix Deployed to QA/Staging** | [Date] | Ready for business validation | [Status] | [Name] |
| **Business UAT Sign-Off** | [Date] | Stakeholder confirms data is correct | [Status] | [Name] |
| **Fix Deployed to PROD** | [Date] | Issue resolved for end users | [Status] | [Name] |
| **Monitoring Alert Configured** | [Date] | Prevention mechanism in place | [Status] | [Name] |

---

## Jira Tickets

### Investigation & Fix
- **[IDE-XXXX: Root Cause Investigation]** — Analysis and diagnosis | [Status] | [Assignee]
- **[IDE-YYYY: Implement Fix]** — Code/config changes | [Status] | [Assignee]
- **[IDE-ZZZZ: Backfill Affected Data]** — Correct historical records (if applicable) | [Status] | [Assignee]

### Prevention
- **[IDE-AAAA: Data Quality Monitoring]** — Add alert to catch this in future | [Status] | [Assignee]

**Ticket Board:** [Link — only if confirmed to exist]

---

## Prevention Strategy

**What We're Doing to Prevent Recurrence:**
1. **Monitoring:** [Specific data quality rule or alert being added]
2. **Process:** [Any process change — e.g., "Require vendor to notify us 2 weeks before API changes"]
3. **Documentation:** [What's being documented for future reference]

---

## References

### Internal Documentation
- **Jira Investigation Ticket:** [Link — only if confirmed to exist]
- **Related Past Issues:** [IDE-XXXX — similar issue from [date], only if confirmed]
- **FDP Standards:**
  - [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
- **Vendor API Docs:** [Link — only if confirmed to exist]

---

## Change Log

| Date | Change | Author |
|---|---|---|
| [YYYY-MM-DD] | Issue discovered and spec created | [Name] |
| [YYYY-MM-DD] | Root cause identified | [Name] |
| [YYYY-MM-DD] | Fix deployed to PROD | [Name] |
```

---

## Template D: Platform Migration Plan

> Use for: Moving objects between environments, dbt migrations, Snowflake schema migrations, deprecations
> Examples: Sandbox → dbt, Azure → Snowflake, db_fivetran → FDP, legacy table deprecation
> Pairs with Jira Template D: Platform Migration

```markdown
# [Migration Name]: [Source] to [Target] Migration Plan

## Executive Summary

**Business Rationale:** [One-paragraph summary of why we're migrating. Focus on business outcomes, not just technical reasons.]

**Expected Benefits:**
- [e.g., "Reduces platform costs by $X/month through consolidation"]
- [e.g., "Improves query performance by 50% through modern architecture"]
- [e.g., "Meets compliance requirements for data governance"]
- [e.g., "Eliminates technical debt and reduces maintenance burden"]

**Timeline:** [Start date] – [Cutover date] – [Deprecation date] | **Status:** [Planning / In Progress / Cutover / Complete]

**Risk Level:** [Low / Medium / High] — [Why]

---

## Stakeholder Confirmation

| Stakeholder | Role | Confirmation Status | Business Justification |
|---|---|---|---|
| [Name] | Business Owner | ✅ Confirmed [YYYY-MM-DD] | [Why they support this migration / what they gain] |
| [Name] | Technical Lead | ✅ Confirmed [YYYY-MM-DD] | [Technical necessity or platform improvement] |
| [Name] | Downstream Consumer | ✅ Confirmed [YYYY-MM-DD] | [Impact to their systems / what changes they need to make] |

---

## Migration Scope

**Migrating:**
- **Object Types:** [Tables / Views / dbt models / Pipelines / Dashboards]
- **Object Count:** [Approx number — e.g., "47 tables, 23 views"]
- **Data Volume:** [Approx row count or GB]
- **Downstream Systems:** [How many dashboards/reports/models consume these objects]

**From:**
- **Source Platform:** [e.g., Azure SQL / Sandbox / db_fivetran]
- **Source Schema:** [Schema name(s)]
- **Current State:** [e.g., "Manually maintained tables"]

**To:**
- **Target Platform:** [e.g., Snowflake / dbt]
- **Target Schema:** `db_fandata_prd.[schema]`
- **Target State:** [e.g., "dbt-managed transformations", "FDP governed layer"]

---

## Business Justification

**Why Migrate Now:**
[Detailed explanation of business drivers. Include any of: compliance deadline, cost reduction, performance improvement, technical debt elimination, vendor deprecation.]

**What Happens If We Don't Migrate:**
[Consequences of inaction — e.g., "Platform reaches end-of-life in [date]", "Costs increase by $X/year", "Unable to meet new compliance requirements"]

**Strategic Alignment:**
[How this supports NBA/team strategic goals — e.g., "Supports FDP consolidation initiative", "Aligns with 2026 data governance roadmap"]

---

## Implementation Timeline

| Milestone | Target Date | Value Delivered | Status | Owner |
|---|---|---|---|---|
| **Migration Plan Approved** | [Date] | Stakeholder alignment on approach | [Status] | [Name] |
| **DEV Migration Complete** | [Date] | Technical feasibility validated | [Status] | [Name] |
| **QA/Staging Migration** | [Date] | Business validation ready | [Status] | [Name] |
| **Business UAT Sign-Off** | [Date] | Stakeholders approve new location | [Status] | [Name] |
| **PROD Cutover** | [Date] | Live traffic switched to new platform | [Status] | [Name] |
| **2-Week Validation Period** | [Date] | Confirm stability and quality | [Status] | [Name] |
| **Old Environment Deprecated** | [Date] | Legacy objects dropped, migration complete | [Status] | [Name] |

**Hard Deadlines (if any):**
- [Date]: [Reason — e.g., "Vendor contract ends", "Compliance deadline"]

---

## Technical Approach

### Migration Phases

**Phase 1: Discovery & Planning**
- Catalog all objects in source environment
- Identify downstream dependencies
- Baseline performance and row counts
- Define validation criteria

**Phase 2: DEV Migration**
- Migrate objects to DEV target environment
- Validate row counts and schema
- Test transformation logic
- Document any schema changes required

**Phase 3: QA/Staging Migration**
- Migrate to QA/Staging
- Business UAT validation
- Performance benchmarking
- Downstream system integration testing

**Phase 4: Production Cutover**
- Migrate to PROD during maintenance window
- Switch connections/aliases to point to new location
- Monitor for issues
- Keep old objects available for rollback

**Phase 5: Deprecation**
- After 2-week validation period, mark old objects as deprecated
- Update documentation to reflect new locations
- After [X] additional weeks with no issues, drop old objects

---

## Rollback Plan

**Rollback Window:** [Timeframe — e.g., "48 hours post-cutover"]

**Rollback Procedure:**
1. [Step 1 — e.g., "Revert connection alias to point to old location"]
2. [Step 2 — e.g., "Notify stakeholders of rollback"]
3. [Step 3 — e.g., "Investigate issue and reschedule cutover"]

**Rollback Safety:**
- Original objects will NOT be dropped until [date] — [X] weeks after successful cutover
- All downstream systems can be re-pointed to old location
- Data continues to refresh in old location during validation period

---

## Validation Approach

### Pre-Migration Baseline
```sql
-- Document row counts for all migrated objects
SELECT 'source_table_1' AS table_name, COUNT(*) AS row_count FROM [source.table1]
UNION ALL
SELECT 'source_table_2', COUNT(*) FROM [source.table2];
```

### Post-Migration Validation
```sql
-- Compare row counts between old and new
SELECT 'old' AS source, COUNT(*) FROM [old_table]
UNION ALL
SELECT 'new' AS source, COUNT(*) FROM [new_table];
```

---

## Jira Tickets

### Epic
- **[IDE-XXXX: Migration Epic Title]** — Overall migration tracking | [Status] | [Assignee]

### Planning & Discovery
- **[IDE-YYYY: Migration Discovery]** — Catalog objects and dependencies | [Status] | [Assignee]

### Implementation
- **[IDE-ZZZZ: DEV Migration]** — Migrate objects to DEV | [Status] | [Assignee]
- **[IDE-AAAA: QA Migration]** — Migrate to QA and validate | [Status] | [Assignee]
- **[IDE-BBBB: PROD Cutover]** — Production migration | [Status] | [Assignee]

### Post-Migration
- **[IDE-CCCC: Old Environment Deprecation]** — Drop legacy objects | [Status] | [Assignee]

**Ticket Board:** [Link — only if confirmed to exist]

---

## Affected Systems & Communication Plan

### Downstream Systems

| System | Owner | Impact | Action Required | Status |
|---|---|---|---|---|
| [Dashboard name] | [Name] | [What changes] | [What owner needs to do] | [Notified / Updated / Tested] |

### Communication Timeline

| Date | Audience | Message | Channel |
|---|---|---|---|
| [Date] | All downstream consumers | Migration announcement, timeline, impact | Email / Slack |
| [Date - 1 week] | All stakeholders | Reminder: cutover in 1 week | Email / Slack |
| [Date] | All stakeholders | Cutover complete, validation in progress | Email / Slack |

---

## References

### Internal Documentation
- **Jira Epic:** [Link — only if confirmed to exist]
- **FDP Standards:**
  - [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
  - [dbt Guide](https://nba.atlassian.net/wiki/spaces/DPAE/pages/8861876661/dbt+Guide)

---

## Change Log

| Date | Change | Author |
|---|---|---|
| [YYYY-MM-DD] | Migration plan created | [Name] |
| [YYYY-MM-DD] | [Phase completed or plan updated] | [Name] |
```

---

## Template E: Data Science / ML Model Spec

> Use for: Propensity models, fan lifetime value, segmentation, recommendation engines
> Examples: FFV Phase 2, Propensity to Convert, Propensity to Cancel, FEV Cohort Analysis, Game Recommendation V2
> Pairs with Jira Template E: Data Science / ML Model

```markdown
# [Model Name]: [Model Type] Model for [Business Use Case]

## Executive Summary

**Business Objective:** [One-paragraph summary of what business decision or action this model enables. Answer: What will we do differently once we have this model?]

**Expected Business Impact:**
- [e.g., "Increase free-trial-to-paid conversion by 5% through personalized targeting"]
- [e.g., "Reduce churn by identifying at-risk fans 30 days before expected cancellation"]

**Model Output:** [What the model produces — e.g., "Propensity score 0-100 for each fan", "Segment assignment (High/Medium/Low value)"]

**Business Action:** [What happens with the model output — e.g., "Marketing uses propensity score to trigger personalized Braze campaigns"]

**Timeline:** [Discovery start] – [Model launch date] – [A/B test complete date] | **Status:** [Discovery / Development / UAT / Production]

---

## Stakeholder Confirmation

| Stakeholder | Role | Confirmation Status | Business Justification |
|---|---|---|---|
| [Name] | Business Owner | ✅ Confirmed [YYYY-MM-DD] | [What business problem they need solved] |
| [Name] | Data Science Lead | ✅ Confirmed [YYYY-MM-DD] | [Model feasibility and technical approach] |
| [Name] | Data Engineering Lead | ✅ Confirmed [YYYY-MM-DD] | [Operationalization support and infrastructure] |
| [Name] | Marketing/Product Lead | ✅ Confirmed [YYYY-MM-DD] | [How they'll use model output in campaigns/product] |

---

## Business Context

**Problem Statement:**
[What business challenge exists today? What decisions are being made without data? What manual processes could be automated?]

**Current State (Without Model):**
[How is this decision/action currently being done? What are the limitations?]

**Future State (With Model):**
[How will this decision/action be improved?]

---

## Model Development Approach

### Model Type
[Classification / Regression / Segmentation / Recommendation]

### Methodology
[Logistic Regression / Random Forest / XGBoost / Neural Network / Clustering / etc.]
[Why this approach was chosen over alternatives]

### Training/Validation Split
- **Training Set:** [Time period or percentage]
- **Validation Set:** [Time period or percentage]
- **Holdout Test Set:** [Time period or percentage — never touched during development]

### Evaluation Metrics
- **Primary:** [Metric name — e.g., AUC-ROC, RMSE, Silhouette Score]
- **Secondary:** [Other metrics — e.g., Precision/Recall, Lift, F1]
- **Threshold:** [Performance target model must meet before launch — e.g., "AUC > 0.75"]

---

## Input Features (Proposed)

| Feature | Source Table | Description | Hypothesis |
|---|---|---|---|
| [feature_name] | `db_fandata_prd.[schema].[table]` | [What it represents] | [Why we think this matters] |

*Feature list to be finalized during EDA phase.*

---

## Operationalization

### Scoring Pipeline
**Where:** [dbt model / Python job / Snowflake stored procedure]
**Refresh Cadence:** [Daily / Weekly / On-demand / Real-time]

### Output Destination
**Primary:** `db_fandata_prd.[schema].[table_name]`

### Output Schema
| Column | Type | Description |
|---|---|---|
| fan_id | VARCHAR | Unique fan identifier |
| score | FLOAT | [Model score — range and meaning] |
| score_decile | INTEGER | [Decile rank 1-10] |
| scored_at | TIMESTAMP | When score was generated |

---

## Model Governance

### Model Monitoring
- **Performance Tracking:** [How we'll monitor model degradation — e.g., "Track monthly AUC on rolling validation set"]
- **Data Drift:** [How we'll detect input distribution changes]
- **Alerting:** [Thresholds that trigger model retraining]

### Retraining Cadence
[How often model will be retrained — e.g., "Quarterly", "When performance degrades"]

---

## Implementation Timeline

| Milestone | Target Date | Value Delivered | Status | Owner |
|---|---|---|---|---|
| **EDA Complete** | [Date] | Feature analysis and feasibility validated | [Status] | [Name] |
| **Model V1 Developed** | [Date] | Initial model trained and evaluated | [Status] | [Name] |
| **Business Review** | [Date] | Stakeholders review score distribution and logic | [Status] | [Name] |
| **Scoring Pipeline Built** | [Date] | Automated scoring infrastructure ready | [Status] | [Name] |
| **UAT Validation** | [Date] | Business validates scores for known high/low-value fans | [Status] | [Name] |
| **Production Launch** | [Date] | Scores available for operational use | [Status] | [Name] |
| **A/B Test Complete** | [Date] | Business impact measured and validated | [Status] | [Name] |

---

## Working Group

| Working Group | Stakeholders | Scope |
|---|---|---|
| **Business Owners** | [Names] | Requirements definition, feature validation, UAT, A/B test design |
| **Data Science** | [Your Name], [Name] | Model development, evaluation, documentation |
| **Data Engineering** | [Names] | Feature pipeline, scoring pipeline, operationalization |
| **Product Analytics** | [Names] | Feature requirements, A/B test analysis, success metrics tracking |
| **Marketing / Product** | [Names] | Business logic, campaign integration, adoption |
| **EXL (if applicable)** | [Names] | Feature engineering, complex business logic creation |

---

## Jira Tickets

### Epic
- **[IDE-XXXX: Model Epic Title]** — Overall initiative tracking | [Status] | [Assignee]

### Discovery & Development
- **[IDE-YYYY: EDA / Feature Analysis]** — Exploratory data analysis | [Status] | [Assignee]
- **[IDE-ZZZZ: Model Development]** — Training, tuning, evaluation | [Status] | [Assignee]
- **[IDE-AAAA: Business Review]** — Stakeholder validation of model logic | [Status] | [Assignee]

### Operationalization
- **[IDE-BBBB: Scoring Pipeline]** — Automated scoring infrastructure | [Status] | [Assignee]
- **[IDE-CCCC: Model Monitoring]** — Performance tracking setup | [Status] | [Assignee]

### Post-Launch
- **[IDE-DDDD: A/B Test Analysis]** — Measure business impact | [Status] | [Assignee]

**Ticket Board:** [Link — only if confirmed to exist]

---

## References

### Internal Documentation
- **Jira Epic:** [Link — only if confirmed to exist]
- **EDA Notebook:** [Link — only if confirmed to exist]
- **FDP Standards:**
  - [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
  - [dbt Guide](https://nba.atlassian.net/wiki/spaces/DPAE/pages/8861876661/dbt+Guide)

---

## Change Log

| Date | Change | Author |
|---|---|---|
| [YYYY-MM-DD] | Initial spec created | [Name] |
| [YYYY-MM-DD] | EDA complete, features finalized | [Name] |
| [YYYY-MM-DD] | Model launched to production | [Name] |
```

---

## Anti-Patterns to Avoid

These are patterns that should **not** be replicated in Confluence specs:

| Anti-pattern | What to write instead |
|---|---|
| Leading with technical details before business value | Always start with Executive Summary showing business impact |
| Missing Stakeholder Confirmation table | Always include with explicit confirmation dates |
| Generic "This will help the business" language | Specific, quantified business outcomes (revenue, time saved, lift %) |
| No linked Jira tickets | Embed ticket links throughout; include dedicated Jira Tickets section |
| Timeline with no value delivery milestones | Every milestone must show what value stakeholders receive |
| "TBD" or "To be determined" | Specific TBD with owner and target date: "TBD — [Name] to confirm by [date]" |
| No visual timeline or roadmap | Include Implementation Timeline table showing dates/value/status |
| Technical jargon without business translation | Explain technical terms in business language |
| Missing working group or stakeholder matrix | Always show who's involved and what their role is |
| Adding Success Metrics / KPIs section | Omit — outcomes belong in the Executive Summary and timeline |
| Adding Testing Strategy section | Omit — execution detail, not spec scope |
| Adding Dependencies / BLOCKED BY / BLOCKS section | Omit — dependency scaffolding clutters specs |
| Using `db_bronze` or `db_silver` | Use `db_fandata_prd.[schema].[table]` for production |
| Alation references of any kind | Never mention Alation in any spec section |
| Constructed or guessed URLs | Only include links confirmed to exist; omit rather than guess |
| Hardcoded personal names in template fields | Always use placeholder `[Your Name]` / `[Data Product Lead]` |

---

## Usage Guide

### When to Use Each Template

- **Template A (Strategic Initiative):** New vendor integrations, major data sources, partnership-driven work requiring executive visibility
- **Template B (Technical Specification):** New or modified dbt models, marts, gold tables, AE layer work requiring stakeholder sign-off
- **Template C (Quality Investigation):** Data quality issues, broken pipelines, UAT findings requiring root cause analysis and stakeholder impact assessment
- **Template D (Platform Migration):** Moving between platforms, deprecating legacy systems, large-scale technical migrations with business impact
- **Template E (DS/ML Model Spec):** Propensity models, segmentation, recommendation engines, any ML model requiring business validation

### Customization Guidelines

- All five templates are starting points — adapt sections based on initiative complexity
- For smaller initiatives, collapse sections (e.g., simplify Working Group to a single table)
- For larger initiatives, expand sections (e.g., split Technical Architecture into multiple pages)
- Always maintain: Executive Summary, Stakeholder Confirmation, Implementation Timeline, Jira Tickets

### Template F (Investigation / Anomaly Flag)

Investigation / Anomaly Flag tickets (Jira Template F) do **not** require a Confluence page. They are lightweight PM-to-DE consultation tickets. If the investigation reveals a pattern worth documenting, use Template C instead.

### Confluence Page Setup

- Create page under appropriate space (e.g., "Fan Data Platform", "Data Science", "Product Analytics")
- Tag with: project name, stakeholder names, initiative type
- Set permissions so all stakeholders have view access
- Pin to space homepage if high-visibility initiative
- Update Change Log section each time page is materially updated

---

**Document Version:** 2.0
**Last Updated:** 2026-06-09
**Owner:** [Data Product Lead]
