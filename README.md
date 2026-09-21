# Plain Wiki

A **DAM Knowledge Base template**: the minimal, no-toolkit wiki. The agent treats
the files in its workspace as knowledge, answers from them, and persists what it
learns as markdown notes in `wiki/`. Pure markdown and conventions — no indexer,
no runtime dependencies, works fully offline once installed.

It is the stripped-down counterpart to [`llm-wiki`](https://github.com/dam-agents/llm-wiki-v2):
same first-session onboarding, none of the machinery.

## How DAM uses it

When a user creates a Knowledge Base with the **Plain Wiki** kit, DAM seeds this
repo into the fresh agent's workspace at the commit its catalog resolved and
runs, from that checkout and with no agent turn:

```
bash bootstrap.sh
```

Run from a checkout, the bootstrap reads `templates/` from it, so nothing is
fetched at install. The harness image names the harness the sandbox runs in
`PLATFORM_HARNESS`, and the bootstrap reads that.

## Harnesses

The manual lands in `AGENTS.md`, which Codex and Pi read natively; each other
harness gets its own hook onto it:

| Harness | Manual |
|---|---|
| Claude Code | `CLAUDE.md` gains an `@AGENTS.md` import |
| Codex | `AGENTS.md` (native) |
| Pi | `AGENTS.md` (native) |
| Bob | `~/.bob/rules/plain-wiki.md` points at the workspace `AGENTS.md` |

Onboarding needs no per-harness wiring: it is `ONBOARDING.md` in the workspace,
and the platform's first turn points whichever harness is running at it.

`PLAIN_WIKI_HARNESS` takes a comma/space-separated list of `claude-code`,
`codex`, `pi`, `bob`, or `all`; unset, the bootstrap wires the family named by
`PLATFORM_HARNESS` (set in the platform's harness images), else every harness
CLI it finds on `PATH`, else `claude-code`.

## Layout

- [`bootstrap.sh`](bootstrap.sh) — the installer. Creates the directories, seeds
  `wiki/index.md`, appends the operating manual to `AGENTS.md`, puts
  `ONBOARDING.md` in place if it is missing, and wires each selected harness
  (table above). It **fetches the manual from `templates/` in this repo** rather
  than embedding a copy, so there is nothing to keep in sync.
- [`templates/AGENTS.md`](templates/AGENTS.md) — the operating manual the agent
  reads every session (layout, note format, the ingest → answer → maintain →
  document loop, the shape of the usage guide, and the onboarding rule for
  harnesses without command files).
- [`ONBOARDING.md`](ONBOARDING.md) — the first session: the checklist the agent
  reports to the platform, the welcome, taking in the first material, and
  publishing the knowledge base.

To change the wiki's behaviour, edit the files under `templates/`; `bootstrap.sh`
picks them up on the next install.

## Contract with the platform

This repository is a starter kit: [`kit.yaml`](kit.yaml) describes it, the
platform seeds the repo as the agent's workspace, runs `install.command`, and
then opens the first session with a briefing that ends in *follow
`ONBOARDING.md`*. So the kit **must ship `ONBOARDING.md` at its root**, and that
file is what asks the user for anything.

## Versioning

The platform installs from `main`, so a push to `main` takes effect for every
**new** Knowledge Base immediately (existing ones are not re-bootstrapped). There
is no pinned release yet; the curated catalog resolves this repo to a commit on
each refresh, so a Knowledge Base is always seeded from an exact commit.

## Develop / test

`bootstrap.sh` is self-checking (`set -euo pipefail`) and idempotent. To try it in
a throwaway directory, pointing at your own fork/branch:

```sh
mkdir /tmp/pw && cd /tmp/pw
PLAIN_WIKI_BASE=https://raw.githubusercontent.com/<you>/plain-wiki/<branch> \
  PLAIN_WIKI_HARNESS=all \
  bash <(curl -fsSL https://raw.githubusercontent.com/<you>/plain-wiki/<branch>/bootstrap.sh)
find . -type f          # AGENTS.md, CLAUDE.md, ONBOARDING.md, wiki/index.md
ls ~/.bob/rules
bash <(curl ...)        # re-run: should be a no-op, no duplicate manual block
```

A local checkout works too: `bash /path/to/plain-wiki/bootstrap.sh` reads
`templates/` from that checkout, and `PLAIN_WIKI_BASE=file:///path/to/plain-wiki`
points a bootstrap fetched from elsewhere at one.

## License

[MIT](LICENSE).
