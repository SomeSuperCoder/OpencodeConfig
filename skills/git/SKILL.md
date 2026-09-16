---
name: git
description: "Mandatory git protocol for committing and pushing work. The Supervisor loads this before ending every response and spawns a Senior Engineer to commit. Auto-commit is obligatory — never leave uncommitted work."
---

# Git Protocol

Every session ends with a commit. No exceptions. No orphaned work.

## When to Run

**At the END of every response, after reporting to the user.**

The Supervisor spawns a Senior Engineer to commit the work.

## The Protocol

### Step 1: Stage Everything

```bash
git add -A
```

### Step 2: Check What Changed

```bash
git status
git diff --cached --stat
```

### Step 3: Write the Commit Message

Format: `<type>: <short description>`

| Type | When |
|------|------|
| `feat` | New feature, new skill, new agent, new capability |
| `fix` | Bug fix, permission fix, config fix |
| `refactor` | Restructure without changing behavior |
| `docs` | Documentation only |
| `chore` | Cleanup, deletion, formatting |
| `style` | No code change (whitespace, etc.) |

Rules:
- First line: type + short description (max 72 chars)
- Blank line
- Body: bullet points of what changed (max 5 bullets)
- No period at end of description

Example:
```
feat: add bash-runner subagent — sandboxed shell execution

- agents/team/core/bash-runner.md: censored sandbox with clear contract
- 9 allowed command categories, 12 explicitly refused
- Direct handoff by default, file writing only on request
- AGENTS.md: bash-runner added to Templates table
```

### Step 4: Commit

```bash
git commit -m "<message>"
```

### Step 5: Push

```bash
git push
```

### Step 6: Report

Return the commit hash and summary:
```
✅ Committed: <hash> — <message>
```

## Rules

1. **ALWAYS commit.** Never end a session with uncommitted work.
2. **ALWAYS push.** Local-only commits are incomplete.
3. **One commit per logical change.** Don't bundle unrelated changes.
4. **Write meaningful messages.** "update" is not a message.
5. **Stage everything first.** `git add -A` catches all changes.
6. **Check the diff before committing.** Don't commit blind.
