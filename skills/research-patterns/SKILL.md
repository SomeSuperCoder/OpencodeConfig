---
name: research-patterns
description: "Research methodology, library evaluation, API discovery. Use when researching libraries, comparing frameworks, finding best practices, or discovering APIs."
---

# Research Patterns

Load this skill when researching libraries, frameworks, or best practices.

## Research Framework
1. **Define criteria** — What matters? (performance, maintenance, community, DX)
2. **Search broadly** — Tavily for multiple sources
3. **Compare objectively** — Pros, cons, tradeoffs
4. **Validate** — Check GitHub stars, issues, last commit date
5. **Recommend** — Best option with rationale

## Library Evaluation Checklist
| Criteria | Question |
|----------|----------|
| Maintenance | Last commit date? Open issues? |
| Community | Stars? Contributors? Discord activity? |
| Performance | Benchmarks available? |
| TypeScript | Type definitions included? |
| Bundle size | How much does it add? |
| License | Compatible with project? |
| Documentation | Comprehensive? Examples? |

## Research Output Format
```markdown
## Research Summary

### Question
[What we're trying to solve]

### Options Found
| Option | Pros | Cons | Maintenance |
|--------|------|------|-------------|

### Recommendation
[Best option with rationale]

### Resources
[Links to documentation]
```

## Common Research Queries
| Topic | Query Pattern |
|-------|---------------|
| Library comparison | "X vs Y comparison 2024" |
| Best practices | "how to do X properly in [framework]" |
| API docs | "[library] API documentation" |
| Examples | "[library] [feature] example" |

## Integration
- **MCPs:** Tavily (primary for search/extraction)
- **AgentMemory:** Save research findings for future reference
