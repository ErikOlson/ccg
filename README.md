# ccg — Claude Code Git

Keep your Claude Code files out of your product repo.

## The problem

When you work with Claude Code, files accumulate: `CLAUDE.md`, `.claude/`,
`PLAN.md`, `TASKS.md`. These are valuable — your instructions, context, plans,
and working notes. But they don't belong in your public product repo. They're
your process, not your product.

## The solution

ccg gives you two git repos from one working directory:

| Repo | What goes there | Visibility |
|------|----------------|------------|
| **product repo** | your code | public |
| **claude repo** | your Claude files | private |

Files route automatically based on name. `CLAUDE.md` goes to the claude repo.
`main.go` goes to the product repo. You just run `ccg add .` and it sorts itself out.

## Quick start

```sh
ccg init                     # set up in current directory
ccg add .                    # stage everything — auto-routed
ccg commit -m "first commit" # one message, both repos
ccg remote                   # create GitHub repos (public + private)
ccg push                     # push both
```

## Commands

```
ccg                   Quick overview — branch, status, last commit for both repos
ccg init              Set up Claude Code process separation
ccg add [files]       Stage files — auto-routes to product or claude repo
ccg status            Show full status of both repos
ccg commit -m MSG     Commit both repos with one message
ccg push              Push both repos
ccg remote            Create/connect GitHub remotes
```

## How commits work

`ccg commit -m "your message"` commits the product repo with your message.
The claude repo gets `sync: product@<hash>` — a quiet cross-reference that
lets you correlate the two histories without duplicating noise.

## What goes to the claude repo

By default, ccg treats these as Claude process files:

- `CLAUDE.md` — your project instructions for Claude
- `.claude/` — Claude configuration directory
- `.claudeignore` — files to hide from Claude
- `PLAN.md` — project planning
- `TASKS.md` — task tracking
- `AGENTS.md` — agent definitions

Everything else goes to the product repo.

## Requirements

- [pgit](https://github.com/ErikOlson/pgit) — the underlying engine (required)
- [gh](https://cli.github.com) — GitHub CLI (required for `ccg remote` only)

**Nix users:** a `flake.nix` is included. Add ccg to your tools flake alongside pgit.

## Under the hood

ccg is a thin wrapper around [pgit](https://github.com/ErikOlson/pgit). It
creates a standard `.pgit/` setup, so `pgit` and `pnp` commands work at any
time if you need lower-level access. When you outgrow ccg, just start typing
`pgit` — no migration needed.
