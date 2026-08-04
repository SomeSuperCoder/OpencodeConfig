---
name: git-patterns
description: Git workflows, branching strategies, commit conventions. Use when setting up git, fixing git issues, or improving workflow.
---

# Git Patterns

## Branching Strategies

### GitHub Flow (Simple)

```
main ──────────────────────────────────────────►
  │
  └─ feature/login ──► PR ──► merge ──► deploy
```

- Branch from `main`
- Create PR when ready
- Squash merge to `main`
- Deploy from `main`

### Git Flow (Complex)

```
main ──────────────────────────────────────────►
  │
  └─ develop ──────────────────────────────────►
       │
       ├─ feature/login ──► PR ──► develop
       │
       ├─ release/1.0 ──► PR ──► main
       │
       └─ hotfix/bug ──► PR ──► main + develop
```

- `main` — production
- `develop` — integration
- `feature/*` — new features
- `release/*` — release prep
- `hotfix/*` — production fixes

### Trunk-Based (Recommended)

```
main ──────────────────────────────────────────►
  │     │     │
  ├─A──►├─B──►├─C──► (short-lived branches)
  │     │     │
```

- Short-lived branches (< 1 day)
- Feature flags for incomplete work
- Continuous integration
- Fast feedback loop

## Commit Conventions (Conventional Commits)

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting (no code change) |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Build, CI, tooling |
| `perf` | Performance improvement |
| `ci` | CI configuration |
| `build` | Build system |

### Examples

```
feat(auth): add OAuth2 login support

Implements Google and GitHub OAuth2 providers.
Adds session management and token refresh.

Closes #123
```

```
fix(api): handle null response from external service

Previously crashed when external API returned null.
Now returns empty array instead.
```

```
refactor(users): extract validation to separate module

Moves validation logic from UserService to UserValidator
for better testability and separation of concerns.
```

### Breaking Changes

```
feat(api)!: change user response format

BREAKING CHANGE: User object now uses camelCase
instead of snake_case. Update all client code.
```

## Rebase vs Merge

### Rebase (Linear History)

```bash
# Interactive rebase — clean up commits
git rebase -i HEAD~3

# Rebase feature branch onto main
git checkout feature/login
git rebase main

# Resolve conflicts, then
git push --force-with-lease
```

**When to use:**
- Clean up local commits before PR
- Keep linear history on `main`
- Sync feature branch with main

### Merge (Preserve History)

```bash
# Merge feature into main
git checkout main
git merge --no-ff feature/login

# Creates merge commit
```

**When to use:**
- Preserve branch history
- Shared branches
- Complex merges

### Decision Matrix

| Scenario | Use |
|----------|-----|
| Local commits before PR | Rebase |
| Shared branch | Merge |
| Main branch | Squash merge |
| Release branch | Merge |

## Cherry-Pick

```bash
# Apply specific commit to current branch
git cherry-pick abc123

# Cherry-pick multiple commits
git cherry-pick abc123 def456

# Cherry-pick range
git cherry-pick abc123..def456

# Cherry-pick without committing
git cherry-pick --no-commit abc123
```

## Bisect (Find Bug)

```bash
# Start bisect
git bisect start
git bisect bad          # Current commit is bad
git bisect good v1.0    # Known good commit

# Git checks out commit to test
# Test it, then mark:
git bisect good   # or
git bisect bad

# Repeat until found
# Automated bisect:
git bisect run npm test
```

## Useful Commands

### Undo Changes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo specific file
git checkout -- file.ts

# Unstage file
git reset HEAD file.ts
```

### Stash

```bash
# Save changes
git stash push -m "work in progress"

# List stashes
git stash list

# Apply stash
git stash pop

# Apply specific stash
git stash apply stash@{2}
```

### Interactive Rebase

```bash
git rebase -i HEAD~5

# Pick — keep commit
# Reword — change commit message
# Edit — modify commit content
# Squash — combine with previous
# Fixup — combine, discard message
# Drop — remove commit
```

### Worktrees (Parallel Work)

```bash
# Create worktree for hotfix
git worktree add ../hotfix-branch hotfix/bug

# Work in parallel without stashing
# Remove when done
git worktree remove ../hotfix-branch
```

## Git Hooks (Husky)

```bash
# .husky/pre-commit
npm run lint

# .husky/commit-msg
npx commitlint --edit $1

# .husky/pre-push
npm run test
```

## Commit Message Linting

```json
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'test', 'chore', 'perf', 'ci', 'build'
    ]],
    'subject-max-length': [2, 'always', 72],
  },
};
```
