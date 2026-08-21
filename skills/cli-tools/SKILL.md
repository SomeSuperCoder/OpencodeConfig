# CLI Power Tools — Ripgrep, fd, bat, eza, ast-grep, delta, pre-commit, hyperfine, tokei

Use these tools everywhere. They replace slower, dumber defaults with faster, smarter versions. Every invocation saves tokens and time.

---

## 1. ripgrep (`rg`) — Fast Code Search

Replaces: `grep`, `grep -rn`, `grep -r`

**Why:** Respects `.gitignore` by default, recursive by default, PCRE2 regex, PC-speed. Skip the noise.

### Patterns

| Task | Command |
|------|---------|
| Search all code for pattern | `rg 'pattern'` |
| Search specific file type | `rg -tjavascript 'Promise'` / `rg -tpy 'def login'` |
| Exclude a file type | `rg -Tsql 'TODO'` |
| Case insensitive | `rg -i 'error'` |
| Whole word match | `rg -w 'process'` |
| Count matches per file | `rg -c 'import'` |
| Files with matches only | `rg -l 'useEffect'` |
| Context lines (3 before/after) | `rg -C3 'panic'` |
| Fixed string (no regex) | `rg -F 'console.log('` |
| Search only filenames | `rg --files-with-matches 'TODO'` |
| Include hidden/ignored files | `rg -u 'pattern'` |
| JSON output | `rg --json 'pattern' \| jq -s '.'` |
| Search in specific directory | `rg 'pattern' src/` |
| Replace in pipeline | `rg 'old' --replace 'new'` (prints to stdout only) |
| Pipe to nushell | `rg 'pattern' -l \| lines` |

### Rule
**Never use `grep -rn` on code.** `rg` is faster, smarter, and respects ignore files. Use `rg` as the default for all code searches.

---

## 2. fd — Fast File Finder

Replaces: `find`, `find . -name`, `glob`

**Why:** Respects `.gitignore`, regex or glob, colorized output, max depth, type filter, exec bulk. Blink-fast.

### Patterns

| Task | Command |
|------|---------|
| Find files by name | `fd 'pattern'` |
| Find by extension | `fd -e ts` / `fd -e py` |
| Find directories only | `fd -td 'src'` |
| Find files only | `fd -tf 'config'` |
| Max depth | `fd -d3 'Component'` |
| Case insensitive | `fd -i 'readme'` |
| Full path match | `fd -p 'src/components'` |
| Include hidden files | `fd -H 'rc'` |
| Exclude ignored files (include .gitignore'd) | `fd -I 'dist'` |
| Exec command on results | `fd -e ts -x wc -l` |
| Pipe to nushell | `fd -e ts \| lines` |
| List with size | `fd -e log -s` |
| Find symlinks | `fd -tl` |
| Find empty files | `fd -te -tf` |

### Rule
**Never use `find . -name` on code.** `fd` is faster and ignores `.gitignore` by default. Use `fd` as the default for all file-finding tasks.

---

## 3. bat — Better Cat with Syntax Highlighting

Replaces: `cat`

**Why:** Syntax highlighting, line numbers, git change markers, auto-pager. Reads code like a human (with context).

### Patterns

| Task | Command |
|------|---------|
| View file with highlighting | `bat file.ts` |
| View without pager (pipe-safe) | `bat --paging=never file.ts` |
| Plain output (no line numbers) | `bat --plain file.ts` |
| Specific language | `bat -l rust file.txt` |
| Show diff markers (git) | `bat --diff` |
| Show non-printable chars | `bat -A file.txt` |
| Multiple files | `bat src/*.ts` |
| Read from stdin | `curl -s url \| bat -l json` |
| Show with decorations | `bat --style=full file.ts` |
| Pipe to another command | `bat file.ts \| head -50` |

### Rule
**Replace `cat` with `bat` for code files.** Use `--paging=never` when piping. Use `--plain` when piping to commands that don't need colors.

---

## 4. eza — Better ls with Git Integration

Replaces: `ls`, `ls -la`, `ls --color`

**Why:** Git status indicators, tree view, color-scale by size, icons, extended attrs. One command shows everything.

### Patterns

| Task | Command |
|------|---------|
| List with git status | `eza --git` |
| Long format + git | `eza -l --git` |
| Tree view (2 levels) | `eza --tree --level=2` |
| Tree with git | `eza --tree --git --level=2` |
| Show only git-ignored files | `eza -l --git-ignore` |
| Sort by size | `eza -l --sort=size` |
| Show hidden files | `eza -la` |
| Color-scale (big = red) | `eza --color-scale` |
| Headers | `eza -l --header` |
| Git repo status per dir | `eza --git-repos` |
| Absolute paths | `eza -l --absolute=dir` |
| Pipe to nushell | `eza -l --json 2>/dev/null \| from json` |

### Rule
**Replace `ls` with `eza` everywhere.** `eza --git` shows what `ls` + `git status` would show, in one command.

---

## 5. ast-grep (`sg`) — Structural Code Search & Replace

Replaces: regex grep on code, manual find-replace

**Why:** Searches by AST structure, not text. Finds `console.log($A)` without matching comments. Replaces patterns across files safely.

### Patterns

| Task | Command |
|------|---------|
| Search for pattern | `sg -p 'console.log($A)' -l ts` |
| Search and rewrite | `sg -p 'print($A)' -r 'logging.info($A)' -l py` |
| List matching files | `sg -p 'function $NAME(){}' -l js -l ts` |
| Specific language | `sg -p 'useState($INIT)' -l tsx` |
| Dry run (show matches) | `sg -p 'old_func($A)' -r 'new_func($A)' --dry-run` |
| YAML rule file | `sg scan -r rule.yaml src/` |
| Multi-file rewrite | `sg -p 'old_pattern' -r 'new_pattern' -l ts -l tsx -w` |

### Installation
```bash
pnpm add -g @ast-grep/cli
```

### Rule
**Use ast-grep for any code transformation across files.** Regex is for text; ast-grep is for code. It understands syntax, so it won't break strings or comments.

---

## 6. delta — Better Git Diff

Replaces: default `git diff` pager

**Why:** Syntax-highlighted diffs, side-by-side view, line numbers, change markers. Makes `git diff` readable.

### Configuration (one-time)
```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
git config --global delta.line-numbers true
git config --global merge.conflictstyle zdiff3
git config --global diff.colorMoved default
```

### Patterns

| Task | Command |
|------|---------|
| View diff (auto-pager) | `git diff` |
| Side-by-side diff | `git diff` (after config) |
| View commit diff | `git show HEAD -- pager=delta` |
| Compare two commits | `git diff HEAD~3 HEAD` |
| View staged diff | `git diff --staged` |

### Rule
**Always configure delta as git's pager.** It makes code review 10x faster. The config is one-time and permanent.

---

## 7. pre-commit — Git Hooks Framework

Replaces: manual git hooks, forgotten linting

**Why:** Declarative hooks config (YAML), auto-updates, shared across team, supports 100+ linters. Catches issues before commit.

### Configuration
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-json
      - id: check-yaml
      - id: check-merge-conflict
      - id: detect-private-key
      - id: no-commit-to-branch
        args: ['--branch', 'main']
```

### Patterns

| Task | Command |
|------|---------|
| Install hooks | `pre-commit install` |
| Run all hooks manually | `pre-commit run --all-files` |
| Update hooks to latest | `pre-commit autoupdate` |
| Skip hooks once | `git commit --no-verify` |
| Run specific hook | `pre-commit run trailing-whitespace --all-files` |
| Clean pre-commit cache | `pre-commit clean` |

### Rule
**Every project should have `.pre-commit-config.yaml`.** Run `pre-commit run --all-files` before committing. Keep hooks fast (< 5s total). Slow checks belong in CI, not pre-commit.

---

## 8. hyperfine — Benchmarking

Replaces: `time`, manual benchmarking scripts

**Why:** Statistical rigor, warmup runs, outlier detection, markdown/JSON output. Compares commands fairly.

### Patterns

| Task | Command |
|------|---------|
| Basic benchmark | `hyperfine 'command'` |
| Compare two commands | `hyperfine 'old_cmd' 'new_cmd'` |
| Warmup runs (I/O heavy) | `hyperfine --warmup 3 'rg pattern'` |
| Fixed number of runs | `hyperfine --runs 10 'make -j8'` |
| Min runs (micro-bench) | `hyperfine --min-runs 100 'echo hi'` |
| Setup before each run | `hyperfine --prepare 'rm -f out.txt' './build'` |
| Export markdown | `hyperfine --export-markdown results.md 'cmd1' 'cmd2'` |
| Export JSON | `hyperfine --export-json results.json 'cmd1' 'cmd2'` |
| Ignore failures | `hyperfine --ignore-failure 'cmd_that_fails'` |
| Shell builtins | `hyperfine --shell bash 'my_func'` |
| Parameterized | `hyperfine -P threads 1 8 'make -j{N}'` |

### Rule
**Use hyperfine to compare tools/commands before recommending one.** Always use `--warmup` for I/O-heavy commands. Report median + std deviation, not just "feels faster."

---

## 9. tokei — Code Statistics

Replaces: `wc -l`, `cloc`, manual counting

**Why:** Blazing fast (millions of lines/sec), accurate comment detection, 150+ languages, JSON/YAML output. The definitive code counter.

### Patterns

| Task | Command |
|------|---------|
| Count all code | `tokei` |
| Count specific language | `tokei --type rust` |
| Per-file breakdown | `tokei -f` |
| Exclude patterns | `tokei -e 'node_modules' -e 'dist'` |
| JSON output | `tokei --output json` |
| YAML output | `tokei --output yaml` |
| Include hidden files | `tokei --hidden` |
| Don't respect ignore | `tokei --no-ignore` |
| Compare with previous | `tokei -i previous_run.json` |
| Pipe to nushell | `tokei --output json \| from json` |

### Rule
**Use tokei to understand project size and composition.** It's the fastest way to answer "how big is this codebase?" or "how much Rust vs TypeScript?"

---

## Tool Selection Matrix

| Task | Tool | Why |
|------|------|-----|
| Find text in code | `rg` | Faster than grep, respects .gitignore |
| Find files by name | `fd` | Faster than find, respects .gitignore |
| View a code file | `bat` | Syntax highlighting + line numbers |
| List directory contents | `eza` | Git status + tree + color-scale |
| Search code structure | `ast-grep` | AST-aware, not regex |
| Review diffs | `delta` | Syntax-highlighted, side-by-side |
| Enforce code quality | `pre-commit` | Declarative hooks, auto-updates |
| Benchmark commands | `hyperfine` | Statistical rigor, warmup |
| Count code | `tokei` | Fastest, most accurate |

## ⚠️ IMPORTANT: Nushell Integration

All these tools produce text output. When the objective is **data processing** (parsing, filtering, aggregating), pipe through nushell:

```bash
# rg → nushell
rg 'pattern' --json | jq -s '.'

# fd → nushell
fd -e ts | lines

# bat → nushell (pipe-safe mode)
bat --paging=never file.ts | head -50

# eza → nushell
eza -l --json 2>/dev/null | from json

# tokei → nushell
tokei --output json | from json | select language files code
```

**The rule:** these tools gather data; nushell processes it. Use each for what it's best at.
