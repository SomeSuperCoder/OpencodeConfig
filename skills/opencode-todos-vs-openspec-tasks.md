# OpenCode Todos vs OpenSpec Tasks

**Understanding the difference between OpenCode's built-in todo system and OpenSpec tasks.**

## Quick Reference

| Feature | OpenCode Todos | OpenSpec Tasks |
|---------|----------------|----------------|
| **Purpose** | Track progress | Define implementation |
| **Scope** | Session-level | Project-level |
| **Detail** | Simple checklist | Detailed specs |
| **Ownership** | Anyone | Tech Lead owns |
| **Persistence** | Session only | Saved in AgentMemory |
| **When to Use** | Quick tracking | Feature development |

## OpenCode Built-in Todos

**What they are:** Simple checklist items tracked by OpenCode's `todowrite` tool.

**When to use:**
- Quick task tracking
- Session-level progress
- Simple checklists
- Temporary notes
- "What am I doing right now?"

**Example:**
```markdown
## TODO
- [ ] Read the file
- [ ] Edit the function
- [ ] Run tests
- [ ] Commit changes
```

**Characteristics:**
- Lightweight
- Session-only
- No persistence
- Anyone can create
- Simple status: pending, in_progress, completed

## OpenSpec Tasks

**What they are:** Detailed implementation specifications created by Tech Lead via openspec-proposal-creation.

**When to use:**
- Feature development
- Bug fixes
- Refactoring
- Any multi-step implementation
- "What are we building?"

**Example:**
```markdown
## OpenSpec Task: User Authentication

### Context
[From Context-Gatherer: codebase analysis, research, patterns]

### Requirements
- Implement JWT authentication
- Add refresh token support
- Rate limiting on auth endpoints

### Implementation Plan
- Backend Engineer: Auth service + middleware
- Frontend Engineer: Login/register UI
- Security Engineer: Review auth flow
- Test Engineer: E2E auth tests

### Success Criteria
- [ ] Login works
- [ ] Token refresh works
- [ ] Rate limiting active
- [ ] Tests pass
```

**Characteristics:**
- Detailed specifications
- Project-level scope
- Saved in AgentMemory
- Tech Lead owns creation
- Implementation-focused

## Decision Guide

### Use OpenCode Todos When:
- Task is simple (< 5 minutes)
- Task is session-only
- Task doesn't need specs
- Task is just tracking progress
- Task is temporary

### Use OpenSpec Tasks When:
- Task is complex (> 5 minutes)
- Task spans multiple files
- Task needs specifications
- Task involves multiple agents
- Task is a feature/bugfix/refactor
- Task needs to be remembered

## The Rule

**OpenCode Todos:** "What am I doing now?"
**OpenSpec Tasks:** "What are we building?"

## Integration

### How They Work Together
1. **Tech Lead** creates OpenSpec tasks for features
2. **Subagents** receive OpenSpec tasks and implement
3. **Anyone** uses OpenCode todos for quick tracking
4. **Tech Lead** saves OpenSpec tasks in AgentMemory

### Workflow
```
1. User request → Tech Lead
2. Tech Lead → OpenSpec task (openspec-proposal-creation)
3. Tech Lead → Announces plan with OpenSpec task
4. Subagents → Implement using openspec-implementation
5. Subagents → Use OpenCode todos for quick tracking
6. Tech Lead → Save OpenSpec task in AgentMemory
```
