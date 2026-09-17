#!/usr/bin/env bash
# Plain Wiki bootstrap.
#
# Installs the plain-wiki conventions into the current workspace: a markdown
# knowledge directory, an operating manual the harness reads every session, and
# the /wiki-onboard command the platform runs to greet the user. No packages,
# and no network at all when run from a checkout of this repo — the wiki
# operates entirely offline once installed.
#
# Invoked once at Knowledge Base create. The platform seeds this repo into the
# fresh agent's workspace at a pinned commit and runs, from that checkout:
#   bash bootstrap.sh
# From anywhere else it still works over the network:
#   curl -fsSL https://raw.githubusercontent.com/dam-agents/plain-wiki/main/bootstrap.sh | bash
#
# The manual lands in AGENTS.md (read natively by Codex and Pi); each selected
# harness then gets its own hook onto it — CLAUDE.md imports it for Claude Code,
# a rules file points at it for Bob — and the /wiki-onboard command lands where
# that harness reads commands. Which harnesses get wired, first match wins:
#   PLAIN_WIKI_HARNESS   comma/space-separated: claude-code codex pi bob all
#   PLATFORM_HARNESS     the family the platform's harness image runs (set in the image)
#   autodetect           every harness CLI found on PATH (claude, codex, pi, bob)
#   fallback             claude-code
#
# `templates/` in this repo is the single source of truth for the manual and
# the command. Run from a checkout, the script reads them from that checkout;
# run over the network, it fetches them — either way nothing is embedded here,
# so there is nothing to keep in sync. Idempotent and non-destructive: it never
# overwrites your notes, and re-running it is a no-op.
#
# `set -euo pipefail` matters: any failed fetch aborts with a non-zero status,
# so the platform retries instead of leaving a half-installed wiki.
set -euo pipefail

# Where the template files come from: PLAIN_WIKI_BASE when set (a fork or a
# branch, e.g. https://raw.githubusercontent.com/me/plain-wiki/dev, or another
# checkout as file:///path/to/plain-wiki), else the checkout this script runs
# from, else the published main branch.
SELF="${BASH_SOURCE[0]:-}"
if [ -z "${PLAIN_WIKI_BASE:-}" ] && [ -n "$SELF" ] && [ -f "$SELF" ]; then
  SELF_DIR="$(cd "$(dirname "$SELF")" && pwd)"
  if [ -f "$SELF_DIR/templates/AGENTS.md" ]; then
    PLAIN_WIKI_BASE="file://$SELF_DIR"
  fi
fi
BASE="${PLAIN_WIKI_BASE:-https://raw.githubusercontent.com/dam-agents/plain-wiki/main}"
KNOWN_HARNESSES="claude-code codex pi bob"
MARKER="<!-- plain-wiki:managed (do not edit this heading) -->"

detect_harnesses() {
  local found=""
  command -v claude >/dev/null 2>&1 && found="$found claude-code"
  command -v codex  >/dev/null 2>&1 && found="$found codex"
  command -v pi     >/dev/null 2>&1 && found="$found pi"
  command -v bob    >/dev/null 2>&1 && found="$found bob"
  echo "${found# }"
}

HARNESSES="${PLAIN_WIKI_HARNESS:-${PLATFORM_HARNESS:-}}"
HARNESSES="${HARNESSES//,/ }"
if [ "$HARNESSES" = "all" ]; then
  HARNESSES="$KNOWN_HARNESSES"
elif [ -z "$HARNESSES" ]; then
  HARNESSES="$(detect_harnesses)"
  [ -n "$HARNESSES" ] || HARNESSES="claude-code"
fi
for h in $HARNESSES; do
  case " $KNOWN_HARNESSES " in
    *" $h "*) ;;
    *) echo "[plain-wiki] unknown harness \"$h\" (known: $KNOWN_HARNESSES, all)" >&2; exit 1 ;;
  esac
done

echo "[plain-wiki] setting up in $(pwd) for: $HARNESSES"

mkdir -p wiki sources .claude/commands

# --- wiki/index.md (the map) — only if absent -------------------------------
if [ ! -f wiki/index.md ]; then
  cat > wiki/index.md <<'PLAIN_WIKI_INDEX'
# Wiki index

_The map of this wiki. Every note lives in `wiki/` as its own markdown file;
keep this index in sync as notes are added, renamed, or removed._

<!-- Group links by topic, e.g.
## Billing
- [billing-webhooks](billing-webhooks.md) — how inbound webhooks are verified
-->
PLAIN_WIKI_INDEX
  echo "[plain-wiki] created wiki/index.md"
fi

# --- operating manual → AGENTS.md -------------------------------------------
# Appended under a marker (file created if absent), so we neither overwrite an
# existing manual nor duplicate ours on a re-run. Some images ship AGENTS.md
# as a symlink to a read-only file — materialize it first so the append lands.
if [ -L AGENTS.md ]; then
  cp -L AGENTS.md AGENTS.md.plain-wiki && mv AGENTS.md.plain-wiki AGENTS.md
fi
if ! grep -qF "$MARKER" AGENTS.md 2>/dev/null; then
  manual="$(curl -fsSL "$BASE/templates/AGENTS.md")"
  printf '\n%s\n' "$manual" >> AGENTS.md
  echo "[plain-wiki] wrote operating manual to AGENTS.md"
fi

# --- /wiki-onboard command --------------------------------------------------
# Overwrite each run: it is platform-managed, not user-edited. The workspace
# copy under .claude/commands/ is installed for every harness — Claude Code
# reads it natively and the manual points harnesses without command files at it.
curl -fsSL "$BASE/templates/commands/wiki-onboard.md" -o .claude/commands/wiki-onboard.md
echo "[plain-wiki] installed /wiki-onboard (.claude/commands/)"

# --- per-harness wiring -----------------------------------------------------
for h in $HARNESSES; do
  case "$h" in
    claude-code)
      # Project CLAUDE.md imports the manual rather than duplicating it.
      if ! grep -qF "$MARKER" CLAUDE.md 2>/dev/null; then
        printf '\n%s\n@AGENTS.md\n' "$MARKER" >> CLAUDE.md
        echo "[plain-wiki] claude-code: CLAUDE.md imports AGENTS.md"
      fi
      ;;
    codex)
      prompts="${CODEX_HOME:-$HOME/.codex}/prompts"
      mkdir -p "$prompts"
      cp -f .claude/commands/wiki-onboard.md "$prompts/wiki-onboard.md"
      echo "[plain-wiki] codex: AGENTS.md is read natively; command at $prompts (/prompts:wiki-onboard)"
      ;;
    pi)
      mkdir -p "$HOME/.pi/agent/prompts"
      cp -f .claude/commands/wiki-onboard.md "$HOME/.pi/agent/prompts/wiki-onboard.md"
      echo "[plain-wiki] pi: AGENTS.md is read natively; command at ~/.pi/agent/prompts"
      ;;
    bob)
      mkdir -p "$HOME/.bob/rules"
      cat > "$HOME/.bob/rules/plain-wiki.md" <<BOB_RULE
$MARKER
The workspace \`$(pwd)\` is a knowledge base. Read \`$(pwd)/AGENTS.md\` at the
start of every session — it is the wiki operating manual — and follow it,
including its onboarding rule for the \`/wiki-onboard\` message.
BOB_RULE
      echo "[plain-wiki] bob: rules file at ~/.bob/rules/plain-wiki.md"
      ;;
  esac
done

echo "[plain-wiki] done."
