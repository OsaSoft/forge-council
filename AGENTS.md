# AGENTS.md -- forge-council

> Pure-markdown multi-agent orchestration for Claude Code. Twelve specialists,
> three councils, structured 3-round debates. No compiled code -- only markdown
> agent definitions, YAML configuration, shell scripts, and Claude Code skills.

## Build / Install / Verify

No build system, compiler, or bundler. The only "build" is deploying agent
markdown files to `~/.claude/agents/`.

```bash
bash bin/install-agents.sh            # install all agents
bash bin/install-agents.sh --dry-run  # preview without writing
bash bin/install-agents.sh --clean    # clean old agents then reinstall
```

No automated tests, linter, or CI pipeline. Verification is manual per
`VERIFY.md`:

```bash
ls ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher}.md
grep -l "^# synced-from:" ~/.claude/agents/*.md | wc -l   # expect 12
ls skills/*/SKILL.md                                       # expect 4
echo "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}"          # 1=parallel, 0=sequential
```

## Project Structure

```
agents/              # 13 agent definitions (12 rostered + ForensicAgent)
bin/                 # install-agents.sh (standalone deployment)
lib/                 # git submodule -> forge-lib (shell utilities)
skills/              # 4 skill definitions (Council, Demo, DeveloperCouncil, ProductCouncil)
defaults.yaml        # Agent roster + council composition (committed)
config.yaml          # User overrides (gitignored, same structure as defaults)
module.yaml          # Module metadata (name, version, description)
.claude-plugin/      # plugin.json manifest for Claude Code
```

## Agent Markdown Files (`agents/*.md`)

### Frontmatter (YAML between `---` delimiters)

Required keys: `title`, `description`, `claude.name`, `claude.model`,
`claude.description`, `claude.tools`.

```yaml
---
title: Developer
description: Senior developer specialist for implementation quality, patterns, and correctness
claude.name: Developer
claude.model: sonnet
claude.description: "Senior developer specialist -- implementation quality, patterns, correctness. USE WHEN code review, implementation quality, design patterns, refactoring assessment."
claude.tools: Read, Grep, Glob, Bash, Write, Edit
---
```

### Tool assignments by role

| Tools | Agents |
|-------|--------|
| `Read, Grep, Glob` | Architect, Designer, DocumentationWriter, Opponent |
| `Read, Grep, Glob, Bash` | Database, DevOps, SecurityArchitect, ForensicAgent |
| `Read, Grep, Glob, Bash, Write, Edit` | Developer, Tester |
| `Read, Grep, Glob, WebSearch, WebFetch` | Researcher, ProductManager, Analyst |

### Model assignments

All agents use `sonnet` except `Opponent` which uses `opus`.

### Body structure (in order)

1. Blockquote summary (one sentence, ends with "Shipped with forge-council.")
2. `## Role` -- what the agent does
3. `## Expertise` -- bullet list of domain areas
4. `## Personality` (optional) -- only Opponent, Researcher, SecurityArchitect
5. `## Instructions` -- detailed steps with `###` subsections
6. `## Output Format` -- markdown template in a fenced code block
7. `## Constraints` -- bullet list of boundaries and rules

### Constraints section rules

- Every agent ends with: "When working as part of a team, communicate findings
  to the team lead via SendMessage when done"
- Include the honesty clause: "If X is solid, say so -- don't manufacture
  issues/objections/complexity"
- Every critique must include a concrete suggestion

## Skill Files (`skills/*/SKILL.md`)

Frontmatter requires: `name`, `description`, `argument-hint`. Body is numbered
steps (Step 1 through 7/8). All council skills follow: gate check, parse input,
select roster, spawn team, 3 debate rounds, synthesize + teardown, sequential
fallback.

| Keyword | Mode | Behavior |
|---------|------|----------|
| _(none)_ | checkpoint | Pause after Round 1 for user input |
| "autonomous" | autonomous | All 3 rounds without interruption |
| "interactive" | interactive | Pause after every round |
| "quick" | quick | Round 1 only + synthesis |

Key constraints: main session IS the moderator (never spawn one), provide full
context in every prompt, agents must reference others by name in Round 2+,
maximum roster size 7.

## Naming Conventions

| Context | Convention | Examples |
|---------|-----------|---------|
| Agent filenames | `PascalCase.md` | `Developer.md`, `SecurityArchitect.md` |
| `claude.name` | PascalCase, matches filename | `Developer`, `SecurityArchitect` |
| `claude.model` | lowercase short form | `sonnet`, `opus` |
| Skill directories | PascalCase | `Council/`, `DeveloperCouncil/` |
| Skill files | Always `SKILL.md` | `skills/Council/SKILL.md` |
| Shell functions | `lowercase_snake_case` | `fm_value`, `deploy_agent` |
| Shell constants | `UPPER_SNAKE_CASE` | `FORGE_LIB`, `AGENTS_SRC` |
| YAML agent names | PascalCase | `Developer`, `ProductManager` |
| YAML council names | lowercase | `developer`, `generic`, `product` |
| Team names (runtime) | lowercase-kebab | `council`, `dev-council` |

## Shell Scripts

### Style

- Shebang: `#!/usr/bin/env bash`
- Always start with `set -euo pipefail` (except lib scripts that are sourced)
- Resolve paths: `SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Source libraries, don't execute: `source "$FORGE_LIB/frontmatter.sh"`
- Check for required files/dirs before proceeding, `exit 1` with user-friendly message
- Argument parsing via `for arg in "$@"; do case "$arg" in ...`
- Local variables in functions declared with `local`

### forge-lib submodule (`lib/`)

Shared utilities sourced (not executed) by `bin/install-agents.sh`:
- `frontmatter.sh` -- `fm_value file key`, `fm_body file`
- `install-agents.sh` -- `deploy_agent`, `deploy_agents_from_dir`
- `strip-front.sh` -- `strip_front [--keep key1,key2] file.md`

## YAML Configuration

- `defaults.yaml` -- canonical roster and council composition. Do not edit
  unless adding/removing agents from the default lineup.
- `config.yaml` -- user overrides (gitignored). Same structure, only changed fields.
- `module.yaml` -- module metadata. Update `version` on releases.
- Model selection lives in agent frontmatter, NOT in YAML config.
- Two-space indentation, unquoted string values, PascalCase agent names.

## Markdown Style

- Em-dashes (`--`) used extensively in prose and descriptions (not `---`)
- `claude.description` pattern: `"Role summary -- capabilities. USE WHEN triggers."`
- Skill `description` pattern: `"Action -- details. USE WHEN triggers."`
- Blockquotes for one-line summaries
- Fenced code blocks for output format templates
- No trailing whitespace; files end with a newline

## Git Conventions

Conventional Commits: `type: description`. Lowercase, no trailing period, no
scope. Em-dashes in descriptions are fine.

```
feat: add ForensicAgent for PII and secret detection
fix: update forge-lib submodule to GitHub commit
docs: tighten README to match forge-reflect style
```

Types used: `feat`, `fix`, `docs`.
