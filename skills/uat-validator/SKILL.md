---
name: uat-validator
description: >-
  Ticket-anchored two-phase QA skill. Reads a Jira ticket + Snowflake table
  name, builds a test plan validating the table against the ticket's acceptance
  criteria (Phase 1), then outputs a Cortex goal string to run (Phase 2). Use
  WHEN validating or signing off a Snowflake object against a Jira ticket.
  Triggers: UAT, validate against ticket, QA against acceptance criteria,
  sign-off, test this table against the ticket. NOTE: exploratory or standalone
  DQ assessment with NO ticket lives in the `dq-assessment` skill.
---

# uat-validator

## Invocation

Provide two things:
1. A Jira ticket key (e.g. `IDE-9374`)
2. A fully-qualified Snowflake table or view name (e.g. `DB_FANANALYTICS.YOUR_DEV_SCHEMA.TABLE_NAME`)

## Phase 1 — Build the Test Plan (Claude)

### Step 1: Read the Jira ticket

Use `mcp__plugin_atlassian_atlassian__getJiraIssue` with the provided ticket key.
- Discover `cloudId` first with `mcp__plugin_atlassian_atlassian__getAccessibleAtlassianResources` if not already known.
- Extract: summary, description, acceptance criteria, any column names or business rules mentioned.

### Step 2: Confirm column metadata (via Cortex)

Claude never runs SQL directly — column introspection goes through Cortex Code CLI like every other query. You have two options:
- **Defer to Phase 2 (default):** column introspection happens at runtime inside the Cortex goal. Cortex reads `information_schema.columns` to confirm column names before building the test queries, so Phase 1 can proceed on the ticket and table name alone.
- **Confirm now:** if you need column names to shape the test plan, ask Cortex to introspect them — never query Snowflake from this session.

Whichever option you use, the column lookup is a Cortex-executed query, not a `snow sql` call.

### Step 3: Build the test plan

Produce a numbered list of checks. For each check, state:
- What is being tested
- What the expected result is (exact value, range, or condition)
- Whether it came from the ticket (`[FROM TICKET]`) or was inferred (`[INFERRED]`)

**Standard checks always included (mark `[INFERRED]` unless ticket overrides):**

The standard FDP integrity checks — PK uniqueness, null checks, sentinel/epoch dates, ETL audit columns, categorical value sets, numeric range anomalies, etc. — are defined in `../_shared/dq-battery.md`. Pull the ones applicable to the table's grain and schema and add them as `[INFERRED]` checks rather than re-listing SQL here. At minimum, always include:
1. Row count > 0
2. No column is 100% NULL
3. Primary key (or grain) is unique — infer grain from table name and ticket context
4. No unexpected negative values in revenue or count columns
5. All columns mentioned in the ticket exist on the table

**Ticket-driven checks (mark `[FROM TICKET]`):**
- Any explicit acceptance criterion → convert to a SQL-testable assertion
- Any business rule stated in the description → convert to assertion
- Any named column → add to expected-columns check
- Any row count or value expectation → add as exact check

### Step 4: Show the test plan

Present the numbered list. Label each check clearly. Ask: "Does this test plan look right? Say 'go' to proceed or edit any checks." Wait for approval before proceeding to Phase 2.

## Phase 2 — Output the Cortex Goal String

Once the test plan is approved, load the Cortex goal template from:
`references/cortex-phase2-template.md`

Fill in:
- `{{TABLE_FQTN}}` — the fully-qualified table name provided
- `{{TICKET_KEY}}` — the Jira ticket key
- `{{TEST_PLAN}}` — the numbered test plan from Phase 1 (formatted as a plain list)
- `{{REPORT_DATE}}` — today's date in YYYY-MM-DD format
- `{{REPORT_PATH}}` — `~/Documents/uat-reports/{{TICKET_KEY}}_{{TABLE}}_{{REPORT_DATE}}.html`

Output the filled goal string in a code block and say:
> "Paste this into Cortex to run Phase 2."

## Notes

- Always use Atlassian MCP for Jira — never prompt for CLI auth or API keys.
- Cortex writes all SQL. Claude never writes SQL checks.
- Report always goes to `~/Documents/uat-reports/`.
- If the ticket has zero acceptance criteria, apply all standard checks and flag the whole plan as `[INFERRED]`.
