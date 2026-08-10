# 🏢 The Opencode Software Company

> **Stop prompting an assistant. Start directing a company.**

**🌐 Languages:** [English](./README.md) · [Español (España)](./README.es.md) · [Русский](./README.ru.md)

One AI coding CLI becomes a **self-organizing software firm** — a Tech Lead who commands, 15 field Leads who orchestrate, 61 senior specialists who execute, and a microtask pipeline so fast that a full feature ships in minutes, not hours. Every change is tested. Every change is documented. Every change is verified before it touches your codebase.

**You are the Director. You say what matters. It does the rest.**

🐳 **[Container Setup](./CONTAINER_SETUP.md)** · [Español](./CONTAINER_SETUP.es.md) · [Русский](./CONTAINER_SETUP.ru.md) — Run opencode in a reproducible Podman container with all dependencies pre-installed.

---

## 🌋 The Problem This Kills

Ask a single AI assistant to "build the checkout flow" and you get: a confident monologue, a wall of code, zero tests, and bugs you find in production.

The reason is structural. One model doing everything at once is a **generalist doing five jobs badly** — architect, engineer, tester, reviewer, and security auditor are all one fuzzy brain. There is no review. There is no verification. There is no accountability.

**This project is the cure.** It splits that one fuzzy brain into a **company of specialists** — each a senior engineer with exactly ONE lane, each fast because it's small, each accountable because it hands off a work report, not vibes.

---

## ✨ The Company, In One Breath

| Tier | Who | One Job |
|------|-----|---------|
| 👑 **Director** | You | Vision, priorities, final decisions |
| 🧠 **Team Lead** | `team/tech-lead` | Plan the work, staff the waves, review, report, commit |
| 🧑‍💼 **15 Field Leads** | `team/lead/*` | Advise on their field — plan microtasks, recommend specialist IDs, NEVER spawn |
| 👥 **61 Specialists** | Senior engineers | Do ONE microtask, prove it, hand it off, stop |

**Directives flow DOWN. Reports flow UP. Field Leads advise; the Team Lead spawns. Nobody crosses the chain of command.**

```
         👑 DIRECTOR (you)
              │  "Ship the export feature" ↓
         🧠 TEAM LEAD
              │  asks for orchestration advice ↓
         🧑‍💼 FIELD LEADS           recommend specialist IDs ↑
              ▼
         👥 61 SPECIALISTS         each does ONE microtask
              ▲  work reports flow UP
         🧠 TEAM LEAD
              │  status + evidence + escalations ↑
         👑 DIRECTOR
```

---

## 🧠 Why It's Fast — The Asymmetry Is Deliberate

Most "AI company" setups fail because every agent is a giant prompt that re-derives everything. This one inverts the classic trade:

| Layer | Prompt size | Why |
|-------|-------------|-----|
| **Specialists** | Tiny | One microtask, one lane, **born with the data** — zero exploration |
| **Field Leads** | Small | Field roster + routing knowledge — plan microtasks, recommend IDs, never spawn |
| **Team Lead** | Huge (~1,400 lines) | Holds the protocols, routing matrix, quality gates, escalation rules |
| **AGENTS.md** | Medium | The universal constitution every agent obeys |
| **Skills** | Deep, lazy-loaded | Pulled in only when a microtask needs them |

**The rule:** small agents work fast → the bottleneck is context injection → so the Team Lead carries the context. A well-spawned worker finishes **in minutes**. Speed through smallness.

---

## 🏭 The Microtask Pipeline — Why It Ships

Every task is one pass through a pipeline where each specialist does exactly their step and stops:

```
CONTEXT → DESIGN → IMPLEMENT → TEST → VERIFY → DELIVER
  Scout     Field      Engineer   Test      QA, Code   Tech Lead
            Leads      (one      Engineer   Reviewer,  commits
            + Design   microtask            Security,
            specialists  each)              audits
```

**Field Leads sit at the DESIGN stage:** they break the directive into the narrowest microtasks and recommend which specialist handles each one. The Tech Lead takes that plan, spawns the specialists itself, and drives the rest of the pipeline.

**The laws that make it work:**

- 📦 **One session = one microtask.** Delivered = session over. No scope creep, no "while I'm here."
- 🍼 **Born with the data.** The Team Lead injects facts, code excerpts, blast radius, and the spec into every spawn prompt. A worker never explores the codebase.
- 📤 **Report, don't fix.** Find a bug outside your lane? Write it in your work report. The Team Lead routes it.
- ⚡ **Speed is a feature.** A microtask that needs 6+ steps was too big — the Team Lead should have split it.

**The Surgical Workflow** — every agent, every task:

```
① THINK  →  ② PLAN  →  ③ ACT  →  ④ VERIFY  →  ⑤ DELIVER → STOP
```

Narrowest first. One pass. Minimum verification. Stop at delivery.

---

## 🔐 The Discipline That Makes It Not Chaos

Anyone can spawn 30 agents. Chaos is easy. **Verification is the hard part** — and this system is brutal about it:

| Protocol | What it enforces |
|----------|------------------|
| 🗣️ **FIRCAC** | Facts → Issue → Rules → Cases → Application → Consequences. Mandatory, spoken out loud, before every bug fix or hard decision. |
| 🔍 **ABC** | **Assume Nothing. Believe Nobody. Confirm Everything.** The verification doctrine — every claim is proven, not trusted. |
| 🧪 **ONE-RUN testing** | Run the suite once, capture everything. Never re-run to "fish" for output. |
| 🔴🟢 **RED-GREEN** | A change gets AT MOST 2 test runs, ever. Fix in batches, not dribbles. |
| 🏓 **One lane owns tests** | The Test Engineer runs the suite. Everyone else consumes the verdict. Nobody re-runs someone else's green. |
| 🧠 **Intelligence Amplifiers** | CodeGraph first (never grep). Tavily before guessing. Browser to actually SEE the UI. AgentMemory for persistent memory. Nushell for structured data. |
| 🚦 **Escalation** | Human decisions go UP with options + deadline. Implementation decisions stay in-house. The Team Lead escalates, never guesses. |
| 📤 **HANDOFF CONTRACT** | Every deliverable ends with Verdict + Evidence + Files + Next owner. Nobody re-parses free-form. |
| ✅ **Definition of Done** | Tested, documented, type-clean, no dead code, handoff filled out. Untested work is NOT done. |
| 🔄 **Session Start** | RECALL → check sessions → state the world → load spec → announce. Never start blind. |
| 🚨 **"I'm Going" Mode** | Say "I'm going" — the company runs fully autonomous, documents every decision, and reports on your return. |

---

## 🔌 Plugins — The Invisible Infrastructure

Four plugins run silently in the background, making the system smarter without you noticing:

| Plugin | What It Does |
|--------|--------------|
| 🧹 **opencode-dynamic-context-pruning** | Automatically prunes context to stay within token limits — agents never hit the ceiling |
| 🔍 **opencode-tool-search** | Enables intelligent tool discovery — agents find the right tool without hardcoding |
| 📢 **opencode-notifier** | Sends notifications when tasks complete — you know when something ships |
| 🔄 **opencode-auto-resume** | Auto-resumes interrupted sessions — pick up exactly where you left off |

Configured in `opencode.jsonc`:
```jsonc
"plugin": [
  "opencode-dynamic-context-pruning",
  "opencode-tool-search",
  "@mohak34/opencode-notifier@latest",
  "opencode-auto-resume"
]
```

---

## 🧠 MCP Servers — The Brain Extension

Two MCP servers give agents superpowers beyond what the LLM can do:

| Server | Type | What It Does |
|--------|------|--------------|
| **CodeGraph** | Local (bundled) | Codebase intelligence — symbol lookup, call chains, blast radius. Replaces grep with a knowledge graph. |
| **Tavily** | Remote | Web search, docs extraction, research. Agents verify claims instead of guessing. |
| **AgentMemory** | Local (bundled) | Persistent memory across sessions — facts, patterns, architecture decisions survive restarts. |

```jsonc
"mcp": {
  "codegraph": {
    "type": "local",
    "command": ["codegraph", "serve", "--mcp"]
  },
  "tavily": {
    "type": "remote",
    "url": "https://mcp.tavily.com/mcp/?tavilyApiKey={file:.secrets/tavily.key}"
  }
}
```

---

## 🧰 The Arsenal — Skills, Loaded On Demand

19 skills, never pre-loaded, pulled in the instant a microtask needs them:

**Reasoning & verification:**
`fircac-out-loud` (reasoning + ABC verification) · `find-skills` (discover new capabilities)

**Code craft:**
`testing-patterns` · `api-patterns` · `error-patterns` · `state-patterns` · `caching-patterns` · `refactoring-patterns` · `performance-patterns` · `algorithm-patterns` · `git-patterns`

**Domain & compliance:**
`security-patterns` · `compliance-patterns` · `domain-knowledge` · `research-patterns`

**Frontend & design:**
`a11y-patterns` · `impeccable` (command-driven design tool — run `context.mjs`, route to a subcommand; **DESIGN.md is law**) · `ux-psychology` (conversion optimization) · `ux-redesign-examples` (real AB test patterns)

**The scatter principle:** AGENTS.md = the universal floor. Skills = deep, rare, on-demand. Agents = only what's role-specific. The Team Lead is the one exception — its protocols live inline because it uses them every single session.

---

## 🎨 Design Patterns — The Code Style Bible

The company follows 15 battle-tested design patterns. Full guidelines in [`CODE_STYLE.md`](./CODE_STYLE.md).

| Pattern | When | Anti-pattern it kills |
|---------|------|----------------------|
| **Inversion of Control** | External dependencies | Code that calls libraries instead of being called |
| **Explicit Dependency** | All dependencies | Hidden coupling through globals, singletons, or service locators |
| **Parse, Don't Validate** | Input handling | Runtime checks that leave types untyped |
| **Tri-state Pattern** | Optional values | Null/undefined confusion — explicit Present/Absent/Error |
| **Fail-Fast Boundary** | Error handling | Raw errors leaking across layers |
| **Single Level of Abstraction** | Function design | Mixing high-level orchestration with low-level details |
| **Tolerant Reader** | External data | Brittle parsers that break on unexpected input |
| **Error Value Pattern** | Expected failures | Exceptions for control flow — errors as values, not throws |
| **Type-Safe Builder** | Complex construction | Partially initialized objects, telescoping constructors |
| **Anti-Corruption Layer** | External APIs | Domain logic tangled with Stripe/DB/SMTP |
| **Composition Over Inheritance** | Code reuse | Deep inheritance hierarchies that lock behavior |
| **Sentinel Object** | Special values | Magic numbers and null checks |
| **Specification Pattern** | Business rules | Scattered if-else chains |
| **Result Type** | Expected failures | Exceptions for control flow — Ok/Err, never throw |
| **Bounded Context** | Domain modeling | God objects that serve every use case |

**The meta-rule:** Code is a communication medium. If the reader must look at the implementation to understand the call, the abstraction is wrong.

---

## 📜 The Director's Playbook

Your full command manual lives in [`DIRECTOR.md`](./DIRECTOR.md). Here's the essence:

### Your 7 Powers

| Power | What It Means |
|-------|---------------|
| 🎯 **Direct** | "Ship X" — one line, the company handles the rest |
| 📊 **Prioritize** | "Do X before Y" — the Team Lead re-orders the pipeline |
| ✅ **Approve** | "Ship it" or "redo it" — the company waits for your verdict |
| ⚖️ **Decide** | "Option A or B?" — the company presents options, you pick |
| 🔧 **Hire/Fire** | "Remove the pentest suite" — the company restructures |
| 📋 **Review** | "Show me what shipped" — the company debriefs with evidence |
| 🌑 **Go Dark** | "I'm going" — full autonomous mode, decisions documented |

### What Comes Back to You

| Artifact | What It Contains |
|----------|-----------------|
| 📦 **Deliverable** | Working code, tested, verified |
| 📋 **Status Report** | What shipped, what's in-flight, what's blocked |
| ⚠️ **Escalation** | A decision only you can make — options + tradeoffs + deadline |
| 📜 **Board Minutes** | Every decision made while you were away (autonomous mode) |

---

## 🛠️ Scripts — The Toolbelt

Four scripts automate the container workflow:

| Script | What It Does |
|--------|--------------|
| `launcher.sh` | Launches the Podman container — handles build, mounts, X11, secrets, UID mapping |
| `create-project` | Scaffolds a new opencode project — git init, codegraph init, .opencode config |
| `setup-project` | Wires an existing project for opencode — OpenSpec + CodeGraph init |
| `first-run.sh` | Container entrypoint — runs pnpm install on first launch, then drops into bash |

**Usage:**
```bash
# New project
create-project my-api --dir ~/projects

# Existing project
setup-project /path/to/project

# Container
./scripts/launcher.sh ~/code          # mount your projects folder
./scripts/launcher.sh --build         # force rebuild
```

Full container documentation: **[CONTAINER_SETUP.md](./CONTAINER_SETUP.md)** · [Español](./CONTAINER_SETUP.es.md) · [Русский](./CONTAINER_SETUP.ru.md)

---

## ⚙️ Configuration

### opencode.jsonc — The Control Panel

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-dynamic-context-pruning", "opencode-tool-search", "..."],
  "mcp": { "codegraph": { ... }, "tavily": { ... } },
  "default_agent": "team/tech-lead",          // ← The King is your default
  "permission": {
    "external_directory": { "/tmp": "allow", "/home/*/OpencodeImprovements": "allow" },
    "bash": { "* /tmp*": "allow", "*/home/*/OpencodeImprovements*": "allow" }
  }
}
```

| Setting | What It Does |
|---------|--------------|
| `default_agent` | Which agent runs when you start opencode (default: `team/tech-lead`) |
| `permission.external_directory` | Which host directories agents can access |
| `permission.bash` | Which bash commands agents can run without prompting |

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `TAVILY_API_KEY` | Tavily API key for web search (also stored in `.secrets/tavily.key`) |

### Config Files

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Primary config — plugins, MCP, permissions, default agent |
| `AGENTS.md` | The constitution — every agent obeys this 1,400-line document |
| `DIRECTOR.md` | Your playbook — how to command the company |
| `CODE_STYLE.md` | 15 design patterns the company follows |
| `tui.json` | TUI configuration (currently empty placeholder) |

---

## 📁 The Machine Room

```
~/.config/opencode/
├── README.md                   ← you are here
├── AGENTS.md                   ← the constitution (every agent obeys it)
├── DIRECTOR.md                 ← your playbook — how to command the company
├── CODE_STYLE.md               ← 15 design patterns
├── opencode.jsonc              ← config: MCP servers, plugins, permissions, default agent
├── Containerfile               ← container build definition (Fedora 44)
│
├── agents/
│   └── team/                                  ← the company (the `team/*` agent namespace)
│       ├── tech-lead.md                       ← THE KING — the orchestrator (default agent)
│       ├── lead/                              ← 🧑‍💼 FIELD LEADS (advisory — plan, never spawn)
│       │   ├── frontend-lead.md · backend-lead.md · quality-lead.md
│       │   └── security-lead.md · platform-lead.md · product-lead.md · research-lead.md
│       │       · telegram-lead.md · pinescript-lead.md · mobile-lead.md · web3-lead.md
│       │       · seo-lead.md · lgtm-lead.md · engagement-lead.md · highload-lead.md
│       ├── core/                              ← cross-cutting (scout · wise-old-man · vision-reader)
│       ├── frontend/                          ← engineer · ui-designer · ux-designer · design-system · animations · i18n
│       ├── backend/                           ← engineer · api-designer · database · data · integration · llm
│       ├── quality/                           ← test · qa · code-reviewer · bug-hunter · critique
│       ├── security/                          ← security-engineer · pentest/ (⛔ off-by-default suite)
│       ├── platform/                          ← devops · observability · performance
│       ├── product/                           ← product-understander · requirements · architect · refactoring
│       ├── research/                          ← research-agent · domain-expert · documentation · skill-generator
│       ├── telegram/                          ← bot-engineer · mini-app-engineer · integration-engineer
│       ├── pinescript/                        ← indicator-developer · strategy-developer · pro-quant
│       ├── mobile/                            ← engineer · native-engineer · performance-engineer
│       ├── web3/                              ← smart-contract · dapp-engineer · defi-analyst
│       ├── seo/                               ← seo-engineer · content-strategist · analytics-specialist
│       ├── lgtm/                              ← loki · grafana-dashboard · tempo · mimir
│       ├── engagement/                        ← gamification-engineer · behavioral-designer · retention-analyst
│       └── highload/                          ← architect · engineer · load-testing-engineer
│
├── skills/                                       ← 19 pattern skills, loaded on demand
│   ├── fircac-out-loud/ · testing-patterns/ · api-patterns/ · error-patterns/
│   ├── state-patterns/ · caching-patterns/ · refactoring-patterns/ · security-patterns/
│   ├── a11y-patterns/ · algorithm-patterns/ · domain-knowledge/ · compliance-patterns/
│   ├── git-patterns/ · research-patterns/ · performance-patterns/ · find-skills/
│   ├── impeccable/ · ux-psychology/ · ux-redesign-examples/
│
├── scripts/
│   ├── launcher.sh              ← Podman container launcher
│   ├── create-project           ← scaffold new opencode project
│   ├── setup-project            ← wire existing project (OpenSpec + CodeGraph)
│   └── first-run.sh             ← container entrypoint
│
├── recommendations/             ← persistent improvement tracking
│   ├── security/ · performance/ · quality/ · testing/
│   ├── accessibility/ · architecture/ · general/
│
├── data/                        ← opencode state (state_store.db, stream_store, ops_board.md)
├── plans/                       ← active work plans
├── .secrets/                    ← API keys (gitignored)
├── .env.example                 ← environment variable template
└── node_modules/                ← plugin dependencies
```

---

## 🔄 Self-Improvement — The Harness Gets Better

Any agent can report problems with the AI harness itself. The system improves by listening to its own operators.

**Directory:** `~/OpencodeImprovements/reports/`

Reports are written as markdown files using the [REPORT_TEMPLATE.md](~/OpencodeImprovements/REPORT_TEMPLATE.md). When an agent finds a broken rule, a missing role, a workflow bottleneck, or a configuration problem, it writes a report. The Director reviews and approves changes. The Tech Lead implements them.

**Self-Reflection Protocol** — every agent, before handoff, answers:
1. Did I explore anything I wasn't given?
2. Did I load a skill I didn't need?
3. Did I re-verify something already verified?

**The Rule:** the harness is code. It gets code-reviewed. It gets improved. Agents are the first line of defense against harness rot.

---

## 📋 Recommendations — Persistent Improvement Tracking

Every "pass with recommendations" from QA, security, code review, or any verification agent gets saved to `recommendations/` — not lost in chat history.

```
recommendations/
├── security/          ← security-related improvements
├── performance/       ← performance recommendations
├── quality/           ← code quality suggestions
├── testing/           ← test improvements
├── accessibility/     ← a11y recommendations
├── architecture/      ← architectural improvements
└── general/           ← other recommendations
```

**Format:** `YYYY-MM-DD-topic.md` with Status, Priority, Effort, Rationale, Evidence.

**User command:** `"Implement all recommendations"` (or "Implement all prior recommendations") → Tech Lead runs the RECOMMENDATION IMPLEMENTATION PROTOCOL: scan pending → already-implemented check → contradiction scan → group by domain → spawn per domain → verify per tier → remove files on completion → report. Contradicting or already-present recommendations never get re-implemented.

Full protocol: [`recommendations/README.md`](./recommendations/README.md)

---

## 🧠 AgentMemory — Persistent Memory Across Sessions

AgentMemory is a standalone MCP server that gives every agent persistent memory across sessions:

```
┌─────────────────────────────────────────────────────────┐
│  agentmemory-mcp (MCP Server)                          │
│  ├── SQLite database with FTS5 full-text search         │
│  ├── Provides memory_save, memory_recall, etc.          │
│  ├── Automatic compaction, search, and context injection│
│  └── Exposes resources for browsing memories            │
└─────────────────────────────────────────────────────────┘
```

**Memory types:** `fact`, `pattern`, `architecture`, `bug`, `workflow`, `preference`

**When to save:** Architecture decisions, bug root causes, project patterns, user preferences, repeatable processes.

**When to recall:** Session start, debugging, before refactoring, before asking user something you should know.

---

## 🚀 Run the Company — How It Feels From Your Desk

```
You:        Fix the payment bug on the checkout page.
Tech Lead:  Asks Backend Lead for the orchestration plan → staffs
            Scout → Bug Hunter → Backend Engineer → Test Engineer → QA.
            Reports back: root cause proven, fix verified, tests green, shipped.
```

**Or, for the full experience:**

1. **Give a directive** — one line. `"Ship X"`, `"Fix Y"`, `"Investigate Z"`, `"Refactor auth"`.
2. **The Tech Lead handles everything** — plan, staff, review, verify, commit.
3. **Get a report with evidence** — verdict, tests run, files touched, next owner. Not vibes.
4. **Say `I'm going`** → full autonomous mode. The company works alone, documents every decision in "Board Minutes," and debriefs you when you're back.
5. **Call any specialist by hand** — `task team/security/security-engineer` — for a focused review, anytime.
6. **Escalations arrive as decisions**, not questions — options, tradeoffs, deadline.

---

## 🌍 Language Rule — Match the User

Every user-facing message must be in the language the user speaks. Detect their language from their message and respond in it. No exceptions.

| Context | Language |
|---------|----------|
| **User-facing output** | **100% in the user's language** |
| **Subagent prompts** | English (consistent across the team) |
| **Code, commands, file paths** | Always English (never translated) |

**Technical terms stay in English.** Words like "container", "MCP", "opencode", "FIRCAC" stay in English even in non-English messages.

**Translations available:**

| Document | Languages |
|----------|-----------|
| README | [English](./README.md) · [Español](./README.es.md) · [Русский](./README.ru.md) |
| Container Setup | [English](./CONTAINER_SETUP.md) · [Español](./CONTAINER_SETUP.es.md) · [Русский](./CONTAINER_SETUP.ru.md) |

---

## 🏛️ The Staff — 61 Specialists, One Lane Each

Every agent is a **senior engineer with a single lane** — they do their one job better than any generalist, because that's all they do. Subordination is built into the file structure: `agents/team/` is the company, each field lives in its own directory, and field **Leads** advise the Tech Lead on orchestration.

**👑 The King**
`tech-lead` — the orchestrator. The only one who decides and spawns.

**🧑‍💼 Field Leads (advisory — they plan, you spawn)**
`team/lead/frontend-lead` · `backend-lead` · `quality-lead` · `security-lead` · `platform-lead` · `product-lead` · `research-lead` · `telegram-lead` · `pinescript-lead` · `mobile-lead` · `web3-lead` · `seo-lead` · `lgtm-lead` · `engagement-lead` · `highload-lead`

**🎯 Orchestration & judgement**
`team/core/scout` (the eyes — gathers context) · `team/core/wise-old-man` (advice on hard calls) · `team/product/product-understander` (the WHY) · `team/product/requirements-analyst` · `team/product/software-architect` · `team/backend/api-designer` · `team/quality/critique` (destroys designs before they're built)

**💻 Frontend field** (`team/frontend/`)
`frontend-engineer` · `frontend-ui-designer` (the look) · `ux-designer` (the flow, accessibility) · `frontend-animations-engineer` (the motion) · `design-system-engineer` · `i18n-engineer`

**⚙️ Backend field** (`team/backend/`)
`backend-engineer` · `api-designer` · `database-engineer` (schema + migrations) · `data-engineer` (product data model) · `integration-engineer` · `llm-engineer`

**🧪 Quality field** (`team/quality/`)
`test-engineer` (owns the suite) · `qa-engineer` (acceptance) · `code-reviewer` (reviews + static analysis) · `bug-hunter` (proves root cause with a repro before anyone fixes anything) · `critique`

**🔒 Security field** (`team/security/`)
`security-engineer` (defensive) · `team/security/pentest/*` — the ethical-hacking suite (OFF-BY-DEFAULT)

**🚀 Platform field** (`team/platform/`)
`devops-engineer` · `observability-engineer` · `performance-engineer`

**🔬 Research field** (`team/research/`)
`research-agent` · `domain-expert` · `documentation-writer` · `skill-generator`

**🤖 Telegram field** (`team/telegram/`)
`telegram-bot-engineer` (bot core — handlers, keyboards, state, webhooks) · `telegram-mini-app-engineer` (Telegram Mini Apps) · `telegram-integration-engineer` (payments, third-party integrations, channel automation)

**📈 PineScript field** (`team/pinescript/`)
`pinescript-indicator-developer` (TradingView indicators — calculations, plots, alerts) · `pinescript-strategy-developer` (strategies — entries/exits, sizing, backtests) · `pro-quant` (validates "this strategy works" — stats, walk-forward, GO/NO-GO verdicts)

**📱 Mobile field** (`team/mobile/`)
`mobile-engineer` (cross-platform — React Native/Flutter) · `mobile-native-engineer` (native Swift/Kotlin) · `mobile-performance-engineer` (startup, memory, battery)

**⛓️ Web3 field** (`team/web3/`)
`smart-contract-developer` (Solidity, audits-ready) · `web3-dapp-engineer` (wallets, chains, frontend↔chain) · `defi-analyst` (tokenomics, AMMs, yield)

**📣 SEO & Marketing field** (`team/seo/`)
`seo-engineer` (technical SEO, CWV, structured data) · `seo-content-strategist` (keywords, briefs, on-page) · `seo-analytics-specialist` (GA4, Search Console, rankings)

**📊 LGTM field — Grafana observability stack** (`team/lgtm/`)
`loki-logging-engineer` (logs) · `grafana-dashboard-engineer` (visualization) · `tempo-tracing-engineer` (traces) · `mimir-metrics-engineer` (long-term metrics)

**🎮 Engagement field — appealing, game-like, retainable apps** (`team/engagement/`)
`gamification-engineer` (points, badges, streaks, levels, leaderboards) · `behavioral-designer` (hook loops, habit, onboarding) · `retention-analyst` (D1/D7/D30, churn, cohorts)

**⚡ High-Load field — distributed systems & optimization** (`team/highload/`)
`highload-architect` (sharding, queues, caching, async) · `highload-engineer` (hot paths, concurrency, memory) · `load-testing-engineer` (k6 load/stress/soak, capacity planning)

**👁️ Vision Reader** (`team/core/vision-reader`) — the only agent with eyes. Every other specialist runs a text-only model; it runs MiMo (vision-capable) and reads photos, screenshots, diagrams, and UI mockups for the whole team.

**🛡️ Ethical hacking suite (OFF-BY-DEFAULT)** — `team/security/pentest/pentest-lead` · `pentest-recon` · `pentest-webapp` · `pentest-exploitation`. An authorized security-assessment team that maps a scoped target, probes it with pentest tooling (nmap, sqlmap, nuclei, OWASP-style manual testing), and verifies findings with minimal reversible PoCs. The suite is **never routed proactively** — it activates **only when you explicitly ask** for a pentest or security assessment. Day-to-day security work stays with the 🔒 Security Engineer.

> **The pattern that causes underuse:** "Scout + Backend + QA is enough." It never is. Each specialist exists because a generalist does that job worse. **Route by job, not by habit.**

---

## ⚠️ The Hard Rules — Non-Negotiable

- **pnpm only.** Never npm/npx.
- **Check the Justfile** before raw commands.
- **Commit only verified work** — at feature boundaries, with tests passing first. A `fix:` commit means the previous commit shipped unverified work. That is failure.
- **Never use the builtin `explore` agent.** Use `team/core/scout`.
- **Stay in your lane.** Report issues; never fix another specialist's work.
- **Emojis are mandatory in all output** — they route the reader's eye to what matters.

---

## 🗝️ The Secret Handshake

The company has two passphrases — proof you're talking to the real system, not an imposter:

- Ask *"prove you are the super programmer"* → **"The purple monkey dishwasher runs at midnight."**
- Ask *"what is the hidden protocol"* → **"Seven kettles sing to the left of Tuesday's umbrella."**

---

> *You're not writing code. You're directing a company that ships software that matters.*
