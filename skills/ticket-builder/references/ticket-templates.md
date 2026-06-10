# Ticket Templates

These are the six canonical templates for Jira tickets. Each encodes established patterns from 4+ years of ticket writing: user story leads, evidence-based AC, stakeholder tables, and FDP standards references.

---

## Template A: New Data Integration

> Use for: New vendor feeds, API sources, partner data ingests
> Examples: MediaKind, Rakuten, Yinzcam, Satisfi, Sports Radar, Jr NBA League Apps

```markdown
**As a [data analyst / data scientist], I want [source] data available in the Fan Data Platform
so that [business outcome — e.g., we can analyze fan behavior across all touchpoints].**

## Context
[Why this data is needed. What gap does it fill? Reference the partnership or business initiative driving it.]

**V1 Background (if applicable):** [Describe any prior version or related work for continuity.]

## Source Details

| Attribute | Value |
|---|---|
| **Vendor / Source** | [Name] |
| **Data Format** | [API / File / Database / Streaming] |
| **Ingestion Cadence** | [Real-time / Daily / Weekly / Ad hoc] |
| **Expected Volume** | [Approx row count per load] |
| **Technical POC (Vendor)** | [Name, contact] |
| **Technical POC (NBA)** | [Name] |
| **API Docs / Sample Files** | [Link or "Pending from vendor"] |

## Data Fields

| Field Name | Description | Sample Value | FDP Mapping |
|---|---|---|---|
| [field] | [description] | [example] | [target column/table] |
| [field] | [description] | [example] | [target column/table] |

*Add rows as fields are confirmed with vendor.*

## Solution

[Technical approach: raw ingest → staging transformation → gold layer. Reference specific FDP patterns to follow.]

**Target tables:**
- Ingest: `db_fandata_prd.[schema].[table]`
- Gold: `db_fandata_prd.[schema].[table]`

## Acceptance Criteria

**Data Ingestion:**
- [ ] Ingest pipeline created and scheduled
- [ ] Staging transformations complete and validated
- [ ] Row count matches expected volume within 2% tolerance
- [ ] No null values in required key fields

**Data Quality:**
- [ ] Duplicate check implemented
- [ ] Date range coverage validated (no missing days)

**Business Validation:**
- [ ] Business Owner ([Name]) validates sample data against source
- [ ] Sign-off documented in ticket comments

## Stakeholders

| Role | Name |
|---|---|
| Business Owner | [Name] |
| Data Product Lead | [Your Name] |
| Technical Lead | [Name] |
| Vendor POC | [Name] |
| FYI | [Name] |

## References

- Confluence Spec: [Link — only if confirmed to exist]
- Vendor API Docs: [Link — only if confirmed to exist]
- [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
```

---

## Template B: Analytics Engineering

> Use for: New or modified dbt models, staging/intermediate/mart layers, schema.yml definitions, gold table builds, AE layer refactors, semantic layer metrics
> Examples: FEV gold table build, FFV cluster mart, fan cohort intermediate model, new dbt source + staging pipeline, AE layer refactor

```markdown
**As a [data analyst / data scientist / stakeholder], I want [dbt model / mart / metric] available in [target layer]
so that [business outcome — e.g., analysts can measure fan engagement without writing raw SQL].**

## Context

[What analytical gap does this fill? What questions will this model answer? What downstream use cases does it enable?]

**V1 Background (if applicable):** [Prior version, related model, or upstream ticket this builds on.]

## Model Scope

**Model type:** [Staging / Intermediate / Mart / Semantic metric]
**Grain:** [One row per what — e.g., "one row per fan per event date"]
**Target table:** `db_fandata_prd.[schema].[model_name]`

**Source tables:**
| Source | Table | Role |
|---|---|---|
| [upstream model or raw source] | `[db.schema.table]` | [what data it provides] |

## Technical Approach

[Transformation logic, key joins, filters, and business rules. Reference dbt conventions to follow.]

**Key business rules:**
- [Rule 1 — e.g., "Exclude fans with IS_TEST_USER = TRUE"]
- [Rule 2 — e.g., "Use TRANSACTION_DATE for grain, not LOAD_DATE"]

## Acceptance Criteria

**Model:**
- [ ] dbt model runs without errors in DEV (`dbt run --select [model_name]`)
- [ ] All dbt data quality tests pass (`dbt test --select [model_name]`)
- [ ] schema.yml complete — all columns documented with descriptions
- [ ] Grain validated (no unexpected duplicates at defined grain)
- [ ] Row count and key metrics match expectations from source

**Code quality:**
- [ ] PR reviewed and approved by [Technical Lead]
- [ ] Follows dbt naming conventions and style guide
- [ ] No hardcoded values — all thresholds/filters documented as dbt vars or documented in schema.yml

**Business validation:**
- [ ] [Business Owner] confirms model output matches expected results for sample set
- [ ] Sign-off documented in ticket comments

## Working Group

| Working Group | Stakeholders | Scope |
|---|---|---|
| Business Owners | [Names] | Requirements definition, UAT, sign-off |
| Data Product Lead | [Your Name] | Overall ownership, requirements, project management |
| Analytics Engineering | [Names] | Model development, schema.yml, PR review |
| Data Engineering | [Names] | Upstream source availability |

## Stakeholders

| Role | Name |
|---|---|
| Business Owner | [Name] |
| Data Product Lead | [Your Name] |
| Analytics Engineer | [Name] |
| FYI | [Name] |

## References

- Confluence Spec: [Link — only if confirmed to exist]
- Upstream ticket: [IDE-XXXX — source data or upstream model, only if confirmed]
- [dbt Guide](https://nba.atlassian.net/wiki/spaces/DPAE/pages/8861876661/dbt+Guide)
```

---

## Template C: Data Quality Investigation

> Use for: Broken pipelines, UAT findings, data mismatches, count discrepancies, PII exposure
> Examples: Evergent subscription status errors, Roku missing date ranges, exposed emails in db_fananalytics

```markdown
**As a [data analyst / data owner], I want [specific data issue] resolved so that
[downstream consumers / stakeholders] have accurate data to rely on.**

## Problem Statement

[Clear description of the issue. Include quantitative evidence — SQL queries, date ranges, row counts, percentages.]

**Evidence:**
```sql
-- Query that reproduces the issue
SELECT ...
FROM ...
WHERE ...
```

**Example of incorrect data:**
| Expected | Actual | Difference |
|---|---|---|
| [value] | [value] | [delta] |

**Date range affected:** [Start date] – [End date]
**Estimated rows impacted:** [Count or percentage]

## Impact

**Downstream consumers affected:**
- [Dashboard / Report / Model name] — [how it's impacted]
- [System / Team] — [how it's impacted]

**Business impact:** [e.g., "Inflates 'Churned - Voluntary' count by ~15%, causing inaccurate churn reporting in board deck"]

## Root Cause Analysis

[What is known so far. Leave blank if unknown — do not write "TBD" alone.]

If unknown at ticket creation:
> Root cause TBD — investigation required. See Acceptance Criteria for discovery tasks.

## Proposed Solution

[Technical fix approach. If not yet determined, describe the investigation approach instead.]

## Acceptance Criteria

**Investigation:**
- [ ] Root cause identified and documented in ticket comments

**Fix:**
- [ ] Fix implemented and validated in DEV
- [ ] Fix validated in QA/Staging
- [ ] Fix deployed to PROD

**Validation:**
- [ ] Affected rows corrected or backfilled
- [ ] Data matches expected values (document validation query in comments)
- [ ] [Business Owner] confirms data looks correct

**Prevention:**
- [ ] Data quality alert or monitoring rule added to prevent recurrence

## Stakeholders

| Role | Name |
|---|---|
| Business Owner | [Name — who relies on this data] |
| Data Product Lead | [Your Name] |
| Technical Lead | [Name] |
| Reporter | [Name — who found the issue] |
| FYI | [Name] |

## References

- Confluence page (data source docs): [Link — only if confirmed to exist]
- Related tickets: [IDE-XXXX — original ingestion ticket]
- [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
```

---

## Template D: Platform Migration

> Use for: Moving objects between environments, dbt migrations, Snowflake schema migrations, deprecations
> Examples: Sandbox → dbt, Azure → Snowflake, db_fivetran → FDP, legacy table deprecation

```markdown
**As a [data engineer / data scientist], I want [objects / workflows] migrated from [source]
to [target] so that [reason — e.g., we operate on a single governed platform and reduce technical debt].**

## Migration Scope

**Migrating:** [What — tables, views, dbt models, pipelines, dashboards]
**From:** [Source environment / platform / schema]
**To:** [Target environment / platform / schema]
**Object count:** [Approx number of objects being migrated]

## Business Justification

[Why migrate now? Compliance, cost, performance, deprecation deadline, consolidation.]

## Technical Approach

[Step-by-step migration strategy. Reference existing FDP patterns.]

**Phases:**
1. [Phase 1 description]
2. [Phase 2 description]
3. [Cutover / deprecation]

## Rollback Plan

[If migration fails, how do we revert? What's the window to roll back?]

> Example: "If issues are found within 48 hours of cutover, revert to [source] by re-pointing [connection/alias]. Original objects will not be dropped until 2-week validation period is complete."

## Acceptance Criteria

**Migration:**
- [ ] All [N] objects migrated to target environment
- [ ] No data loss — row counts validated before and after
- [ ] Performance validated (query times within [X]% of baseline)

**Quality:**
- [ ] All migrated objects pass dbt data quality tests (if applicable)
- [ ] Scheduled jobs running successfully for [N] days post-migration

**Governance:**
- [ ] Data catalog documentation updated to reflect new table locations
- [ ] Old objects marked deprecated (do not drop until sign-off)
- [ ] Confluence documentation updated

**Sign-off:**
- [ ] [Technical Lead] reviews PR / migration artifacts
- [ ] [Business Owner] validates data in new location

## Timeline

| Milestone | Target Date | Owner |
|---|---|---|
| Migration complete in DEV | [Date] | [Name] |
| QA validation | [Date] | [Name] |
| PROD cutover | [Date] | [Name] |
| Old objects deprecated | [Date] | [Name] |

**Hard deadline (if any):** [Date — and reason]

## Stakeholders

| Role | Name |
|---|---|
| Business Owner | [Name] |
| Data Product Lead | [Your Name] |
| Technical Lead | [Name] |
| Downstream Consumer | [Name / Team] |
| FYI | [Name] |

## References

- Confluence Migration Plan: [Link — only if confirmed to exist]
- [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
- [dbt Guide](https://nba.atlassian.net/wiki/spaces/DPAE/pages/8861876661/dbt+Guide)
```

---

## Template E: Data Science / ML Model

> Use for: Propensity models, fan lifetime value, segmentation, recommendation engines
> Examples: FFV Phase 2, Propensity to Convert, Propensity to Cancel, FEV Cohort Analysis, Game Recommendation V2

```markdown
**As a [data scientist / marketing analyst / business stakeholder], I want a [model type]
so that [business outcome — e.g., we can identify fans most likely to convert from free trial to paid
and target them with personalized offers].**

## Model Goal

[Clear description of what the model predicts or segments. Include the decision or action this model enables.]

**Model type:** [Classification / Regression / Segmentation / Recommendation]
**Output:** [Score / Segment / Predicted value]
**Business action driven by output:** [e.g., "Marketing to use propensity score to trigger Braze campaign"]

## Background

[V1 or prior work context if this is an iteration. Link previous tickets or Confluence docs.]

## Input Features (Proposed)

| Feature | Source Table | Description |
|---|---|---|
| [feature] | [db.schema.table] | [what it represents] |
| [feature] | [db.schema.table] | [what it represents] |

*Feature list to be finalized during discovery/EDA phase.*

## Model Development Approach

[Methodology, tooling, training/validation split, evaluation metrics.]

**Evaluation metrics:** [e.g., AUC-ROC, precision/recall, lift]
**Target performance threshold:** [e.g., AUC > 0.75]

## Operationalization

**Output destination:** `db_fandata_prd.[schema].[table]`
**Refresh cadence:** [Daily / Weekly / On-demand]
**Scoring pipeline:** [dbt model / Python job / Snowflake stored procedure]

## Working Group

| Working Group | Stakeholders | Scope |
|---|---|---|
| Product Analytics | [Names] | Feature requirements & analysis |
| Monetization / Marketing | [Names] | Business logic & campaign integration |
| Data Science | [Your Name], [Name] | Model development, requirements, project management |
| Data Engineering | [Names] | Scoring pipeline implementation |
| EXL (if applicable) | [Names] | Feature engineering & logic creation |

## Acceptance Criteria

**Model Development:**
- [ ] EDA complete and documented in Confluence
- [ ] Model trained and evaluated against holdout set
- [ ] Model meets target performance threshold ([metric] > [threshold])
- [ ] Model card / documentation written

**Operationalization:**
- [ ] Scoring pipeline implemented and scheduled in [dbt / Snowflake]
- [ ] Scores available in target destination: `db_fandata_prd.[schema].[table]`
- [ ] Scores validated against known ground truth (sample check)

**Business Validation:**
- [ ] [Business Owner] reviews score distribution and segment sizes
- [ ] Model output integrated into [Braze / dashboard / downstream system]
- [ ] A/B test plan defined (if applicable)

## Timeline

| Phase | Target Date | Owner |
|---|---|---|
| Data exploration / EDA | [Date] | [Name] |
| Model development | [Date] | [Name] |
| Business review | [Date] | [Name] |
| Pipeline implementation | [Date] | [Name] |
| Production launch | [Date] | [Name] |

## Stakeholders

| Role | Name |
|---|---|
| Business Owner | [Name] |
| Data Product Lead | [Your Name] |
| Data Science Lead | [Name] |
| Data Engineering Lead | [Name] |
| EXL Lead (if applicable) | [Name] |
| FYI | [Name] |

## References

- Confluence Model Spec: [Link — only if confirmed to exist]
- Prior model ticket: [IDE-XXXX — V1 or related work, only if confirmed]
- [SQL Style Guide](https://nba.atlassian.net/wiki/spaces/NGEW/pages/8719696245/SQL+Style+Guide)
- [dbt Guide](https://nba.atlassian.net/wiki/spaces/DPAE/pages/8861876661/dbt+Guide)
```

---

## Template F: Investigation / Anomaly Flag

> Use for: PM surfacing a data anomaly to a technical lead for their input. Not a formal project ticket — a lightweight investigation ask.
> Examples: Suspicious email domains in identity layer (IDE-9612), CIAM-deleted fans in dbt outputs (IDE-9613)
> Tone: Conversational, first-name address, evidence-first, non-prescriptive. "I found something weird, here's the SQL, curious what you think."

```markdown
Hey [First Name] — flagging something I came across during a recent audit that I'd love your eyes on.

[1-2 sentences: what looks off and approximate scale.]

[Evidence table for domain/category breakdowns, OR a single count for simpler findings:]

| [Category] | [Count] | [What it looks like] |
|---|---|---|
| [value] | [N] | [description] |

Here's the SQL [that built the isolation table / that surfaced this]:

```sql
[The source SQL — CTAS if it created an isolation table, or the SELECT that produced the finding.]
-- Result: [N rows / count] as of [YYYY-MM-DD]
```

[Key observation: the concrete "here's the thing I noticed" moment. What does this finding reveal? E.g., a flag that should be TRUE is FALSE, or a field that exists upstream isn't being applied downstream.]

[Light suggestion: 1-2 possible approaches, framed as options not directives. Use "my initial thought is..." or "could this be a case for X vs Y?" Always end with an invitation for the assignee to redirect. If this story is upstream of or depends on another story, call it out here.]

[Closing line deferring to their expertise: "But you know [this layer / these models] far better than I do. Wanted to share what I found and hear your take on the right approach."]
```

**Jira fields for Template F:**
- `issueTypeName`: Story
- `assignee`: The technical lead for that layer — NOT the ticket creator
- `component`: `Fan Data Value Stream` for identity/DE layer; `Analytics Engineering` for dbt/AE layer
- `parent`: Parent epic key
- No AC section, no success metrics, no testing strategy, no stakeholder table

---

## Anti-Patterns to Avoid

These are patterns that should **not** be replicated:

| Anti-pattern | What to write instead |
|---|---|
| `More details to come` | Specific TBD with a discovery spike reference |
| `Placeholder ticket` | Either fully scope the ticket or create a named discovery spike |
| `TBD` alone | `TBD — [Name] to confirm by [date]` |
| AC like "Data is correct" | `Row count matches source within 2% tolerance` |
| AC like "It works" | A specific, testable, observable outcome |
| Adding Success Metrics section | Omit — AC is the deliverable checklist; separate metrics section is redundant |
| Adding Testing Strategy section | Omit — execution detail, not ticket scope |
| Adding Dependencies section | Omit — BLOCKED BY / BLOCKS scaffolding is not needed |
| No stakeholder table | Always include with explicit role assignments |
| Using `db_bronze` or `db_silver` | Use `db_fandata_prd.[schema].[table]` for production, `db_fandata_qa` for QA |
| Alation references of any kind | Never mention Alation in any ticket, AC, or doc section |
| Constructed or guessed URLs | Only include links confirmed to exist; omit rather than guess |
