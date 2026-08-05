---
name: git-patterns
description: Git workflows, branching strategies, commit conventions. Use when setting up git, fixing git issues, or improving workflow.
---

# Git Patterns

## When To Use This

- Choosing a branching model for a team/repo
- Writing conventional commit messages
- Deciding rebase vs merge vs squash
- Fixing mistakes, bisecting bugs, cherry-picking fixes
- Keeping PRs reviewable and history bisectable

## Branching Models — Decision Table

| Model | Merge to | Branch lifetime | Best for | Cost |
|-------|----------|-----------------|----------|------|
| **Trunk-based** | `main` directly, feature flags | < 1 day | CI/CD, small-to-medium teams, high deploys | Needs feature flags + CI discipline |
| **GitHub Flow** | `main` via PR | Days | Most teams; every branch = a PR | Simple, low ceremony |
| **Git Flow** | `main` (releases) + `develop` | Weeks | Scheduled releases, multiple versions in maintenance | Heavy ceremony, slow feedback |
| **GitLab Flow** | environment branches (`staging`, `production`) | Days–weeks | Environments with deployment gates | Extra branches to maintain |

### Recommended default: Trunk-Based / GitHub Flow

```
main ──────────────────────────────────────────►
  │     │     │
  ├─A──►├─B──►├─C──►   (short-lived branches, merged fast)
  │     │     │
```

- Short-lived branches (hours–days), merged as soon as CI is green.
- Incomplete work is hidden behind **feature flags**, not long-lived branches — this keeps main always releasable.
- High deploy cadence forces small, reviewable changes.

### When Git Flow makes sense

Scheduled releases with a stabilization window: `main` = production, `develop` = integration, `release/*` = prep, `hotfix/*` = production patches (merged to both `main` and `develop`). If you don't have release cadence + versioned maintenance windows, Git Flow is overhead.

## Commit Conventions (Conventional Commits)

### Format

```
<type>(<scope>): <description>

[optional body — why, not what]

[optional footer(s)]   # Closes #123, BREAKING CHANGE, Co-authored-by
```

### Types

| Type | When | Semver |
|------|------|--------|
| `feat` | New user-visible feature | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | — |
| `style` | Formatting, no logic change | — |
| `refactor` | Restructure, behavior unchanged | — |
| `test` | Adding/fixing tests | — |
| `perf` | Performance improvement | — |
| `chore` | Build, tooling, deps | — |
| `ci` | CI configuration | — |
| `build` | Build system changes | — |
| `revert` | Reverting a commit | — |

### Good vs Bad

```
good: fix(auth): validate JWT audience claim to prevent token confusion
bad:  fix stuff
bad:  update
good: feat(api)!: change user response to camelCase
      BREAKING CHANGE: user fields renamed; update all clients
```

- Subject: imperative mood, ≤ 72 chars, **explain the why** in the body when the "what" isn't obvious.
- Breaking changes always marked with `!` + `BREAKING CHANGE:` footer (drives semver).
- `!` on a `feat`/`fix` is the only thing that should bump a major version.

### Commit scope & size

- **One logical change per commit** — a commit that touches 6 unrelated files is a red flag.
- Commit message = *reason the change was needed*, not a list of what changed (the diff already shows that).

## Rebase vs Merge vs Squash

### The three operations

| Operation | History | When |
|-----------|---------|------|
| `merge` | Preserves branch structure + merge commits | Shared branches, long-lived branches, preserving a feature's history |
| `rebase` | Linear; rewrites commits | Cleaning local work, syncing with `main`, before PR |
| `squash merge` | One commit on `main` | GitHub Flow PRs — tidy `main`, easy revert |

### Decision Matrix

| Scenario | Use |
|----------|-----|
| Your local commits before PR | Rebase (`git rebase -i`) to clean up |
| Feature branch vs moving `main` | Rebase onto `main`, then merge/squash |
| Merging a PR to `main` | **Squash merge** (one clean commit, easy `git revert`) |
| Long-lived shared branch | Merge (never rebase shared branches) |
| Release branch stabilization | Merge |
| Preserve granular history of a feature | Merge `--no-ff` |

### Rules that prevent pain

- **Never rebase a branch others have pulled** — you rewrite history they already have; force-push = data loss for them.
- Prefer `--force-with-lease` over `--force` (aborts if remote moved — protects against clobbering others).
- Rebase = every commit re-applied on top; conflicts repeat per commit. Merge = resolve once. For long divergence, **merge**; for short, **rebase**.

## Fixing Mistakes — Undo Cheat Sheet

| Mistake | Command | Result |
|---------|---------|--------|
| Just committed locally, keep changes | `git reset --soft HEAD~1` | Commit gone, staged |
| Committed locally, discard | `git reset --hard HEAD~1` | **Danger**: deletes changes |
| Committed AND pushed | `git revert <sha>` | New commit undoing it (never rewrite pushed history) |
| Staged a wrong file | `git restore --staged <file>` | Unstage, keep changes |
| Edited a tracked file, want it back | `git restore <file>` | Discard working-tree changes |
| Want to un-delete a deleted commit | `git reflog` → `git cherry-pick <sha>` | Recover lost work |
| Mistakenly reset/branch-deleted | `git reflog` + `git reset --hard <sha>` | Restore from reflog |
| Stashed changes you forgot | `git stash list` / `git stash pop` | Recover stash |

### Reflog — the safety net

```bash
git reflog            # every HEAD movement, ~90 days
git reset --hard HEAD@{2}   # go back to where HEAD was 2 moves ago
```

**Rescue workflow:** anything "lost" is in the reflog for ~90 days (or until GC). Before panicking: `git reflog`, find the commit, `git reset --hard <sha>` or `git cherry-pick <sha>`.

## Cherry-Pick

```bash
# Apply a single commit to the current branch
git cherry-pick abc123
# Multiple / a range (exclusive end)
git cherry-pick abc123 def456
git cherry-pick abc123..def456
# Without committing (stash for review, or apply to staging)
git cherry-pick -n abc123
```

**Use when:** a hotfix must land on both `main` and a release branch; a commit belongs on the wrong branch; recovering from reflog. **Avoid as a substitute for proper merging** — it duplicates commits and drifts from the original.

## Bisect — find the breaking commit

```bash
git bisect start
git bisect bad          # current state is broken
git bisect good v1.0    # known-good commit
# git checks out the midpoint — test it:
git bisect good    # midpoint was fine
git bisect bad     # midpoint was broken
# Repeat until the offender is named

# Automated: bisect run the failing test command
git bisect start HEAD v1.0
git bisect run pnpm test  # exits non-zero = bad commit found
```

Rules: start with a reliably-failing test/command (not an intermittent one); give a *known-good* commit; binary-search precision depends on your "good/bad" honesty per step.

## PR Hygiene

### The PR contract

| Aspect | Good | Bad |
|--------|------|-----|
| Size | Small (< 400 lines, 1 concern) | 2,000-line monolith |
| Title | Conventional, imperative | "updates" |
| Description | What + why + test plan + screenshots | Empty |
| CI | Green before review | Red, "will fix later" |
| Rebase | Up to date with `main` | Conflicted or months stale |
| Reviews | Addressed, then re-request | Ignored comments |
| Merge | Rebase/squash when approved | Rebase-merge chaos |

- **Small PRs get reviewed better and merge faster** — split features into logical PRs; every commit should still compile and pass tests (bisectable history).
- Re-request review after addressing comments; keep the conversation resolvable.
- Before merging: `git pull --rebase` on `main`, resolve, re-run affected tests.

## Git Hooks & Automation

```bash
# .husky/pre-commit     — fast checks only
pnpm lint
# .husky/commit-msg     — enforce conventional commits
pnpm exec commitlint --edit "$1"
# .husky/pre-push       — slower checks before pushing
pnpm test
```

- Keep `pre-commit` fast (lint/format); run the full suite in CI, not hooks.
- Commitlint config for type-enum + subject-length (72).

## Worktrees — parallel work without stashing

```bash
# Work on a hotfix without touching your current checkout
git worktree add ../hotfix-branch hotfix/bug
git worktree remove ../hotfix-branch     # after merging
```

## Common Pitfalls / Anti-Patterns

| Pitfall | Why it hurts | Fix |
|---------|-------------|-----|
| Force-pushing shared branches | Destroys others' work | Rebase only local/private; `--force-with-lease` |
| Committing secrets | Leaks forever in history | Pre-commit secret scan; rotate leaked creds |
| Giant commits / giant PRs | Unreviewable, un-bisectable | One logical change per commit |
| "fix stuff" messages | Useless in `git log`, `git blame`, releases | Conventional commits with why |
| Merging `main` then merging PR with same content | Noisy history | Rebase feature, then squash merge |
| `reset --hard` on uncommitted work | Instant data loss | Check `git status`/`git diff` first; use reflog |
| Long-lived feature branches | Divergence hell, merge pain | Trunk-based + feature flags |
| Intermittent `bisect run` | Wrong commit identified | Use a deterministic failing test |
| Cherry-picking instead of merging | Duplicate commits, drift | Merge the branch normally |

## Best Practices Checklist

- [ ] Branching model matches team size + release cadence (default: trunk-based/GitHub Flow)
- [ ] Short-lived branches; main always releasable
- [ ] Conventional commits: type(scope): imperative subject ≤ 72 chars, why in body
- [ ] `!` + `BREAKING CHANGE:` for breaking changes
- [ ] One logical change per commit; commits compile + pass tests
- [ ] Rebase local, squash-merge to main, never rebase shared branches
- [ ] `--force-with-lease` not `--force`
- [ ] Revert pushed mistakes; reset only local
- [ ] Bisect with a deterministic failing command
- [ ] Small PRs, green CI, rebased, review comments resolved
