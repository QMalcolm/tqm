# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Dependencies
mix deps.get

# Tests
mix test                              # All tests
```

## Conventions

- Tests use `async: true` and include doctests where appropriate.
- Commits are small and atomic; messages explain *why*, not just what. Exceptions for large sweeping changes (lint rule changes, package updates, etc.).
- Each commit should represent a single concern. Cleanup (typo fixes), abstraction (deduplicating logic), refactoring (reworking a function/module/system architecture), bug fixes, and feature additions must not be intermixed. If a feature requires cleanup, then a refactor, then the addition itself — those are three separate commits.
- When working on a task, plan the commit sequence upfront. If you notice unrelated cleanup or duplication mid-task, defer it to a follow-up commit rather than mixing it into the current change. Use `git add -p` when needed to stage only the relevant hunks.
- Commit descriptions are encouraged (but not required) and should cover: why the change is necessary, any foreseen issues, and paths intentionally not taken (and why).
- Commits are GPG-signed (`commit.gpgsign=true`). Do not skip signing.
- Do not add `Co-Authored-By` trailers.
