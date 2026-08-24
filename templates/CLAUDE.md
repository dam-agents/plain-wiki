<!-- plain-wiki:managed (do not edit this heading) -->
# Plain Wiki

You maintain a plain-text knowledge wiki in this workspace. It is pure markdown —
no tools or scripts beyond reading, searching, and writing files.

## Layout
- `wiki/` — your memory. One atomic note per topic, kebab-case filename
  (e.g. `billing-webhooks.md`). Keep notes small and focused.
- `wiki/index.md` — the map of the wiki. Keep it in sync with the notes.
- `wiki/USAGE_GUIDE.md` — the usage guide for a reader arriving at this wiki
  cold. Not a note; keep it out of the index.
- `sources/` — raw input material the user provides. Treat it as evidence, not
  memory: the wiki is where durable knowledge lives.

## Note format
Each note in `wiki/` has:
- an `# H1` title,
- a one-line summary directly under the title,
- the body — concise and factual,
- a `Related:` line linking sibling notes, e.g. `[other-note](other-note.md)`,
- a `Sources:` line naming the file(s) or conversation the note came from.

## Usage guide format
`wiki/USAGE_GUIDE.md` is markdown, written for a reader who has never seen this
wiki — not for the user. Cover three things:
- **What this knowledge base is about** — the subject matter and its edges, in a
  couple of sentences, so the reader can tell whether an answer is likely to be
  in here at all.
- **How it is organised** — one note per topic as a markdown file in `wiki/`,
  `wiki/index.md` as the map to start from, `sources/` as the raw material the
  notes were drawn from, and the topic groupings this wiki actually has.
- **How to navigate it** — read `wiki/index.md` first, follow its links and the
  `Related:` lines between notes, grep `wiki/` for terms the index doesn't name,
  and read the notes as the answer with `sources/` as backing evidence.

Describe the groupings that are really there, and name a few notes by filename
as entry points. Never write down a note count, or anything else that turns
false the moment a note is added. Only the first 8000 characters are read, so
stay under that and put the essentials first.

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

**Document.** Keep `wiki/USAGE_GUIDE.md` current: it is the usage guide for
someone arriving at this wiki cold, with nothing else to go on. Whenever you
build or reshape the wiki — an ingest, notes added, renamed or removed, anything
that changes `wiki/index.md` — refresh it in the same pass, unasked.

## Principles
- The wiki is the source of truth; `sources/` is raw material.
- Prefer updating a note over creating a new one.
- Every claim should trace to a source.
- Small, linked notes beat large dumps.
