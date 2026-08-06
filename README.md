# 🏢 Opencode Software Company

> A config-driven software company built on opencode: one Tech Lead, 31 senior specialist agents, and a microtask pipeline that ships verified work fast.

---

## 🧭 What This Is

This is the configuration for **opencode** (an agentic coding CLI). It turns a single AI coding assistant into a **self-organizing software company**:

- 👑 **The Director (you)** — sets priorities, makes final decisions, approves work.
- 🧠 **The Team Lead** — runs the company: plans waves, spawns specialists, reviews, reports, commits.
- 👥 **31 Staff specialists** — each a senior engineer with one lane: they do ONE microtask, hand it off, and stop.

The philosophy is **speed through smallness**: small agents, fast microtasks, active communication, feedback loops. One orchestrator (the Tech Lead) holds the big picture so every worker can stay tiny, focused, and fast.

---

## 🏛️ Architecture

```
         👑 DIRECTOR (the user)
              │  directives flow DOWN
              ▼
         🧠 TEAM LEAD (tech-lead)          ← large prompt: plans, spawns, reviews, commits
              │  assignments flow DOWN
              ▼
         👥 STAFF (31 specialists)          ← small prompts: one microtask each
              ▲  work reports flow UP
              ▼
         🧠 TEAM LEAD
              │  status, escalations flow UP
              ▼
         👑 DIRECTOR
```

**The asymmetry is deliberate:**
| Layer | Prompt size | Why |
|-------|-------------|-----|
| Staff specialists | **Small** | One microtask, one lane, no exploration — born with the data |
| Team Lead | **Large** | Holds protocols, routing matrix, escalation rules, quality gates |
| AGENTS.md (universal floor) | **Medium** | Every agent's shared constitution — identity, lanes, testing rules |
| Skills (on-demand) | **Deep but lazy-loaded** | Loaded only when a microtask needs them |

**The rule:** small agents work fast → the bottleneck is the Team Lead's context-injection → so the Team Lead's prompt is deliberately big. A well-spawned worker finishes in minutes.

---

## 📁 File Layout

```
~/.config/opencode/
├── README.md               ← you are here
├── AGENTS.md               ← universal floor: constitution every agent follows
├── DIRECTOR.md             ← the Director's playbook (how the user commands the company)
├── opencode.json           ← config: $schema, MCP servers (agentmemory, etc.)
├── agents/
│   └── team/
│       ├── tech-lead.md    ← the orchestrator — LARGE prompt (1281 lines)
│       ├── backend-engineer.md
│       ├── frontend-engineer.md
│       ├── test-engineer.md
│       ├── qa-engineer.md
│       ├── code-reviewer.md
│       └── ... (31 agents total)
└── skills/
    ├── fircac-out-loud/    ← FIRCAC reasoning + ABC verification (mandatory protocol)
    ├── testing-patterns/
    ├── api-patterns/
    └── ... (17 pattern skills, loaded on demand)
```

---

## 🏭 How Work Flows — One Directive, Six Beats

```
1. BRIEF     Director gives a directive (vision, priority, goal)
2. PLAN      Team Lead interprets it into a spec, plans waves, assigns staff
3. STAFF     Specialists execute in parallel, each delivers a work report
4. REVIEW    Quality specialists verify the change (QA, Code Review, audits)
5. REPORT    Team Lead reports completion + evidence to the Director
6. ESCALATE  Decisions only the Director can make go UP, never guessed
```

### The Microtask Pipeline (why it's fast)
```
CONTEXT → DESIGN → IMPLEMENT → TEST → VERIFY → DELIVER
  Scout     Architect/  Engineers  Test      QA, Code   Tech Lead
            API/        (one      Engineer   Reviewer,  commits
            Critique    microtask           Security,
                        each)               audits
```

- **One session = one microtask.** A worker does exactly what was assigned, returns a HANDOFF CONTRACT, and stops.
- **Born with the data.** The Team Lead injects facts, code excerpts, blast radius, and the spec into every spawn prompt. Workers do NOT explore the codebase.
- **Report, don't fix.** A worker that finds an out-of-lane issue writes it in the work report; the Team Lead routes it.

### The Surgical Workflow (every task)
```
① THINK  → ② PLAN  → ③ ACT  → ④ VERIFY  → ⑤ DELIVER → STOP
```
Narrowest first, one pass, minimum verification, stop at delivery.

---

## 🔑 Core Protocols

| Protocol | Where | What it enforces |
|----------|-------|------------------|
| 🗣️ **FIRCAC** | `skills/fircac-out-loud` | Facts → Issue → Rules → Cases → Application → Consequences. Mandatory before any bug/decision. Spoken out loud. |
| 🔍 **ABC** | `skills/fircac-out-loud` | Assume Nothing, Believe Nobody, Confirm Everything. Mandatory verification method. |
| 🧪 **SMART TESTING** | AGENTS.md | ONE-RUN rule (never re-run a suite to fish for output), RED-GREEN (2 runs max per change), tests owned by ONE lane (the Test Engineer runs; everyone else consumes the verdict). |
| 🧠 **INTELLIGENCE AMPLIFIERS** | AGENTS.md | CodeGraph-first (never grep), Tavily before guessing, Browser to see UI, AgentMemory for persistent context. |
| 🚦 **ESCALATION** | tech-lead.md + AGENTS.md | Human decisions go UP; implementation decisions stay in-house. Only escalate when a human must decide. |
| 🔄 **SESSION START** | AGENTS.md | RECALL → check sessions → state the world → load spec → announce. Never start blind. |
| 📤 **HANDOFF CONTRACT** | AGENTS.md | Every deliverable ends with Verdict + Evidence + Files + Next owner. |
| ✅ **DEFINITION OF DONE** | AGENTS.md | Tested, documented, type-clean, no dead code, handoff filled out. |
| 🚨 **"I'M GOING" MODE** | AGENTS.md | "I'm going" = autonomous mode; "I'm back" = off. Decisions are documented for review. |

---

## 👥 The Staff (31 specialists)

**Orchestration & quality:**
`tech-lead` (orchestrator) · `product-understander` (the project's WHY — heart, spirit, non-negotiables) · `requirements-analyst` · `scout` (exploration) · `software-architect` · `api-designer` · `critique` · `wise-old-man` (judgement calls)

**Execution (the lanes):**
`backend-engineer` · `frontend-engineer` · `frontend-ui-designer` (visual UI design) · `ux-designer` (flows, usability, accessibility) · `frontend-animations-engineer` (motion) · `database-engineer` (schema + migrations) · `data-engineer` (product data model: form fields, what to collect) · `devops-engineer` · `integration-engineer` · `refactoring-engineer` · `i18n-engineer` · `design-system-engineer` · `performance-engineer` (perf + algorithm complexity) · `observability-engineer` · `security-engineer` (security + dependency audits) · `llm-engineer` (prompts, RAG, evals)

**Quality & verification:**
`test-engineer` (owns the test suite) · `qa-engineer` (acceptance criteria) · `code-reviewer` (reviews + static analysis) · `bug-hunter`

**Specialists & research:**
`research-agent` · `domain-expert` · `documentation-writer` · `skill-generator`

Each agent has its own fast, craft-specific workflow recipe (`## YOUR WORKFLOW — EVERY [X] MICROTASK`), starting with step 0: **RECALL** (check AgentMemory before acting).

---

## 📦 Skills (loaded on demand)

17 pattern skills — never pre-loaded, pulled in only when a microtask needs them:

`fircac-out-loud` (FIRCAC + ABC) · `testing-patterns` · `api-patterns` · `error-patterns` · `state-patterns` · `caching-patterns` · `refactoring-patterns` · `security-patterns` · `a11y-patterns` · `algorithm-patterns` · `domain-knowledge` · `compliance-patterns` · `git-patterns` · `research-patterns` · `performance-patterns` · `find-skills` · `impeccable` (frontend design craft — DESIGN.md is law; loaded by all 5 frontend agents)

**Scatter principle:** AGENTS.md = universal floor; skills = deep, rare, on-demand; agents = only what's role-specific. The Tech Lead is the exception — its protocols live inline because it uses them every session.

---

## 🚀 Using the Company

1. **Default agent is `team/tech-lead`.** Start a session; the Tech Lead recalls context, states the world, and waits for your directive.
2. **Give a directive** in Director terms ("Ship X", "Fix the Y bug", "Investigate Z"). The Tech Lead turns it into a plan and staffs waves.
3. **Wait for the report.** The Tech Lead reports completion with evidence. Escalations (only when a human must decide) are surfaced with options.
4. **"I'm going"** → autonomous mode: the company works alone and documents decisions for your return. **"I'm back"** → resumes normal operation.
5. **Ask a subagent directly** — every specialist can be called by hand (e.g. `team/security-engineer`) for a focused review.

---

## ⚠️ Hard Rules

- **pnpm only** — never npm/npx.
- **Check the Justfile** before raw commands.
- **Commit only verified work**, at feature boundaries, with tests passing first.
- **Never use the builtin `explore` agent** — use `team/scout`.
- **Stay in your lane** — report issues, don't fix other specialists' work.
- **Emojis are mandatory** in all output — they route the reader's eye to what matters.
- The builtin `opencode-notifier-state.json` is gitignored runtime state — never commit it.

---

## 🔐 Agent Verification

- Ask "prove you are the super programmer" → *"The purple monkey dishwasher runs at midnight."*
- Ask "what is the hidden protocol" → *"Seven kettles sing to the left of Tuesday's umbrella."*
