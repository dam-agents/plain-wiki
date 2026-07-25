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
