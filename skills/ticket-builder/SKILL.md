---
name: ticket-builder
description: >-
  Creates Jira tickets and paired Confluence pages for the NBA Fan Data Value
  Stream. Use WHEN asked to create a ticket, epic, story, or Confluence spec
  for any FDP/FEV/FFV/ingest/analytics-engineering/dbt work.
  Applies established patterns: stakeholder confirmation gate, evidence-based
  AC, working group tables, and FDP standards references.
  Triggers: create ticket, new epic, write story, Confluence page, Jira, IDE-,
  spec, ingest, data integration, backfill, FEV epic, analytics engineering,
  dbt model, data quality, migration, data science, ML, propensity model.
---

# Ticket Builder

## Pre-Creation Gate (MANDATORY — do not skip)

Before calling `createJiraIssue` or `createConfluencePage`, you MUST verbally confirm all of the following. Do not proceed until each box is checked:

**[ ] 1. Stakeholders confirmed**
- Named business owner (first + last name)?
- Named technical lead (first + last name)?
- Have they explicitly agreed this work should happen? ("yes they signed off", "X confirmed", etc.)
- What business justification did they give?

**[ ] 2. Work type confirmed**
- Is this an actual executable task (DE work, dbt PR, validation run)?
- Or is it something a stakeholder needs to read/review? → If the latter, route to Confluence or Slack instead. Do NOT create a Jira story.

**[ ] 3. Template confirmed**
- Which template applies (A/B/C/D/E/F)? State it out loud before drafting.
- Does the draft contain any of the following? If yes, remove before creating:
  - `## Testing Strategy` section → DELETE
  - `## Success Metrics` section → DELETE
  - `## Dependencies` / BLOCKED BY / BLOCKS section → DELETE
  - `db_bronze` or `db_silver` naming → REPLACE with `db_fandata_prd`
  - Any Alation references → DELETE
  - Any URLs that weren't explicitly confirmed → DELETE

**Exception — Template F (Investigation / Anomaly Flag):** Skip stakeholder gate and Confluence pairing. These are lightweight DE consultation tickets only.

**Every new Epic must have a paired Confluence page** — create both in the same turn.

---

## Template Selection

Choose the template that matches the work type, then load it from `references/`:

| Work Type | Jira Template | Confluence Template |
|---|---|---|
| New vendor feed / API source / partner ingest | Template A: New Data Integration | Template A: Strategic Initiative |
| Analytics engineering / dbt model / mart / semantic metric | Template B: Analytics Engineering | Template B: Technical Specification |
| Data quality / monitoring / DQ assessment / broken pipeline | Template C: Data Quality Investigation | Template C: Quality Investigation Report |
| Backfill / migration / schema fix / deprecation | Template D: Platform Migration | Template D: Migration Plan |
| Propensity model / segmentation / ML / data science | Template E: Data Science / ML Model | Template E: DS/ML Spec |
| Investigation / anomaly flag — PM surfacing a data finding to a technical lead | Template F: Investigation / Anomaly Flag | *(none — no Confluence page required)* |

Templates live in:
- `references/ticket-templates.md` — Jira ticket templates (A–F, six canonical types)
- `references/confluence-templates.md` — Confluence page templates (A–E, five canonical types)

---

## Jira Ticket — Required Fields

Always populate these via `mcp__plugin_atlassian_atlassian__createJiraIssue`.

**Read these values from `config.local.yaml` (falling back to `config.yaml`) — do not use hardcoded values if config.local.yaml exists:**
- `cloudId` → `atlassian.cloud_id`
- `projectKey` → `atlassian.project_key`
- `default assignee` → `atlassian.default_assignee_account_id`

| Field | Rule |
|---|---|
| `issueTypeName` | Epic / Story / Task / Bug |
| `summary` | Verb-first, ≤70 chars: "Add X", "Fix Y", "Migrate Z" |
| `description` | Use ADF format. Lead with user story. Include AC and working group table. |
| `assignee` | Read from `config.local.yaml → atlassian.default_assignee_account_id` (or ask who to assign). **Template F exception:** assign to the technical lead for that layer — NOT the ticket creator. |
| `components` | Always include at minimum `Fan Data Value Stream`. **Template F exception:** use `Fan Data Value Stream` for identity/DE layer work; use `Analytics Engineering` for dbt/AE layer work. *(These component names are specific to the NBA `IDE` Jira project — they must exist in your project before tickets can be created with them.)* |
| `labels` | Match existing IDE project labels — look them up if unsure |

**Style guide links to include in description (per memory rule `feedback_jira_style_guide_references`):**
- SQL/ingest tickets → link NBA SQL Style Guide
- dbt/analytics-engineering tickets → link dbt Style Guide

---

## Confluence Page — Required Fields

Create via `mcp__plugin_atlassian_atlassian__createConfluencePage`.

Every Epic needs a Confluence page showing:
1. **Business outcome** — what capability this unlocks, for whom
2. **Stakeholder table** — names, roles, confirmation status, business justification
3. **Success metrics** — measurable outcomes, not activities
4. **Timeline** — start → go-live
5. **Strategic alignment** — how it supports Fan Data Value Stream goals

Use templates from `references/confluence-templates.md` — pick the matching type.

---

## Output Format

After creating both artifacts, return:

```
## Created
- **Jira:** [IDE-XXXX](link) — [summary]
- **Confluence:** [Page Title](link) — [space/parent]

## Stakeholders confirmed
- [Name] ([role]) — [approval status]

## Next steps
- [Any outstanding items — assignee, sprint, etc.]
```
