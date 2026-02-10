# ccg — Claude Code Git

Keep Claude Code process files out of your product repo.

## What it does

When you work with Claude Code, files like `CLAUDE.md`, `.claude/`, `PLAN.md`,
and `TASKS.md` accumulate. These are valuable — your instructions, context, and
plans — but they don't belong in your public product repo.

ccg gives you two repos from one working directory:

- **product repo** — your code, public
- **claude repo** — your Claude configs and plans, private

One command to set up. One command to commit. Your code stays clean.

## Requirements

- [pgit](https://github.com/ErikOlson/pgit) — the underlying engine (required)
- [gh](https://cli.github.com) — GitHub CLI (required for `ccg remote` only)

> **Note for nix users:** a `flake.nix` that declares both as inputs is planned.
> Until then, install both manually and ensure they're on your PATH.

## Quick start

```sh
ccg init                    # set up in current directory
ccg add .                   # stage files — auto-routes product vs claude
ccg commit -m "first commit"
ccg remote                  # create GitHub repos (public + private)
ccg push                    # push both
```

## Commands

```
ccg                   Quick overview (branch, status, last commit for both repos)
ccg init              Set up Claude Code process separation
ccg add [files]       Stage files — auto-routes to product or claude repo
ccg status            Show status of both repos
ccg commit -m MSG     Commit both repos with one message
ccg push              Push both repos
ccg remote            Create/connect GitHub remotes (public product, private claude)
```

## How commits work

`ccg commit -m "your message"` commits the product repo with your message.
The claude repo gets `sync: product@<hash>` — a cross-reference without noise.

## Under the hood

ccg is a thin wrapper around [pgit](https://github.com/ErikOlson/pgit). It
creates a standard `.pgit/` setup, so `pgit` and `pnp` commands work at any
time if you need lower-level access.
