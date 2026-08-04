---
name: algorithm-patterns
description: "Algorithm optimization, data structures, complexity analysis. Use when optimizing performance, reducing time/space complexity, or implementing efficient algorithms."
---

# Algorithm Patterns

Load this skill when optimizing algorithms or data structures.

## Complexity Cheat Sheet
| Complexity | Name | Example |
|------------|------|---------|
| O(1) | Constant | Array index, HashMap lookup |
| O(log n) | Logarithmic | Binary search |
| O(n) | Linear | Single loop |
| O(n log n) | Linearithmic | Merge sort |
| O(n²) | Quadratic | Nested loops |

## Common Optimizations
| Pattern | Before | After |
|---------|--------|-------|
| Nested lookup | O(n²) | HashMap O(n) |
| Repeated work | Recursion | Memoization |
| Linear search | O(n) | Binary search O(log n) |
| String concat | O(n²) | StringBuilder O(n) |
| Matrix multiply | O(n³) | Strassen O(n^2.81) |

## Data Structure Selection
| Need | Use |
|------|-----|
| Fast lookup | HashMap |
| Sorted data | TreeMap |
| Fast insert/delete | LinkedList |
| LIFO | Stack |
| FIFO | Queue |
| Priority | Heap |
| Union/Disjoint Set | Union-Find |
| Graph traversal | Adjacency list |

## Algorithm Templates
```typescript
// Binary Search
function binarySearch(arr: number[], target: number): number {
  let left = 0, right = arr.length - 1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    if (arr[mid] === target) return mid;
    if (arr[mid] < target) left = mid + 1;
    else right = mid - 1;
  }
  return -1;
}

// Memoization
function memoize<T>(fn: (...args: any[]) => T): (...args: any[]) => T {
  const cache = new Map<string, T>();
  return (...args: any[]) => {
    const key = JSON.stringify(args);
    if (!cache.has(key)) cache.set(key, fn(...args));
    return cache.get(key)!;
  };
}
```

## Integration
- **MCPs:** CodeGraph for code analysis
- **AgentMemory:** Save algorithm patterns, optimization techniques
