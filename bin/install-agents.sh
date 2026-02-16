#!/usr/bin/env bash
# install-agents.sh — Deploy council agents to ~/.claude/agents/
#
# For standalone forge-council installations (not using forge-core).
# If you're using forge-core, sync-agents.sh handles this automatically.
#
# Usage:
#   bin/install-agents.sh              # install all council agents
#   bin/install-agents.sh --dry-run    # show what would be installed
#   bin/install-agents.sh --clean      # remove council agents before reinstalling

set -euo pipefail

SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_ROOT="$(builtin cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_SRC="$MODULE_ROOT/agents"
AGENTS_DST="${HOME}/.claude/agents"

# Resolve forge-lib: forge-core env > local clone
FORGE_LIB="${FORGE_LIB:-$MODULE_ROOT/lib}"
if [ ! -d "$FORGE_LIB" ] || [ ! -f "$FORGE_LIB/frontmatter.sh" ]; then
  echo "forge-lib not found at $FORGE_LIB"
  echo "Run: git clone https://github.com/<user>/forge-lib.git $MODULE_ROOT/lib"
  echo "See INSTALL.md for details."
  exit 1
fi

source "$FORGE_LIB/frontmatter.sh"
source "$FORGE_LIB/install-agents.sh"

DRY_RUN=""
CLEAN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN="--dry-run" ;;
    --clean)   CLEAN=true ;;
    -h|--help)
      echo "Usage: install-agents.sh [--dry-run] [--clean]"
      echo "  --dry-run  Show what would be installed without writing files"
      echo "  --clean    Remove council agents before reinstalling"
      exit 0
      ;;
  esac
done

if [ ! -d "$AGENTS_SRC" ]; then
  echo "Error: agents directory not found at $AGENTS_SRC"
  exit 1
fi

mkdir -p "$AGENTS_DST"

# Clean previously installed council agents
if $CLEAN; then
  for f in "$AGENTS_DST"/council-*.md; do
    [ -f "$f" ] || continue
    if grep -q "^# synced-from:" "$f" 2>/dev/null; then
      if [ -n "$DRY_RUN" ]; then
        echo "[dry-run] Would remove: $(basename "$f")"
      else
        command rm "$f"
        echo "Removed: $(basename "$f")"
      fi
    fi
  done
fi

deploy_agents_from_dir "$AGENTS_SRC" "$AGENTS_DST" $DRY_RUN
