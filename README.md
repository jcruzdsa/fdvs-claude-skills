# FDVS Claude Skills

A collection of Claude Code skills for Fan Data Value Stream (FDVS) work at the NBA — Jira/Confluence ticket creation, Snowflake SQL development, data quality assessments, UAT validation, and code QA.

> **FDVS** (Fan Data Value Stream) is the NBA's cross-functional data team responsible for fan data ingestion, the Fan Data Platform (FDP), analytics engineering, and the models and pipelines that power fan engagement insights. [Learn more →](https://nba.atlassian.net/wiki/x/XoBgRw)

---

## Why this exists

After 4+ years on the Fan Data Value Stream, I found myself answering the same questions repeatedly: *Which Jira template do we use for a new vendor feed? What fields does a DQ investigation ticket need? How do we structure a dbt model ticket?*

I built these skills to encode that institutional knowledge — ticket patterns, SQL conventions, review checklists — into Claude Code so the team doesn't have to rediscover it every time. A ticket that used to take 20–30 minutes of thinking now takes 2–3 minutes of reviewing. A DQ assessment that required manually running 12 queries can be kicked off with a single skill invocation.

This repo makes those tools available to anyone on the team doing similar FDVS work.

---

## Skills

| Skill | What it does |
|---|---|
| `ticket-builder` | Creates Jira tickets and Confluence pages using 6 canonical FDVS templates (ingest, AE, DQ, migration, DS/ML, investigation) |
| `snowflake-sql` | Snowflake SQL development — routes SQL execution to Cortex Code CLI |
| `dq-assessment` | Exploratory, standalone data quality battery on an FDP table (no ticket required): 12 tests, P1/P2/P3 findings |
| `uat-validator` | Validates a table against a Jira ticket's acceptance criteria — pass/fail checklists and sign-off tracking |
| `code-qa-sentry` | QA review when tickets close or branches merge, checked against FDVS conventions |

---

## Two-engine model

This plugin is built for a two-engine workflow:

| Engine | Role |
|---|---|
| **Claude** | Plan, think, review, write tickets/docs, brainstorm, debug strategy |
| **Cortex Code CLI** | Write and run Snowflake SQL, build and iterate on Streamlit apps, execute dbt |

The `snowflake-sql` skill routes SQL tasks to Cortex — Claude does not execute SQL directly.

---

## Install

```bash
git clone https://github.com/jcruzdsa/fdvs-claude-skills.git
cd fdvs-claude-skills
bash install.sh
```

`install.sh` symlinks the plugin and each skill into `~/.claude/`. Restart Claude Code after running it.

---

## Configure

Copy the config template and fill in your values:

```bash
cp config.yaml config.local.yaml
```

Edit `config.local.yaml`:

```yaml
atlassian:
  cloud_id: "your-cloud-id-here"       # Jira cloud ID
  project_key: "IDE"                    # Jira project key
  default_assignee_account_id: "your-account-id-here"
```

`config.local.yaml` is gitignored — your credentials stay local.

---

## Routing

Skills are invoked via slash commands in Claude Code. See `routing-system.html` for the full visual routing guide (open it in a browser).

Quick reference:

| Task | Skill |
|---|---|
| Jira ticket or Confluence page | `/ticket-builder` |
| Snowflake SQL | `/snowflake-sql` |
| Exploratory DQ assessment (no ticket) | `/dq-assessment` |
| UAT against a Jira ticket | `/uat-validator` |
| Code QA on merge | `/code-qa-sentry` |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add skills, propose templates, or report issues.
