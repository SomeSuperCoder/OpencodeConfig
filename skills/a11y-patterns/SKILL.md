---
name: a11y-patterns
description: "Accessibility patterns, WCAG compliance, keyboard navigation, screen reader support. Use when implementing UI components, doing accessibility audits, or fixing a11y issues."
---

# Accessibility Patterns

Load this skill when implementing accessible UI or fixing accessibility issues.

## WCAG 2.1 AA Checklist
- [ ] Semantic HTML elements
- [ ] ARIA labels for interactive elements
- [ ] Keyboard navigation works
- [ ] Focus visible on all interactive elements
- [ ] Color contrast ratio ≥ 4.5:1 (text), ≥ 3:1 (large text)
- [ ] Alt text for images
- [ ] Form labels associated with inputs
- [ ] Skip navigation link
- [ ] Error messages associated with fields

## Semantic HTML Quick Reference
```html
<!-- Good -->
<nav>, <main>, <aside>, <article>, <section>, <header>, <footer>
<button>, <a>, <input>, <select>, <textarea>

<!-- Bad -->
<div onclick="...">, <span class="button">
```

## ARIA Patterns
| Pattern | When | Example |
|---------|------|---------|
| `aria-label` | No visible text | Icon buttons |
| `aria-labelledby` | Reference to label | Complex forms |
| `aria-describedby` | Additional info | Help text |
| `aria-live` | Dynamic content | Status messages |
| `aria-expanded` | Collapsible | Dropdowns |
| `aria-hidden` | Decorative | Icons, images |

## Keyboard Navigation
| Key | Action |
|-----|--------|
| Tab | Move forward |
| Shift+Tab | Move backward |
| Enter/Space | Activate button |
| Escape | Close modal/dropdown |
| Arrow keys | Navigate within widget |

## Common Fixes
| Issue | Solution |
|-------|----------|
| Missing labels | `<label>` or `aria-label` |
| No keyboard nav | Add `tabIndex`, handle Enter/Space |
| Poor contrast | Use WebAIM contrast checker |
| Missing landmarks | Use semantic HTML |

## Integration
- **MCPs:** Browser MCP for testing
- **AgentMemory:** Save a11y patterns, common fixes
