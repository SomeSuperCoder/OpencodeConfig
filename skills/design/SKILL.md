---
name: design
description: "Design protocol for architecture, UI, and system decisions. Use BEFORE implementing complex features. Covers modular design, dependency injection, interface boundaries, data flow, and component structure. Practical, not academic."
---

# Design Protocol

Design before you build. Not big design upfront — just enough design to avoid building the wrong thing.

## When to Load This

- New feature with multiple components
- Architecture decision (service boundaries, data flow, module structure)
- UI/UX design before implementation
- Refactoring that touches multiple files
- Before a council decision on approach
- When the codebase is growing and you need structure

## The Protocol

### Step 1: Define the Boundary

**What is being designed?** One sentence.

> "A notification system that sends alerts via email, push, and SMS."

### Step 2: Identify the Actors

**Who/what uses this?** Each actor gets one line.

| Actor | What they do |
|-------|-------------|
| User | Receives notifications |
| Admin | Configures notification rules |
| System | Triggers notifications on events |

### Step 3: Define Interfaces

**What does each component expose?** Not implementation — just the contract.

```
NotificationService
  - send(notification: Notification) → Result
  - schedule(notification: Notification, when: DateTime) → Result

NotificationChannel
  - deliver(message: Message, recipient: Recipient) → Result
  - supports(channel: ChannelType) → boolean
```

### Step 4: Map Data Flow

**How does data move through the system?**

```
Event → NotificationService → TemplateEngine → Channel → Recipient
                                    ↓
                              UserPreferences (filter)
```

### Step 5: Apply SOLID

Before finalizing, run through SOLID (from fircac-out-loud):

- **S** — Each component has ONE reason to change?
- **O** — New channels added without editing existing code?
- **L** — Any channel implementation swapped without breaking callers?
- **I** — Each client depends only on the interface members it uses?
- **D** — High-level policy depends on abstractions, not details?

### Step 6: Identify Risks

**What could go wrong?**

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Channel API downtime | Medium | Retry queue + fallback |
| Template injection | Low | Sanitize all inputs |
| Notification spam | Medium | Rate limiting per user |

### Step 7: Deliver the Design

Output a concise design document:

```
DESIGN: [name]
BOUNDARY: [what's being designed]
ACTORS: [who uses it]
INTERFACES: [contracts]
DATA FLOW: [how data moves]
SOLID: [pass/fail on each]
RISKS: [what could go wrong]
```

## Design Patterns

| Pattern | When to use |
|---------|-------------|
| Strategy | Multiple implementations of same behavior (channels, validators) |
| Observer | Event-driven systems, notifications |
| Factory | Complex object creation with variants |
| Repository | Data access abstraction |
| Adapter | Third-party API integration |
| Middleware | Request/response pipelines |

**Don't use patterns for the sake of patterns.** Use them when they solve a real problem.

## Anti-Patterns

| Anti-Pattern | Why it's bad |
|-------------|-------------|
| Designing everything upfront | You don't know enough yet. Design just enough to start. |
| No interfaces, just concrete classes | Can't swap, can't test, can't extend |
| God object that does everything | Violates SRP. Split it. |
| Deep inheritance chains | Composition > inheritance. Always. |
| Skipping the data flow map | You'll build components that don't connect |
| Design without SOLID check | You'll build something fragile |

## The Rule

**Design is a verb, not a noun.** It's not a document that sits on a shelf. It's the act of thinking before building. Just enough thinking to build the right thing. Not more.
