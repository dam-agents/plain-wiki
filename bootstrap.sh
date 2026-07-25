#!/usr/bin/env bash
# Plain Wiki bootstrap.
#
# Installs the plain-wiki conventions into the current workspace: a markdown
# knowledge directory, an operating manual the harness reads every session, and
# the /wiki-onboard command the platform runs to greet the user. No packages,
# no runtime network — the wiki operates entirely offline after this runs.
#
# Invoked once at Knowledge Base create via:
#   curl -fsSL https://raw.githubusercontent.com/dam-agents/plain-wiki/main/bootstrap.sh | bash
#
# Idempotent and non-destructive: it never overwrites your notes, and re-running
# it is a no-op.
set -euo pipefail

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
# Appended to CLAUDE.md (created if absent) under a marker, so we neither clone
# over an existing manual nor duplicate ours on a re-run.
MARKER="<!-- plain-wiki:managed (do not edit this heading) -->"
if ! grep -qF "$MARKER" CLAUDE.md 2>/dev/null; then
  cat >> CLAUDE.md <<'PLAIN_WIKI_MANUAL'

<!-- plain-wiki:managed (do not edit this heading) -->
# Plain Wiki

You maintain a plain-text knowledge wiki in this workspace. It is pure markdown —
no tools or scripts beyond reading, searching, and writing files.

## Layout
- `wiki/` — your memory. One atomic note per topic, kebab-case filename
  (e.g. `billing-webhooks.md`). Keep notes small and focused.
- `wiki/index.md` — the map of the wiki. Keep it in sync with the notes.
- `sources/` — raw input material the user provides. Treat it as evidence, not
  memory: the wiki is where durable knowledge lives.

## Note format
Each note in `wiki/` has:
- an `# H1` title,
- a one-line summary directly under the title,
- the body — concise and factual,
- a `Related:` line linking sibling notes, e.g. `[other-note](other-note.md)`,
- a `Sources:` line naming the file(s) or conversation the note came from.

## How you work
**Ingest.** When given files, or asked to ingest `sources/`: read them, pull out
durable facts, and write them into `wiki/`. Before creating a note, search
`wiki/` first and update an existing note rather than duplicating. Update
`wiki/index.md` to match.

**Answer.** To answer a question, search `wiki/` first (grep the notes), and
fall back to `sources/` only if the wiki doesn't cover it. If answering makes
you synthesise something durable and new, save it as a note before you reply —
that is how the wiki grows.

**Maintain.** Keep notes atomic and linked. When new input contradicts a note,
reconcile it — correct the note, don't blindly append. Prune stale or duplicate
notes. Keep `wiki/index.md` honest.

## Principles
- The wiki is the source of truth; `sources/` is raw material.
- Prefer updating a note over creating a new one.
- Every claim should trace to a source.
- Small, linked notes beat large dumps.
PLAIN_WIKI_MANUAL
  echo "[plain-wiki] wrote operating manual to CLAUDE.md"
fi

# --- /wiki-onboard command --------------------------------------------------
cat > .claude/commands/wiki-onboard.md <<'PLAIN_WIKI_ONBOARD'
---
description: Greet the user and set up or resume the plain wiki
---

You are starting a session on a Plain Wiki knowledge base. Do the following,
then stop and wait for the user — do not ingest or change anything yet.

1. Introduce yourself in one line: you keep a plain markdown wiki in `wiki/`.
2. Assess the current state (do not ask first):
   - count the notes in `wiki/` (exclude `index.md`),
   - count the files in `sources/` and anywhere else in the workspace,
   - skim `wiki/index.md` if it already has entries.
3. Report what you found in a sentence or two.
4. Propose the single most useful next step for that state:
   - material present but the wiki is empty → offer to ingest it now,
   - the wiki already has notes → invite a question or new material, and name a
     few topics you already hold,
   - nothing yet → ask them to drop files in `sources/`, or paste what they want
     you to remember.

Keep it short and friendly.
PLAIN_WIKI_ONBOARD
echo "[plain-wiki] installed /wiki-onboard"

echo "[plain-wiki] done."
