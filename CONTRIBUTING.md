# Contributing

## Before you change a skill

Skills are prompt files — a poorly worded change can silently break the behavior. Before editing:

1. **Test the current behavior** — invoke the skill and confirm what it does today
2. **Make your change in a branch** — `git checkout -b your-name/skill-name-fix`
3. **Test the new behavior** — invoke the skill again and confirm it does what you intended
4. **Open a PR** — describe what changed and why; include a before/after example if possible

## Adding a new skill

1. Create a folder under `skills/your-skill-name/`
2. Add `SKILL.md` with frontmatter (`name:`, `description:`) — see existing skills for format
3. Add the skill to the routing table in `CLAUDE.md`
4. Add a row to the skill grid in `routing-system.html`
5. Update `install.sh` if the skill needs any special setup
6. Open a PR

## Changing templates

Templates in `skills/ticket-builder/references/` encode 4+ years of ticket-writing patterns. Changes need justification:

- **Removing a section**: explain why it's harmful, not just redundant
- **Adding a section**: confirm it's not in the Anti-Patterns list first
- **Changing DB naming**: `db_fandata_prd` is the correct production naming — do not revert to `db_bronze`/`db_silver`

## Config values

`config.yaml` contains placeholder keys. **Never commit real values** — those belong in `config.local.yaml` which is gitignored.

## Questions

Reach out in `#fan_data_collab` on Slack or open an issue.
