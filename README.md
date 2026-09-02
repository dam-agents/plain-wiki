# Plain Wiki

A **DAM Knowledge Base template**: the minimal, no-toolkit wiki. The agent treats
the files in its workspace as knowledge, answers from them, and persists what it
learns as markdown notes in `wiki/`. Pure markdown and conventions — no indexer,
no runtime dependencies, works fully offline once installed.

It is the stripped-down counterpart to [`llm-wiki`](https://github.com/dam-agents/llm-wiki-v2):
same `/wiki-onboard` entry point, none of the machinery.

## How DAM uses it

When a user creates a Knowledge Base with the **Plain Wiki** template, DAM runs
this repo's `bootstrap.sh` once in the fresh agent's workspace (no agent turn):

```
curl -fsSL https://raw.githubusercontent.com/dam-agents/plain-wiki/main/bootstrap.sh | bash
```

## Layout

- [`bootstrap.sh`](bootstrap.sh) — the installer. Creates the directories, seeds
  `wiki/index.md`, appends the operating manual to `CLAUDE.md`, and installs the
  `/wiki-onboard` command. It **fetches the manual and the command from
  `templates/` in this repo** rather than embedding copies, so `templates/` is
  the single source of truth — there is nothing to keep in sync.
- [`templates/CLAUDE.md`](templates/CLAUDE.md) — the operating manual the agent
  reads every session (layout, note format, the ingest → answer → maintain →
  document loop, and the shape of the usage guide).
- [`templates/.claude/commands/wiki-onboard.md`](templates/.claude/commands/wiki-onboard.md)
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
  bash <(curl -fsSL https://raw.githubusercontent.com/<you>/plain-wiki/<branch>/bootstrap.sh)
find . -type f          # CLAUDE.md, wiki/index.md, .claude/commands/wiki-onboard.md
bash <(curl ...)        # re-run: should be a no-op, no duplicate manual block
```

## License

[MIT](LICENSE).
