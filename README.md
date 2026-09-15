# Opencode — The Supervisor System

A recursive AI agent system inspired by Recursive Language Models (RLMs). The Supervisor orchestrates subagents, each with isolated context, writing state to external files (handoffs/ + ops_board.json). No context rot. No orphaned work. No wasted tokens.

## Architecture

```
User → Supervisor → Subagents (spawned on demand)
                         ↓
                    harness/handoffs/ (shared state library)
                    harness/ops_board.json (pipeline state)
```

## Agents

| Agent | Role | Edit | Write |
|-------|------|------|-------|
| **Supervisor** | Orchestrator — plans, spawns, reviews, reports | ❌ | ❌ |
| **Scout** | Gathers context — codebase facts, call chains, blast radius | ❌ | ✅ |
| **Advisor** | Advises on decisions — frames options, analyzes tradeoffs | ❌ | ✅ |
| **Senior Developer** | Implements code — writes focused, clean changes | ✅ | ✅ |
| **Tester** | Writes and runs tests — unit, integration, e2e | ✅ | ✅ |
| **Critique** | Reviews designs and code — attacks assumptions, finds risks | ❌ | ✅ |
| **Pentester** | Security testing — vulnerabilities, OWASP Top 10 | ✅ | ✅ |
| **Docs Writer** | Writes documentation — READMEs, API docs, ADRs | ❌ | ✅ |
| **Chore** | Git ops + maintenance — commits, pushes, safe shell commands | ❌ | ✅ |
| **Ops Board Manager** | Reads/writes ops board — lightning fast | ✅ | ✅ |

## Skills

| Skill | Purpose |
|-------|---------|
| `anti-drift` | Mandatory on every request — prevents scope creep |
| `fircac-out-loud` | Obligatory reasoning — FIRCAC, ABC, SOLID protocols |
| `grill-me` | Smart clarification — scout first, ask only gaps |
| `council` | Parallel specialist perspectives for complex decisions |
| `design` | UI/UX design protocol for frontend |
| `wave-orchestration` | Dynamic wave planning for multi-agent tasks |
| `handoff-output` | Structured JSON output protocol for all agents |
| `git` | Mandatory git protocol — commit before every response |
| `idea-generator` | Creative brainstorming — out-of-the-box thinking |
| `backend-patterns` | Senior backend architectural patterns reference |
| `frontend-patterns` | Senior frontend architectural patterns reference |
| `devops-patterns` | Senior DevOps patterns reference |
| `liveops-observability` | Production observability patterns |
| `cybersec-patterns` | Cybersecurity patterns for developers and pentesters |

## Core Loop

```
① ANTI-DRIFT — Every request, no exceptions
② PARSE — What does the user want?
③ INVESTIGATE — Scout before you ask
④ ASK ONLY GAPS — 2-3 questions max, with defaults
⑤ PLAN — Decompose, identify dependencies, sequence
⑥ RESTATE — Explain plan, wait for confirmation
⑦ SPAWN — Launch agents per plan
⑧ COLLECT — Read handoff JSONs
⑨ REVIEW — Does result match requirement?
⑩ REPORT — Present to user
⑪ GIT — Commit before ending. Always.
```

## System Beliefs

- **External state over internal tokens** — handoffs are the system's brain
- **Decompose before you act** — hardest part is breaking problems into pieces
- **Isolate context ruthlessly** — context rot is the #1 enemy
- **Never proceed on hope** — verify between every wave
- **Spend tokens like money** — budget awareness is not optional
- **Adapt or die** — plan won't survive contact with reality

## Handoffs

Every agent writes structured JSON at `harness/handoffs/<agent_id>/<name>.json`. The Supervisor reads these. Any agent can read any handoff. It's the shared state library.

## Getting Started

1. This is an opencode configuration — use with [opencode](https://opencode.ai)
2. The Supervisor is the default agent (`opencode.json` → `default_agent: team/supervisor`)
3. Talk to the Supervisor. It plans, spawns agents, reviews output, reports results.

## License

MIT
