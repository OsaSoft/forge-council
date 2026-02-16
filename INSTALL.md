# Installation

## As part of forge-core

Already registered. Deploy council agents:

```bash
Hooks/sync-agents.sh
```

Restart Claude Code for agents to be available. forge-lib is provided by the parent project via `FORGE_LIB` env var — the module's own `lib/` submodule is not used when running inside forge-core.

## Standalone

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/<user>/forge-council.git
```

Or if already cloned:

```bash
git submodule update --init
```

This checks out [forge-lib](https://github.com/<user>/forge-lib) into `lib/`, providing shared utilities for agent deployment.

### 2. Deploy agents

```bash
bin/install-agents.sh
```

This reads agent files from `agents/` and installs them to `~/.claude/agents/`.

Use `--dry-run` to preview without writing, `--clean` to remove existing council agents first.

### 3. Enable agent teams

Add to `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without this flag, `/DeveloperCouncil` falls back to sequential subagent calls.

### 4. Restart Claude Code

Agents require a session restart to be discovered.

## Updating

```bash
git pull --recurse-submodules    # update module + forge-lib
bin/install-agents.sh            # re-deploy agents
```
