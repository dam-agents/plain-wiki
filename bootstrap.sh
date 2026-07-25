#!/usr/bin/env bash
# Plain Wiki bootstrap.
#
# Installs the plain-wiki conventions into the current workspace: a markdown
# knowledge directory, an operating manual the harness reads every session, and
# the /wiki-onboard command the platform runs to greet the user. No packages,
# no runtime network beyond fetching this repo's own files — the wiki operates
# entirely offline once installed.
#
# Invoked once at Knowledge Base create via:
#   curl -fsSL https://raw.githubusercontent.com/dam-agents/plain-wiki/main/bootstrap.sh | bash
#
# `templates/` in this repo is the single source of truth for the manual and
# the command; this script fetches them rather than embedding copies, so there
# is nothing to keep in sync. Idempotent and non-destructive: it never
# overwrites your notes, and re-running it is a no-op.
#
# `set -euo pipefail` matters: any failed fetch aborts with a non-zero status,
# so the platform retries instead of leaving a half-installed wiki.
set -euo pipefail

# Where to fetch the template files from. Override to test a fork or a branch,
# e.g. PLAIN_WIKI_BASE=https://raw.githubusercontent.com/me/plain-wiki/dev.
BASE="${PLAIN_WIKI_BASE:-https://raw.githubusercontent.com/dam-agents/plain-wiki/main}"

echo "[plain-wiki] setting up in $(pwd)"

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

# --- operating manual -------------------------------------------------------
# Appended to CLAUDE.md (created if absent) under a marker, so we neither
# overwrite an existing manual nor duplicate ours on a re-run.
MARKER="<!-- plain-wiki:managed (do not edit this heading) -->"
if ! grep -qF "$MARKER" CLAUDE.md 2>/dev/null; then
  manual="$(curl -fsSL "$BASE/templates/CLAUDE.md")"
  printf '\n%s\n' "$manual" >> CLAUDE.md
  echo "[plain-wiki] wrote operating manual to CLAUDE.md"
fi

# --- /wiki-onboard command --------------------------------------------------
# Overwrite each run: it is platform-managed, not user-edited.
curl -fsSL "$BASE/templates/.claude/commands/wiki-onboard.md" \
  -o .claude/commands/wiki-onboard.md
echo "[plain-wiki] installed /wiki-onboard"

echo "[plain-wiki] done."
