---
name: frontend-patterns
description: "Senior frontend architectural patterns reference. Covers state management, component patterns, data fetching, performance, error handling, forms, and more. Use when implementing frontend features, designing components, or reviewing UI architecture."
---

# Frontend Patterns Reference

Patterns for building responsive, performant, maintainable frontends. Not theory — actionable patterns with when-to-use.

---

## State Management

### Pattern: Colocation

**When:** State lives closest to where it's used.

```
Component
  ├── Local state (useState) — UI state (open/closed, hover, active tab)
  ├── Derived state (useMemo) — computed from other state
  └── Server state (React Query/SWR) — fetched data, cache, sync
```

**Rules:**
- Don't lift state higher than needed. Each component owns its state.
- Derived state: compute, don't store. `const fullName = firstName + lastName` not a separate state.
- Server state ≠ application state. Use React Query, not useState for fetched data.
- Global state: only for truly global things (auth, theme, locale). Not "the selected tab on page 3."

### Pattern: Server State Cache (React Query / SWR)

**When:** Fetching data from APIs.

```
useQuery({ queryKey: ['user', id], queryFn: () => fetchUser(id) })
```

**Rules:**
- Stale-while-revalidate: show cached data, refetch in background.
- Cache key: deterministic. `['user', id]` not `['user']`.
- Mutations: use `useMutation` + invalidate related queries.
- Loading/error states: always handle. Never assume success.
- Deduplication: same query key = one network request, shared cache.

### Pattern: URL as State

**When:** Filterable, shareable, bookmarkable UI state.

```
/users?role=admin&page=2&sort=name
```

**Rules:**
- URL params for: search, filters, pagination, active tab, modal open.
- Local state for: hover, animation, form inputs (unsaved).
- Sync URL → state on mount. Sync state → URL on change.
- `useSearchParams` / `useRouter` for clean URL manipulation.

---

## Component Patterns

### Pattern: Composition over Props

**When:** Component needs flexible content/layout.

```jsx
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Actions</Card.Footer>
</Card>
```

**Rules:**
- Children + compound components for layout flexibility.
- Render props for data-dependent rendering.
- Don't pass 10+ props. If you are, decompose.
- Slot pattern: named children for structured content.

### Pattern: Container / Presenter

**When:** Separating data fetching from UI rendering.

```
Container (fetches data, handles logic)
  → passes data + callbacks to
Presenter (renders UI, no side effects)
```

**Rules:**
- Container: hooks, API calls, state management. No markup.
- Presenter: pure render function. Props in, JSX out. Testable.
- Alternative: custom hooks replace containers. Hook handles logic, component handles UI.

### Pattern: Custom Hooks

**When:** Reusable logic across components.

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
```

**Rules:**
- Name starts with `use`. Convention = React knows it's a hook.
- One hook, one concern. `useDebounce`, not `useDebounceAndFetchAndAuth`.
- Return values, not objects with 10 properties.
- Hooks compose: `useUser()` can call `useFetch()` inside.

### Pattern: Controlled vs Uncontrolled

**When:** Form inputs, toggles, any stateful UI.

**Uncontrolled** (default): component manages its own state.
**Controlled**: parent manages state, component receives value + onChange.

**Rules:**
- Default to uncontrolled. Less code, simpler.
- Controlled when: form submission needs value, sibling components need sync, validation rules.
- Never mix. Pick one per input.

---

## Data Fetching

### Pattern: Parallel Fetching

**When:** Multiple independent API calls.

```typescript
const [users, posts, comments] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
  fetchComments(),
]);
```

**Rules:**
- Independent calls: `Promise.all`. Don't serialize what can parallelize.
- Dependent calls: await first, then second. Don't lie about dependencies.
- Partial failure: `Promise.allSettled`. Show what succeeded, retry what failed.

### Pattern: Optimistic Updates

**When:** User action should feel instant (like, vote, toggle).

```
1. Update UI immediately (optimistic)
2. Send request in background
3. If success → done (already updated)
4. If failure → revert UI, show error
```

**Rules:**
- Only for low-risk actions. Not for payments, deletes, irreversible operations.
- Always revert on failure. User must trust the UI.
- Show subtle indicator: "Saving..." or "Syncing..."

### Pattern: Pagination

**When:** Large datasets.

| Type | Use when | How |
|------|----------|-----|
| Offset | Total count known, random access | `?page=2&limit=20` |
| Cursor | Infinite scroll, real-time data | `?cursor=abc123&limit=20` |
| Virtual | 10,000+ items, fixed height | Window only visible items |

**Rules:**
- Offset: simple, but slow on large offsets. Use for admin dashboards.
- Cursor: fast, consistent. Use for feeds, timelines.
- Virtual: only for huge lists with fixed row height. Use `react-window` or `@tanstack/virtual`.
- Always show loading state while fetching next page.

---

## Performance

### Pattern: Memoization

**When:** Expensive computations or stable references.

```typescript
const sorted = useMemo(() => items.sort(compareFn), [items]);
const handleClick = useCallback(() => { /* ... */ }, [dep]);
```

**Rules:**
- useMemo: expensive calculations (>1ms) or data transformations. Not for trivial math.
- useCallback: functions passed to child components or used in useEffect deps.
- Don't memo everything. React is fast. Measure first.
- React.memo: wrap components that receive stable props but re-render often.

### Pattern: Code Splitting

**When:** Large bundles, routes, heavy components.

```typescript
const Dashboard = React.lazy(() => import('./Dashboard'));
```

**Rules:**
- Route-level splitting: each route is a chunk.
- Component-level splitting: modals, editors, charts (heavy things).
- Never split tiny components. Overhead > benefit.
- Suspense + fallback for loading states.

### Pattern: Image Optimization

**When:** Any image in production.

**Rules:**
- Format: WebP/AVIF with JPEG fallback.
- Sizes: srcset for responsive images. Don't load 4K on mobile.
- Lazy: below-fold images use `loading="lazy"`.
- Placeholder: blur hash or skeleton while loading.
- CDN: serve from CDN, not app server.

### Pattern: Bundle Analysis

**When:** Before shipping, when bundle feels large.

**Rules:**
- Bundle analyzer: visualize what's in your bundle.
- Tree shake: import `{ debounce } from 'lodash'` not `import _ from 'lodash'`.
- Dead code: remove unused imports, components, utilities.
- Dependencies: check if heavy deps can be replaced with lighter alternatives.

---

## Error Handling

### Pattern: Error Boundaries

**When:** Catching render errors in component tree.

```
<ErrorBoundary fallback={<Error />}>
  <App />
</ErrorBoundary>
```

**Rules:**
- One per page section, not one giant boundary for everything.
- Fallback: helpful UI, not blank screen. Show what failed, retry button.
- Log error to monitoring (Sentry, etc.) inside the boundary.
- Don't catch event handler errors. Boundaries only catch render errors.

### Pattern: API Error Handling

**When:** Every API call.

```typescript
try {
  const data = await fetchUser(id);
  setUser(data);
} catch (error) {
  if (error.status === 404) setNotFound(true);
  else if (error.status === 401) redirectToLogin();
  else setError(error.message);
}
```

**Rules:**
- Handle every status code you care about: 400, 401, 403, 404, 429, 500.
- Never swallow errors silently. Log + show to user.
- User-facing messages: "Something went wrong" not "TypeError: Cannot read property 'id' of undefined".
- Retry logic: transient errors (503, timeout) → retry. Permanent (400, 404) → don't.

### Pattern: Global Error State

**When:** App-wide error management.

```
ErrorContext
  ├── errors[] — active errors
  ├── addError(message) — show toast
  └── removeError(id) — dismiss toast
```

**Rules:**
- Toast notifications for: transient errors, success confirmations.
- Modal/blocking errors for: critical failures, auth issues.
- Auto-dismiss: 5s for info, 10s for errors, manual dismiss for critical.
- Stack errors: don't replace, append. User sees all recent errors.

---

## Forms

### Pattern: Uncontrolled Form with Validation

**When:** Simple forms, login, search.

```jsx
<form onSubmit={handleSubmit}>
  <input name="email" required type="email" />
  {errors.email && <span>{errors.email}</span>}
</form>
```

**Rules:**
- HTML5 validation first: `required`, `type="email"`, `minLength`.
- Custom validation: on submit, not on every keystroke.
- Error messages: below the field, red text, specific ("Email is required" not "Invalid input").

### Pattern: Controlled Complex Form

**When:** Dynamic forms, conditional fields, multi-step.

```
Formik / React Hook Form
  ├── validation (zod / yup)
  ├── field arrays (add/remove items)
  └── multi-step (wizard)
```

**Rules:**
- React Hook Form for performance (uncontrolled by default).
- Zod for schema validation. Share types between frontend and backend.
- Field arrays: unique keys for each item. Not array index (breaks on reorder).
- Multi-step: persist each step's data. Don't lose progress on back.

### Pattern: Form State Management

**When:** Forms with complex state.

**Rules:**
- Local state for form data. Don't put forms in global store.
- Touched: track which fields user interacted with. Show errors only after touch.
- Dirty: track if form changed from initial values. Warn on navigation away.
- Submitting: disable button + show spinner. Prevent double submit.

---

## Accessibility (a11y)

### Pattern: Keyboard Navigation

**When:** Every interactive element.

**Rules:**
- Tab order: logical, matches visual flow.
- Enter/Space: activate buttons and links.
- Escape: close modals, dropdowns.
- Arrow keys: navigate within groups (tabs, menus, lists).
- Focus visible: never `outline: none` without replacement.

### Pattern: ARIA Labels

**When:** Screen reader support.

```jsx
<button aria-label="Close dialog">✕</button>
<nav aria-label="Main navigation">...</nav>
<div role="alert">Error: form invalid</div>
```

**Rules:**
- Label interactive elements. If it's not a button/link/input, it needs a role.
- `aria-label` for elements without visible text.
- `aria-live="polite"` for dynamic content updates.
- `aria-hidden="true"` for decorative elements.

### Pattern: Focus Management

**When:** Modal opens, route changes, dynamic content.

**Rules:**
- Modal open: focus first focusable element inside.
- Modal close: return focus to trigger element.
- Route change: focus main heading or skip link.
- Dynamic content added: focus it or announce via aria-live.

---

## Animation

### Pattern: CSS Transitions for Micro-interactions

**When:** Hover, focus, active states, simple state changes.

```css
.button {
  transition: background-color 150ms ease, transform 100ms ease;
}
.button:hover {
  background-color: var(--primary-dark);
  transform: translateY(-1px);
}
```

**Rules:**
- Duration: 100-300ms for micro-interactions. Longer feels sluggish.
- Easing: `ease` or `ease-out` for entrances. `ease-in` for exits.
- Respect `prefers-reduced-motion`. Always.
- Don't animate layout properties (width, height, top). Use `transform` and `opacity`.

### Pattern: Page Transitions

**When:** Route changes.

**Rules:**
- Fade: simplest, works everywhere.
- Slide: for navigation direction (left/right based on route depth).
- Avoid: complex animations on every route change. Users navigate fast.
- Loading state: skeleton screen during transition, not spinner.

---

## Anti-Patterns

| Anti-Pattern | Why it's bad | Do this instead |
|-------------|-------------|-----------------|
| Global state for everything | Unnecessary re-renders, complexity | Colocate state, use server cache |
| Prop drilling 5+ levels | Tightly coupled components | Context, composition, custom hooks |
| Fetching in useEffect without cleanup | Memory leaks, race conditions | AbortController, React Query |
| Inline functions in JSX | New reference every render, breaks memo | useCallback, define outside render |
| Large components (500+ lines) | Unreadable, untestable | Decompose into smaller components |
| useState for server data | No caching, no dedup, no sync | React Query / SWR |
| `outline: none` without replacement | Keyboard users can't see focus | Custom focus ring |
| No loading/error states | Broken UI on slow network | Always handle loading, error, empty |
| Animate everything | Motion sickness, slow feel | Animate only meaningful transitions |
| String refs / class components | Legacy, harder to test | Hooks + function components |
