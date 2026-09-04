# Plain Wiki

A **DAM Knowledge Base template**: the minimal, no-toolkit wiki. The agent treats
the files in its workspace as knowledge, answers from them, and persists what it
learns as markdown notes in `wiki/`. Pure markdown and conventions — no indexer,
no runtime dependencies, works fully offline once installed.

It is the stripped-down counterpart to [`llm-wiki`](https://github.com/dam-agents/llm-wiki-v2):
same `/wiki-onboard` entry point, none of the machinery.

## How DAM uses it

When a user creates a Knowledge Base with the **Plain Wiki** template, DAM runs
this repo's `bootstrap.sh` once in the fresh agent's workspace (no agent turn),
naming the harness the sandbox runs:

```
curl -fsSL https://raw.githubusercontent.com/dam-agents/plain-wiki/main/bootstrap.sh | PLAIN_WIKI_HARNESS=codex bash
```

## Harnesses

The manual lands in `AGENTS.md`, which Codex and Pi read natively; each selected
harness then gets its own hook onto it and the `/wiki-onboard` command where it
reads commands:

| Harness | Manual | `/wiki-onboard` |
|---|---|---|
| Claude Code | `CLAUDE.md` gains an `@AGENTS.md` import | `.claude/commands/wiki-onboard.md` → `/wiki-onboard` |
| Codex | `AGENTS.md` (native) | `$CODEX_HOME/prompts/wiki-onboard.md` → `/prompts:wiki-onboard` |
| Pi | `AGENTS.md` (native) | `~/.pi/agent/prompts/wiki-onboard.md` → `/wiki-onboard` |
| Bob | `~/.bob/rules/plain-wiki.md` points at the workspace `AGENTS.md` | none — the manual's Onboarding rule maps the bare message |

`PLAIN_WIKI_HARNESS` takes a comma/space-separated list of `claude-code`,
`codex`, `pi`, `bob`, or `all`; unset, the bootstrap wires every harness CLI it
finds on `PATH`, else `claude-code`. The workspace copy under
`.claude/commands/` is installed for every harness — it is the fallback the
manual points harnesses without command files at.

## Layout

- [`bootstrap.sh`](bootstrap.sh) — the installer. Creates the directories, seeds
  `wiki/index.md`, appends the operating manual to `AGENTS.md`, installs the
  `/wiki-onboard` command, and wires each selected harness (table above). It
  **fetches the manual and the command from `templates/` in this repo** rather
  than embedding copies, so `templates/` is the single source of truth — there
  is nothing to keep in sync.
- [`templates/AGENTS.md`](templates/AGENTS.md) — the operating manual the agent
  reads every session (layout, note format, the ingest → answer → maintain →
  document loop, the shape of the usage guide, and the onboarding rule for
  harnesses without command files).
- [`templates/commands/wiki-onboard.md`](templates/commands/wiki-onboard.md)
  — the `/wiki-onboard` command DAM runs as the opening turn of a fresh KB to
  greet the user.

To change the wiki's behaviour, edit the files under `templates/`; `bootstrap.sh`
picks them up on the next install.

## Contract with the platform

Every DAM KB template's bootstrap **must install a `/wiki-onboard` command** — the
platform runs it as a fresh KB's opening turn to greet the user.

## Versioning

The platform installs from `main`, so a push to `main` takes effect for every
**new** Knowledge Base immediately (existing ones are not re-bootstrapped). There
is no pinned release yet; if the platform later pins a tag or commit, update the
URL in DAM's `install-command.ts` in lockstep.

## Develop / test

`bootstrap.sh` is self-checking (`set -euo pipefail`) and idempotent. To try it in
a throwaway directory, pointing at your own fork/branch:

```sh
mkdir /tmp/pw && cd /tmp/pw
PLAIN_WIKI_BASE=https://raw.githubusercontent.com/<you>/plain-wiki/<branch> \
  PLAIN_WIKI_HARNESS=all \
  bash <(curl -fsSL https://raw.githubusercontent.com/<you>/plain-wiki/<branch>/bootstrap.sh)
find . -type f          # AGENTS.md, CLAUDE.md, wiki/index.md, .claude/commands/wiki-onboard.md
ls ~/.codex/prompts ~/.pi/agent/prompts ~/.bob/rules
bash <(curl ...)        # re-run: should be a no-op, no duplicate manual block
```

A local checkout works too: `PLAIN_WIKI_BASE=file:///path/to/plain-wiki`.

## License

[MIT](LICENSE).
