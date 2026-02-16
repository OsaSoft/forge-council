# forge-council

Multi-agent council orchestration for Claude Code. Spawns specialist teams that review, design, and debug from independent perspectives using [agent teams](https://code.claude.com/docs/en/agent-teams).

## Councils

### Developer Council (`/DeveloperCouncil`)

Convenes 2-5 specialist agents for multi-perspective software development:

| Role | Agent | Model | Focus |
|------|-------|-------|-------|
| Dev | `council-dev` | sonnet | Implementation quality, patterns, correctness |
| DB | `council-db` | sonnet | Schema design, query performance, migrations |
| Ops | `council-ops` | sonnet | CI/CD, deployment, monitoring, reliability |
| Docs | `council-docs` | haiku | API docs, READMEs, developer experience |
| QA | `council-qa` | sonnet | Test strategy, coverage, edge cases, regression |

The main Claude session acts as team lead — selects relevant specialists, spawns them, creates tasks, and synthesizes findings.

## Prerequisites

Enable agent teams (experimental):

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this flag, the skill falls back to sequential subagent calls.

## Installation

### As part of forge-core

Already registered. Run `sync-agents.sh` to deploy council agents:

```bash
Hooks/sync-agents.sh
```

### Standalone

```bash
bash bin/install-agents.sh
```

## Configuration

`defaults.yaml` defines the role roster per council type. Override in `config.yaml` (gitignored).

Model selection lives in agent frontmatter (`agents/*.md`). To change a model, edit the agent file and re-run the agent sync.

## Usage

```
/DeveloperCouncil Review the authentication module for security and correctness
/DeveloperCouncil full council — Evaluate the database migration strategy
/DeveloperCouncil Should we use WebSockets or SSE for real-time updates?
```

The skill selects relevant specialists based on the task. Say "full council" to spawn all 5.
