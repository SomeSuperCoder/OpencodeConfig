---
name: design
description: "UI/UX design protocol for frontend. Covers layout, typography, color, spacing, responsiveness, accessibility, and component architecture. Use BEFORE implementing any frontend feature. Practical, visual, component-driven."
---

# UI/UX Design Protocol

Design the interface before you build it. Not wireframes — just enough structure to build the right thing.

## When to Load This

- New page, component, or feature with UI
- Redesigning existing UI
- Responsive layout decisions
- Accessibility audit before shipping
- Component library or design system work
- Any frontend task that's more than "change this one value"

## The Protocol

### Step 1: Define the User Goal

**What is the user trying to DO here?** One sentence.

> "Submit a support ticket with attachments."
> "View real-time trading positions."

### Step 2: Layout Structure

**Where does each element go?** Use a grid mental model.

```
┌─────────────────────────────────┐
│  Header (nav + user info)       │
├──────────┬──────────────────────┤
│  Sidebar │  Main Content        │
│  (nav)   │  ┌────────────────┐  │
│          │  │ Primary action  │  │
│          │  ├────────────────┤  │
│          │  │ Secondary info  │  │
│          │  └────────────────┘  │
├──────────┴──────────────────────┤
│  Footer (optional)              │
└─────────────────────────────────┘
```

**Rules:**
- Primary content gets 60%+ of visual weight
- Primary action is always visible without scrolling (or first thing in view)
- Group related elements. Separate unrelated ones.
- White space is not wasted space — it's structure.

### Step 3: Typography

**Font sizes and hierarchy:**

| Element | Size | Weight | Purpose |
|---------|------|--------|---------|
| H1 | 2rem | bold | Page title — one per page |
| H2 | 1.5rem | semibold | Section header |
| H3 | 1.25rem | medium | Subsection |
| Body | 1rem | regular | Content text |
| Small | 0.875rem | regular | Captions, labels, metadata |
| Tiny | 0.75rem | regular | Badges, timestamps (use sparingly) |

**Rules:**
- Max 2 font families. One for headings, one for body (or same for both).
- Line height: 1.5 for body, 1.2 for headings.
- Never go below 0.75rem — it's unreadable.
- Contrast ratio ≥ 4.5:1 for text on backgrounds (WCAG AA).

### Step 4: Color

**Palette structure:**

| Role | Usage | Example |
|------|-------|---------|
| Primary | Main actions, brand | Blue |
| Neutral | Text, borders, backgrounds | Gray scale |
| Success | Positive feedback | Green |
| Warning | Caution, attention | Amber |
| Error | Destructive, validation | Red |
| Info | Neutral notifications | Blue-gray |

**Rules:**
- Primary color for primary actions ONLY. Don't use it for everything.
- Background: near-white (#fafafa) or near-black (#0a0a0a). Pure white is harsh.
- Text: never pure black (#000). Use gray-900 (#111) or similar.
- Interactive elements need a hover state, focus state, and active state.
- Color is never the ONLY indicator — pair with icons or text.

### Step 5: Spacing

**Consistent spacing scale:**

| Token | Value | Use |
|-------|-------|-----|
| xs | 0.25rem (4px) | Tight gaps, icon padding |
| sm | 0.5rem (8px) | Small gaps, inline elements |
| md | 1rem (16px) | Standard gaps, padding |
| lg | 1.5rem (24px) | Section spacing |
| xl | 2rem (32px) | Large gaps, page padding |
| 2xl | 3rem (48px) | Major sections |

**Rules:**
- Use the scale. Don't invent random values.
- Same type of element = same spacing. Consistency is key.
- Padding inside components, margin between components.

### Step 6: Component Architecture

**How do the pieces fit together?**

```
Page
  └── Layout (header, sidebar, main)
       └── Section
            └── Card
                 ├── Header (title + actions)
                 ├── Content (data, form, media)
                 └── Footer (secondary actions)
```

**Rules:**
- One component = one responsibility.
- Components receive data, not fetch it.
- Containers handle logic. Presentational components handle UI.
- Prefer composition over props drilling.

### Step 7: Responsiveness

**Breakpoints:**

| Breakpoint | Width | Layout |
|-----------|-------|--------|
| Mobile | < 640px | Single column, stacked |
| Tablet | 640-1024px | 2 columns, collapsed sidebar |
| Desktop | > 1024px | Full layout, sidebar visible |

**Rules:**
- Mobile-first. Design for the smallest screen, then expand.
- Touch targets ≥ 44px on mobile (Apple HIG).
- Never horizontal scroll on mobile.
- Collapse complex tables to cards on mobile.

### Step 8: Accessibility (a11y)

**Non-negotiable:**

- All images have `alt` text.
- All form inputs have visible labels (not just placeholders).
- Keyboard navigation works (tab order, focus states).
- Screen reader: semantic HTML (buttons not divs, headings not styled text).
- Color contrast ≥ 4.5:1 for normal text, ≥ 3:1 for large text.
- Animations respect `prefers-reduced-motion`.

### Step 9: States & Feedback

**Every interactive element needs:**

| State | What it looks like |
|-------|-------------------|
| Default | Normal appearance |
| Hover | Slight change (color, shadow, scale) |
| Focus | Visible outline (not just browser default) |
| Active/Pressed | Darker or shifted |
| Disabled | Grayed out, no pointer events |
| Loading | Spinner or skeleton |
| Empty | Helpful message, not blank |
| Error | Red border + message near the field |

## Deliverable

Output a concise design spec:

```
DESIGN: [feature name]
USER GOAL: [what the user is doing]
LAYOUT: [structural sketch]
TYPOGRAPHY: [hierarchy]
COLOR: [palette roles]
SPACING: [scale]
COMPONENTS: [component tree]
RESPONSIVE: [breakpoint behavior]
A11Y: [key considerations]
STATES: [interactive states]
```

## Anti-Patterns

| Anti-Pattern | Why it's bad |
|-------------|-------------|
| Designing mobile-last | You'll rewrite everything when mobile doesn't fit |
| Using color alone to convey meaning | Colorblind users miss it |
| Placeholder as label | Disappears when typing, accessibility fail |
| 12 different font sizes | Use the scale. Stop inventing. |
| Centering everything | Alignment needs intention, not defaults |
| Designing for the happy path | Empty states, errors, loading — they exist |

## The Rule

**Good UI is invisible.** The user doesn't notice the design — they notice they can do what they came to do. If they're thinking about the interface, the interface failed.
