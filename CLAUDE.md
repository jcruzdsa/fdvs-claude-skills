# Global Instructions for Claude Code — fdvs-personal Plugin

## Skill Routing

Use the right skill before responding. These skills are part of this plugin:

| Task | Skill |
|---|---|
| Jira tickets / Confluence specs | `ticket-builder` |
| DQ assessment on a Snowflake table | `dq-assessment` |
| PR review (FEV/FFV pipeline) | `fev-pr-review` |
| Code review against FDVS conventions | `code-qa-sentry` |
| UAT validation | `uat-validator` |
| Snowflake SQL development | `snowflake-sql` *(routes to Cortex Code CLI — do not execute SQL directly in Claude)* |

For all other tasks (planning, brainstorming, debugging, strategy, optimization, committing), use the `compound-engineering:ce-*` skills from the compound-engineering plugin.

## External Service Integration

**CRITICAL: Always use MCP tools instead of direct API calls.**

When working with external services that have MCP integrations:

### Jira/Atlassian

1. ✅ **DO use MCP tools**: `mcp__plugin_atlassian_atlassian__*` tools
   - `searchJiraIssuesUsingJql` — Search for issues
   - `getJiraIssue` — Get issue details
   - `createJiraIssue` — Create new issues
   - `editJiraIssue` — Update existing issues
   - `addCommentToJiraIssue` — Add comments
   - `transitionJiraIssue` — Change issue status
   - `getConfluencePage` — Read Confluence pages
   - `createConfluencePage` — Create Confluence pages

2. ❌ **DO NOT make direct API calls**:
   - Never use curl, fetch, or HTTP methods to call Jira REST endpoints
   - Never construct manual API requests to Atlassian services

### Other MCP Services

Apply the same principle to all MCP-enabled services — check for `mcp__plugin_*` tools first.

## Plugin Configuration

Configurable values (Atlassian cloud ID, project key, account ID) are in `config.yaml` at the plugin root.
Team members should copy it to `config.local.yaml` and fill in their own values.
