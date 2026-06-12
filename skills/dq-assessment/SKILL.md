---
name: dq-assessment
description: >-
  Exploratory data quality assessment for NBA FDP Snowflake tables — point it at
  a table (no ticket required) and it profiles what's there. Use WHEN asked to
  assess, audit, or profile a table, or to find anomalies, inconsistencies, or
  "what's wrong with this table." Claude plans which battery tests apply and
  interprets results; Cortex Code CLI executes all SQL; Claude writes the
  findings report. Covers PK integrity, temporal logic, fill rates, ETL audit
  columns, row_hash collisions, value set anomalies, and FDP-specific gotchas
  (epoch-zero dates, fan_id > 0, UNKNOWN category, sentinel values). Produces a
  prioritized P1/P2/P3 findings report with row counts, business impact, and
  recommended actions. Triggers: audit, assess, anomalies, DQ, data quality,
  inconsistencies, weird data, what's wrong with this table, profile.
  Ticket-anchored validation lives in the `uat-validator` skill.
---

# DQ Assessment — NBA Fan Data Platform (Exploratory Mode)

## Core Behavior

**Execution:** Claude plans which battery tests apply to the table's grain/schema and interprets the results. **CoCo (Cortex Code) generates the SQL and the Snowflake warehouse runs it** — never `snow sql`, never a direct connection from Claude. Claude writes the findings report from the returned results. See the execution contract and the model-routing tier policy in `../_shared/dq-battery.md`.

**Scope:** Find inconsistencies and weird anomalies. Do NOT focus on fill rates for first-party data tables (ATTRIBUTES, DWH_* tables) — fill rates are expected to be low and are not findings unless combined with logical inconsistencies.

---

## Test Battery & FDP Gotchas

See `../_shared/dq-battery.md` for the 12-test battery, the FDP-specific gotchas, the execution contract, and execution notes. Apply all applicable tests.

The battery covers PK integrity, temporal ordering, sentinel/epoch-zero dates, ETL audit columns, row_hash uniqueness, categorical value sets, numeric range anomalies, timestamp corruption, FK referential integrity, deleted/suppressed fans, bot/test users, and stale feed gaps — plus the FDP gotchas (fan_id > 0, epoch-zero dates, millisecond timestamps, UNKNOWN category, masked email domains, null-country US fans, and more).

---

## Report Format

Structure:

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
