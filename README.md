# 🏢 The Opencode Software Company

> **Stop prompting an assistant. Start directing a company.**

**🌐 Languages:** [English](./README.md) · [Español (España)](./README.es.md) · [Русский](./README.ru.md)

One AI coding CLI becomes a **self-organizing software firm** — a Tech Lead who commands, 8 field Leads who orchestrate, 47 senior specialists who execute, and a microtask pipeline so fast that a full feature ships in minutes, not hours. Every change is tested. Every change is documented. Every change is verified before it touches your codebase.

**You are the Director. You say what matters. It does the rest.**

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
| 🧑‍💼 **8 Field Leads** | `team/lead/*` | Advise on their field — plan microtasks, recommend specialist IDs, NEVER spawn |
| 👥 **43 Specialists** | Senior engineers | Do ONE microtask, prove it, hand it off, stop |

**Directives flow DOWN. Reports flow UP. Field Leads advise; the Team Lead spawns. Nobody crosses the chain of command.**

```
         👑 DIRECTOR (you)
              │  "Ship the export feature" ↓
         🧠 TEAM LEAD
              │  asks for orchestration advice ↓
         🧑‍💼 FIELD LEADS           recommend specialist IDs ↑
              ▼
         👥 43 SPECIALISTS         each does ONE microtask
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

## 🏛️ The Staff — 43 Specialists, One Lane Each

Every agent is a **senior engineer with a single lane** — they do their one job better than any generalist, because that's all they do. Subordination is built into the file structure: `agents/team/` is the company, each field lives in its own directory, and field **Leads** advise the Tech Lead on orchestration.

**👑 The King**
`tech-lead` — the orchestrator. The only one who decides and spawns.

**🧑‍💼 Field Leads (advisory — they plan, you spawn)**
`team/lead/frontend-lead` · `backend-lead` · `quality-lead` · `security-lead` · `platform-lead` · `product-lead` · `research-lead` · `telegram-lead`

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

**👁️ Vision Reader** (`team/core/vision-reader`) — the only agent with eyes. Every other specialist runs a text-only model; it runs MiMo (vision-capable) and reads photos, screenshots, diagrams, and UI mockups for the whole team.

**🛡️ Ethical hacking suite (OFF-BY-DEFAULT)** — `team/security/pentest/pentest-lead` · `pentest-recon` · `pentest-webapp` · `pentest-exploitation`. An authorized security-assessment team that maps a scoped target, probes it with pentest tooling (nmap, sqlmap, nuclei, OWASP-style manual testing), and verifies findings with minimal reversible PoCs. The suite is **never routed proactively** — it activates **only when you explicitly ask** for a pentest or security assessment. Day-to-day security work stays with the 🔒 Security Engineer.

> **The pattern that causes underuse:** "Scout + Backend + QA is enough." It never is. Each specialist exists because a generalist does that job worse. **Route by job, not by habit.**

---

## 🧰 The Arsenal — Skills, Loaded On Demand

17 pattern skills, never pre-loaded, pulled in the instant a microtask needs them:

`fircac-out-loud` (reasoning + verification) · `testing-patterns` · `api-patterns` · `error-patterns` · `state-patterns` · `caching-patterns` · `refactoring-patterns` · `security-patterns` · `a11y-patterns` · `algorithm-patterns` · `domain-knowledge` · `compliance-patterns` · `git-patterns` · `research-patterns` · `performance-patterns` · `find-skills` · `impeccable` (the design-craft standard — **DESIGN.md is law** for every frontend agent)

**The scatter principle:** AGENTS.md = the universal floor. Skills = deep, rare, on-demand. Agents = only what's role-specific. The Team Lead is the one exception — its protocols live inline because it uses them every single session.

---

## 🚀 Run the Company — How It Feels From Your Desk

```
You:        Fix the payment bug on the checkout page.
Tech Lead:  Asks Backend Lead for the orchestration plan → staffs
            Bug Hunter → Backend Engineer → Test Engineer → QA.
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

## 📁 The Machine Room

```
 ~/.config/opencode/
├── README.md           ← you are here
├── AGENTS.md           ← the constitution (every agent obeys it)
├── DIRECTOR.md         ← your playbook — how to command the company
├── opencode.jsonc      ← config: MCP servers, default agent, plugins
├── agents/
│   └── team/                          ← the company (the `team/*` agent namespace)
│       ├── tech-lead.md               ← THE KING — the orchestrator (default agent)
│       ├── lead/                      ← 🧑‍💼 FIELD LEADS (advisory — plan, never spawn)
│       │   ├── frontend-lead.md · backend-lead.md · quality-lead.md
│       │   └── security-lead.md · platform-lead.md · product-lead.md · research-lead.md · telegram-lead.md
│       ├── core/                      ← cross-cutting (scout · wise-old-man · vision-reader)
│       ├── frontend/                  ← engineer · ui-designer · ux-designer · design-system · animations · i18n
│       ├── backend/                   ← engineer · api-designer · database · data · integration · llm
│       ├── quality/                   ← test · qa · code-reviewer · bug-hunter · critique
│       ├── security/                  ← security-engineer · pentest/ (⛔ off-by-default suite)
│       ├── platform/                  ← devops · observability · performance
│       ├── product/                   ← product-understander · requirements · architect · refactoring
│       ├── research/                  ← research-agent · domain-expert · documentation · skill-generator
│       └── telegram/                  ← bot-engineer · mini-app-engineer · integration-engineer
└── skills/
    └── (17 pattern skills, loaded on demand)
```

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
