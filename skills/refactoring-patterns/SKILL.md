---
name: refactoring-patterns
description: Code smells, refactoring techniques, extraction patterns. Use when refactoring code, improving readability, or reducing complexity.
---

# Refactoring Patterns

## Code Smells

### Long Method (>30 lines)

```typescript
// Bad
function processOrder(order: Order) {
  // 50 lines of validation, calculation, database calls...
}

// Good
function processOrder(order: Order) {
  const validatedOrder = validateOrder(order);
  const calculatedPricing = calculatePricing(validatedOrder);
  const savedOrder = saveOrder(calculatedPricing);
  return sendConfirmation(savedOrder);
}
```

### Large Class (>300 lines)

```typescript
// Bad — does everything
class UserManager {
  // 500 lines of user, auth, email, profile logic
}

// Good — single responsibility
class UserService {
  // User CRUD only
}

class AuthService {
  // Authentication only
}

class EmailService {
  // Email sending only
}
```

### Duplicated Code (3+ places)

```typescript
// Bad — same logic repeated
const totalA = itemsA.reduce((sum, item) => sum + item.price, 0);
const totalB = itemsB.reduce((sum, item) => sum + item.price, 0);

// Good — extracted function
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

### Long Parameter List (>3)

```typescript
// Bad
function createUser(name, email, phone, address, city, state, zip) {}

// Good — options object
interface CreateUserParams {
  name: string;
  email: string;
  phone?: string;
  address?: Address;
}

function createUser(params: CreateUserParams) {}
```

### Feature Envy

```typescript
// Bad — uses other class's data more than its own
class Order {
  calculateTax(): number {
    return this.subtotal * this.taxRate;
  }
  
  formatForDisplay(): string {
    return `${this.customer.name}: $${this.total}`;
  }
}

// Good — move behavior to the class that owns the data
class TaxCalculator {
  calculate(order: Order): number {
    return order.subtotal * order.taxRate;
  }
}

class OrderFormatter {
  format(order: Order): string {
    return `${order.customer.name}: $${order.total}`;
  }
}
```

### Primitive Obsession

```typescript
// Bad — primitives everywhere
function createUser(name: string, email: string) {}

// Good — value objects
class Email {
  constructor(private value: string) {
    if (!this.isValid()) throw new Error('Invalid email');
  }
  
  private isValid(): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.value);
  }
  
  toString(): string {
    return this.value;
  }
}

function createUser(name: Name, email: Email) {}
```

## Refactoring Techniques

### Extract Function

```typescript
// Before
function printOwing(invoice) {
  let outstanding = 0;
  
  // print banner
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
  
  // calculate outstanding
  for (const order of invoice.orders) {
    outstanding += order.amount;
  }
  
  // print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}

// After
function printOwing(invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}

function printBanner() {
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
}

function calculateOutstanding(invoice) {
  return invoice.orders.reduce((sum, order) => sum + order.amount, 0);
}

function printDetails(invoice, outstanding) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

### Extract Class

```typescript
// Before
class Person {
  name: string;
  officeAreaCode: string;
  officeNumber: string;
  
  getTelephoneNumber(): string {
    return `(${this.officeAreaCode}) ${this.officeNumber}`;
  }
}

// After
class TelephoneNumber {
  constructor(private areaCode: string, private number: string) {}
  
  toString(): string {
    return `(${this.areaCode}) ${this.number}`;
  }
}

class Person {
  name: string;
  telephoneNumber: TelephoneNumber;
  
  getTelephoneNumber(): string {
    return this.telephoneNumber.toString();
  }
}
```

### Inline Function

```typescript
// Before
function getRating(driver) {
  return moreThanFiveLateDeliveries(driver) ? 2 : 1;
}

function moreThanFiveLateDeliveries(driver) {
  return driver.numberOfLateDeliveries > 5;
}

// After
function getRating(driver) {
  return driver.numberOfLateDeliveries > 5 ? 2 : 1;
}
```

### Move Method

```typescript
// Before
class Order {
  // ... order stuff
  
  calculateShippingCost(destination: Address): number {
    return destination.distance * this.shippingRate;
  }
}

// After
class Order {
  // ... order stuff
}

class ShippingCalculator {
  calculateCost(order: Order, destination: Address): number {
    return destination.distance * order.shippingRate;
  }
}
```

### Replace with Strategy

```typescript
// Before
class Parachute {
  calculateValue(risk: number): number {
    if (risk === 'low') return this.basePrice * 1.1;
    if (risk === 'medium') return this.basePrice * 1.3;
    if (risk === 'high') return this.basePrice * 1.8;
  }
}

// After
interface ValuationStrategy {
  calculate(basePrice: number): number;
}

class LowRiskValuation implements ValuationStrategy {
  calculate(basePrice: number): number {
    return basePrice * 1.1;
  }
}

class Parachute {
  constructor(private strategy: ValuationStrategy) {}
  
  calculateValue(): number {
    return this.strategy.calculate(this.basePrice);
  }
}
```

## Refactoring Checklist

- [ ] Run tests before refactoring
- [ ] Make small, incremental changes
- [ ] Keep tests passing at each step
- [ ] Use IDE refactoring tools when available
- [ ] Review with a colleague for complex refactors
- [ ] Update documentation if behavior changes
- [ ] Check for performance regressions
