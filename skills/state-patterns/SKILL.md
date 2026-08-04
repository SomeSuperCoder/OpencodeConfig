---
name: state-patterns
description: State management patterns, Redux, Zustand, Jotai, signals. Use when implementing state management, refactoring state, or fixing state bugs.
---

# State Management Patterns

## Redux Patterns

### Slice Pattern

```typescript
// features/counter/counterSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
}

const initialState: CounterState = { value: 0 };

const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment(state) {
      state.value += 1; // Immer handles immutability
    },
    decrement(state) {
      state.value -= 1;
    },
    incrementBy(state, action: PayloadAction<number>) {
      state.value += action.payload;
    },
  },
});

export const { increment, decrement, incrementBy } = counterSlice.actions;
export default counterSlice.reducer;
```

### Middleware Pattern

```typescript
// middleware/logger.ts
const logger: Middleware = (store) => (next) => (action) => {
  console.log('Dispatching:', action);
  const result = next(action);
  console.log('Next state:', store.getState());
  return result;
};

// middleware/api.ts
const apiMiddleware: Middleware = (store) => (next) => async (action) => {
  if (action.type === 'api/fetch/pending') {
    try {
      const response = await fetch(action.payload.url);
      const data = await response.json();
      store.dispatch({ type: 'api/fetch/fulfilled', payload: data });
    } catch (error) {
      store.dispatch({ type: 'api/fetch/rejected', payload: error });
    }
  }
  return next(action);
};
```

### Redux Toolkit Query

```typescript
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

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
      query: (body) => ({
        url: '/users',
        method: 'POST',
        body,
      }),
      invalidatesTags: ['User'],
    }),
  }),
});

export const { useGetUsersQuery, useAddUserMutation } = api;
```

## Zustand Patterns

### Basic Store

```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface BearState {
  bears: number;
  increase: () => void;
  decrease: () => number;
}

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
      { name: 'bear-storage' }
    )
  )
);
```

### Slice Pattern

```typescript
import { StateCreator } from 'zustand';

interface BearSlice {
  bears: number;
  addBear: () => void;
}

interface FishSlice {
  fish: number;
  addFish: () => void;
}

const createBearSlice: StateCreator<BearSlice & FishSlice, [], [], BearSlice> = (set) => ({
  bears: 0,
  addBear: () => set((state) => ({ bears: state.bears + 1 })),
});

const createFishSlice: StateCreator<BearSlice & FishSlice, [], [], FishSlice> = (set) => ({
  fish: 0,
  addFish: () => set((state) => ({ fish: state.fish + 1 })),
});

const useStore = create<BearSlice & FishSlice>()((...a) => ({
  ...createBearSlice(...a),
  ...createFishSlice(...a),
}));
```

### Zustand + React Query

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

function useUsers() {
  const queryClient = useQueryClient();

  const users = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  });

  const addUser = useMutation({
    mutationFn: createUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });

  return { users, addUser };
}
```

## Jotai Patterns

### Basic Atoms

```typescript
import { atom, useAtom } from 'jotai';
import { atomWithStorage } from 'jotai/utils';

// Primitive atom
const countAtom = atom(0);

// Derived atom (read-only)
const doubleCountAtom = atom((get) => get(countAtom) * 2);

// Derived atom (read-write)
const加倍Atom = atom(
  (get) => get(countAtom),
  (get, set, delta: number) => set(countAtom, get(countAtom) + delta)
);

// Async atom
const userDataAtom = atom(async (get) => {
  const userId = get(currentUserIdAtom);
  const response = await fetch(`/api/users/${userId}`);
  return response.json();
});
```

### Atom Effects

```typescript
import { atomEffect } from 'jotai-effect';

const loggingEffect = atomEffect((get) => {
  const count = get(countAtom);
  console.log('Count changed:', count);

  // Cleanup function
  return () => {
    console.log('Cleaning up');
  };
});

// Persistence effect
const persistEffect = atomEffect((get, { signal }) => {
  const value = get(myAtom);

  const handler = () => {
    localStorage.setItem('my-key', JSON.stringify(value));
  };

  signal.addEventListener('abort', () => {
    // Cleanup
  });
});
```

### Jotai + React Query

```typescript
import { atomsWithQuery } from 'jotai-tanstack-query';

const [usersAtom] = atomsWithQuery((get) => ({
  queryKey: ['users', get(filterAtom)],
  queryFn: async ({ queryKey }) => {
    const [, filter] = queryKey;
    const response = await fetch(`/api/users?filter=${filter}`);
    return response.json();
  },
}));
```

## Signals (Angular/Solid)

### Angular Signals

```typescript
import { signal, computed, effect } from '@angular/core';

@Component({...})
export class CounterComponent {
  count = signal(0);
  doubleCount = computed(() => this.count() * 2);

  constructor() {
    effect(() => {
      console.log('Count changed:', this.count());
    });
  }

  increment() {
    this.count.update(n => n + 1);
  }
}
```

### Solid Signals

```typescript
import { createSignal, createEffect, createMemo } from 'solid-js';

function Counter() {
  const [count, setCount] = createSignal(0);
  const doubleCount = createMemo(() => count() * 2);

  createEffect(() => {
    console.log('Count:', count());
  });

  return (
    <button onClick={() => setCount(c => c + 1)}>
      {doubleCount()}
    </button>
  );
}
```

## State Normalization

### Normalized State Shape

```typescript
interface NormalizedState<T> {
  ids: string[];
  entities: Record<string, T>;
}

// Normalizr schema
import { normalize, schema } from 'normalizr';

const userSchema = new schema.Entity('users');
const postSchema = new schema.Entity('posts', {
  author: userSchema,
});

const normalized = normalize(rawData, postSchema);
// {
//   entities: {
//     users: { '1': { id: '1', name: 'Alice' } },
//     posts: { '1': { id: '1', author: '1' } }
//   },
//   result: '1'
// }
```

### Redux Normalized State

```typescript
interface AppState {
  users: NormalizedState<User>;
  posts: NormalizedState<Post>;
}

// Selector to denormalize
const selectUserPosts = createSelector(
  (state: AppState) => state.posts,
  (state: AppState) => state.users,
  (state: AppState, userId: string) => userId,
  (posts, users, userId) => {
    return posts.ids
      .filter(id => posts.entities[id].authorId === userId)
      .map(id => ({
        ...posts.entities[id],
        author: users.entities[posts.entities[id].authorId],
      }));
  }
);
```
