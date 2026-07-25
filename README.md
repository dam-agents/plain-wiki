# Plain Wiki

A **DAM Knowledge Base template**: the minimal, no-toolkit wiki. The agent treats
the files in its workspace as knowledge, answers from them, and persists what it
learns as markdown notes in `wiki/`. Pure markdown and conventions — no indexer,
no runtime dependencies, works fully offline.

It is the stripped-down counterpart to [`llm-wiki`](https://github.com/dam-agents/llm-wiki-v2):
same `/wiki-onboard` entry point, none of the machinery.

## How DAM uses it

When a user creates a Knowledge Base with the **Plain Wiki** template, DAM runs
this repo's `bootstrap.sh` once in the fresh agent's workspace (no agent turn):

```
curl -fsSL https://raw.githubusercontent.com/dam-agents/plain-wiki/main/bootstrap.sh | bash
```

`bootstrap.sh` is self-contained (it embeds the manual and the command below), so
that single fetch is the only network access required.

## What bootstrap installs

- `wiki/` + `wiki/index.md` — the markdown memory and its map.
- `sources/` — where raw input files go.
- `CLAUDE.md` — the operating manual (appended under a marker; never clobbers an
  existing one). Canonical copy: [`templates/CLAUDE.md`](templates/CLAUDE.md).
- `.claude/commands/wiki-onboard.md` — the `/wiki-onboard` command DAM auto-runs
  to greet the user. Canonical copy:
  [`templates/.claude/commands/wiki-onboard.md`](templates/.claude/commands/wiki-onboard.md).

## Contract with the platform

Every DAM KB template's bootstrap **must install a `/wiki-onboard` command** — the
platform runs it as the opening turn of a fresh KB to greet the user. Keep the
files under `templates/` and `bootstrap.sh` in sync (bootstrap embeds copies).
