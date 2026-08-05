---
name: state-patterns
description: State management patterns, Redux, Zustand, Jotai, signals. Use when implementing state management, refactoring state, or fixing state bugs.
---

# State Management Patterns

## When To Use This

- Choosing a state library or approach for a feature
- Splitting server state from client state
- Normalizing or reshaping state
- Debugging stale state, over-renders, or state bugs

## The Two Kinds of State — Decide First

| | Server state | Client state |
|---|-------------|-------------|
| Where it lives | Remote DB (via API) | In the app only |
| Examples | users, posts, cart persisted to backend | form input, toggle, active tab, draft |
| Who owns truth | Server | Client |
| Tools | **TanStack Query / RTK Query / SWR** | Zustand / Jotai / Redux / signals |

**The #1 rule: server state belongs in a data-fetching library, not a manual store.** Manually syncing fetched data into Redux/Zustand is the most common state bug factory (stale copies, duplicate fetch logic, cache drift). Let the query library own caching, refetch, invalidation, and loading/error status.

### When to use what — decision table

| Situation | Use |
|-----------|-----|
| Fetch/cache/mutate server data | TanStack Query / RTK Query / SWR |
| Small-medium client state, few components | `useState`/`useReducer` local |
| Client state shared across many components/trees | Zustand |
| Deep dependency graph, derived values, fine-grained updates | Jotai |
| Large team, strict architecture, devtools/time-travel, debugging | Redux (RTK) |
| Framework-fine-grained reactivity | Signals (Angular, Solid, Preact) |
| URL / route state (filters, pagination) | URL search params (source of truth) |

### Derive first, store second

**Don't store what you can compute.** Storing `totalPrice` alongside a `cart` array means two sources of truth that drift. Store the minimal truth; derive everything else.

## Redux (RTK)

### When Redux is the right call

- Multiple slices with complex cross-relations
- Many components read/write the same global state
- Team discipline: explicit actions, reducers, and DevTools time-travel matter
- High-stakes undo/replay, analytics of every state change

### Slice Pattern

```typescript
// features/counter/counterSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CounterState { value: number; }
const initialState: CounterState = { value: 0 };

const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment(state) { state.value += 1; },          // Immer: draft mutation is safe
    decrement(state) { state.value -= 1; },
    incrementBy(state, action: PayloadAction<number>) { state.value += action.payload; },
  },
});

export const { increment, decrement, incrementBy } = counterSlice.actions;
export default counterSlice.reducer;
```

Rules:
- **Never mutate state outside a reducer** — Immer only protects inside `createSlice` reducers.
- Keep reducers pure: no side effects, no async, no `Math.random`/`Date.now` in a reducer (breaks time-travel & tests).
- Use `createAsyncThunk` for async flows, or better, let RTK Query own server state.

### Middleware

```typescript
const apiMiddleware: Middleware = (store) => (next) => (action) => {
  if (action.type === 'api/fetch/pending') {
    fetch(action.payload.url)
      .then((r) => r.json())
      .then((data) => store.dispatch({ type: 'api/fetch/fulfilled', payload: data }))
      .catch((e) => store.dispatch({ type: 'api/fetch/rejected', payload: e }));
  }
  return next(action);
};
```

Middleware is for cross-cutting concerns (logging, analytics, routing), **not** a substitute for RTK Query.

### RTK Query — server state for Redux apps

```typescript
export const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['User'],
  endpoints: (builder) => ({
    getUsers: builder.query<User[], void>({
      query: () => '/users',
      providesTags: ['User'],
    }),
    addUser: builder.mutation<User, Partial<User>>({
      query: (body) => ({ url: '/users', method: 'POST', body }),
      invalidatesTags: ['User'],   // re-fetch everything tagged 'User'
    }),
  }),
});
```

## Zustand — minimal global store

### When to reach for it

- Fast to set up, minimal boilerplate
- Medium-sized client state, consumed across many components
- Want store logic (actions) colocated with state, no providers needed

### Basic Store + Persistence

```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

const useBearStore = create<BearState>()(
  devtools(
    persist(
      (set, get) => ({
        bears: 0,
        increase: () => set((state) => ({ bears: state.bears + 1 })),
        decrease: () => {
          const current = get().bears;
          set({ bears: current - 1 });
          return current;
        },
      }),
      { name: 'bear-storage' },   // persists to localStorage; version it for schema changes
    ),
  ),
);
```

### Slice Pattern — split large stores

```typescript
const createBearSlice: StateCreator<BearState & FishState, [], [], BearSlice> = (set) => ({
  bears: 0,
  addBear: () => set((s) => ({ bears: s.bears + 1 })),
});
const createFishSlice: StateCreator<BearState & FishState, [], [], FishSlice> = (set) => ({
  fish: 0,
  addFish: () => set((s) => ({ fish: s.fish + 1 })),
});
const useStore = create<BearState & FishState>()((...a) => ({
  ...createBearSlice(...a),
  ...createFishSlice(...a),
}));
```

### Selectors — avoid over-renders

```typescript
// WRONG — subscribes to the whole store; re-renders on every change
const bears = useBearStore((s) => s);           // or destructuring

// RIGHT — select only what you need (uses === equality)
const bears = useBearStore((s) => s.bears);
const addBear = useBearStore((s) => s.addBear);

// Right for multiple values without churn
import { useShallow } from 'zustand/react/shallow';
const { bears, fish } = useBearStore(useShallow((s) => ({ bears: s.bears, fish: s.fish })));
```

### Zustand + React Query

```typescript
// Zustand: UI/transient state only
const useUIStore = create((set) => ({ filters: {}, setFilters: (f) => set({ filters: f }) }));

// React Query: server data
const users = useQuery({ queryKey: ['users', filters], queryFn: fetchUsers });
```

## Jotai — atomic, derived, fine-grained

### When to reach for it

- State is a graph of derived values
- You want module-scoped atoms, no global store shape
- You want fine-grained updates and easy composition

### Atoms & Derivation

```typescript
import { atom, useAtom } from 'jotai';

const countAtom = atom(0);
const doubleCountAtom = atom((get) => get(countAtom) * 2);      // derived (read-only)
const readWriteAtom = atom(
  (get) => get(countAtom),
  (get, set, delta: number) => set(countAtom, get(countAtom) + delta),
);

// Async atom — loading handled by Suspense or loadable
const userDataAtom = atom(async (get) => {
  const userId = get(currentUserIdAtom);
  const res = await fetch(`/api/users/${userId}`);
  return res.json();
});
```

### Jotai + React Query

```typescript
const [usersAtom] = atomsWithQuery((get) => ({
  queryKey: ['users', get(filterAtom)],
  queryFn: async ({ queryKey }) => {
    const [, filter] = queryKey;
    const res = await fetch(`/api/users?filter=${filter}`);
    return res.json();
  },
}));
```

## Signals

### When to reach for it

- Framework built on signals (Angular, Solid, Preact) — use the platform primitive, not an adapter
- Fine-grained reactivity where tracking dependencies happens automatically

### Angular Signals

```typescript
import { signal, computed, effect } from '@angular/core';

count = signal(0);
doubleCount = computed(() => this.count() * 2);

constructor() {
  effect(() => console.log('Count:', this.count()));  // re-runs when tracked signals change
}

increment() { this.count.update((n) => n + 1); }
```

### Solid Signals

```typescript
import { createSignal, createMemo, createEffect } from 'solid-js';

const [count, setCount] = createSignal(0);
const double = createMemo(() => count() * 2);
createEffect(() => console.log('Count:', count()));
```

### Signals Pitfalls

- **Conditional reads change dependency tracking** — only signals read *during* an effect run are tracked. Reading a signal inside a `while`/`if` that's false first run = never re-runs. (The same trap exists for memoized selectors.)
- Effects with side effects should be rare and explicit; derive in `computed`/`createMemo` instead.
- Don't mix signals into an imperative callback expecting reactivity — signals are read lazily.

## Normalization

### Why normalize

- **No duplicate copies** of the same entity (updating `user.name` in one place updates everywhere)
- **No nested-update pain** — update by id, not by path
- **Consistent identity** — relationships are ids, not copies

### Normalized shape

```typescript
interface NormalizedState<T> {
  ids: string[];                 // preserves order
  entities: Record<string, T>;   // fast lookup by id
}
```

### When NOT to normalize

| Situation | Keep nested/denormalized |
|-----------|--------------------------|
| Small, rarely-updated data | Yes |
| Data used as a whole (a single report doc) | Yes |
| No shared references between entities | Yes |
| Deeply nested, updated by whole-document write | Yes (or use Immer) |

### Selectors re-derive views

```typescript
const selectUserPosts = createSelector(
  (s: AppState) => s.posts,
  (s: AppState) => s.users,
  (_: AppState, userId: string) => userId,
  (posts, users, userId) =>
    posts.ids
      .filter((id) => posts.entities[id].authorId === userId)
      .map((id) => ({ ...posts.entities[id], author: users.entities[posts.entities[id].authorId] })),
);
```

**Denormalize in selectors, never in the store.** `normalizr` can shape API payloads into `{ entities, result }` on arrival.

## Immutability

### Why it matters

- Predictable updates (no accidental mutation bugs)
- Cheap change detection (`!==` reference check) in React/memo
- Time-travel & undo become trivial (snapshot the state)

### Rules & helpers

| Technique | Use |
|-----------|-----|
| Spread `{ ...obj, field }` | Shallow updates |
| `[...arr, item]` / `arr.filter(...)` | Array updates |
| Immer (`produce`) | Nested updates without spreads everywhere |
| `structuredClone` | Deep copy (only when necessary — expensive) |
| `Map`/`Set` immutably | New instance on each change |

```typescript
import { produce } from 'immer';
const next = produce(state, (draft) => {
  draft.user.preferences.theme = 'dark';   // safe nested mutation of draft
});
```

Pitfalls:
- Mutating props/state directly in React → re-render misses, `shouldComponentUpdate` false negatives
- `Object.freeze`-ing state is a dev-mode tripwire, not a runtime guarantee
- `push`/`splice` on state arrays — always replace, never mutate

## Common Pitfalls / Anti-Patterns

| Anti-pattern | Why it hurts | Fix |
|--------------|-------------|-----|
| Server data in client store | Duplicated copies, cache drift, manual sync bugs | Query library owns server state |
| Storing derived values | Two sources of truth drift | Derive in selectors/computeds |
| Whole-store subscriptions | Over-rendering on every change | Select only needed slices |
| Mutating state directly | Silent UI bugs, broken memo | Immer/spread; never mutate |
| Redux for trivial state | Boilerplate with zero benefit | `useState` or Zustand |
| Zustand/Jotai for everything | No caching/refetch/invalidation | Pair with a query library |
| Normalizing everything | Overhead where data is whole-doc | Normalize shared-reference data only |
| Persisting everything | Schema migration pain, quota, stale writes | Persist only what survives reload; version keys |
| Async logic in reducers/actions as an afterthought | Race conditions, stale closures | Use createAsyncThunk / RTK Query / query lib |

## Best Practices Checklist

- [ ] Server state in a query library; client state in a store — never mixed
- [ ] Derive computed values; store minimal truth
- [ ] Immutable updates everywhere (Immer/spread)
- [ ] Selectors subscribe narrowly (avoid whole-store re-renders)
- [ ] Normalize shared entities; denormalize in selectors
- [ ] Persist only what must survive reload; version persistence keys
- [ ] One clear owner per piece of state (URL, local, global, server)
- [ ] Library choice matches team size + state complexity (Redux for discipline, Zustand for speed, Jotai for derived graphs)
