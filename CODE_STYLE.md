# 🏛️ Code Style Guidelines

> **Not a linter config. This is how senior engineers think about code.**

---

## 1. The Inversion of Control Principle

**Bad:** Code that calls libraries.
**Good:** Code that configures libraries to call you.

```typescript
// ❌ You call the framework
async function createUser(data: CreateUserDTO) {
  const user = await db.users.create(data);
  await emailService.sendWelcome(user.email);
  await analytics.track('user_created', user.id);
  return user;
}

// ✅ Framework calls you
class CreateUserHandler implements Handler<CreateUserCommand, User> {
  constructor(
    private readonly users: UserRepository,
    private readonly events: DomainEventEmitter,
  ) {}

  async execute(command: CreateUserCommand): Promise<User> {
    const user = User.create(command.data);
    await this.users.save(user);
    await this.events.emit(new UserCreated(user.id));
    return user;
  }
}
```

**Why:** The first version is a procedure that knows about everything. The second is a plug-in that knows about nothing except its own responsibility.

---

## 2. The Explicit Dependency Principle

**Bad:** Dependencies discovered at runtime.
**Good:** Dependencies declared at construction time.

```typescript
// ❌ Hidden dependencies
class OrderService {
  async processOrder(id: string) {
    const db = getDatabase(); // where does this come from?
    const config = getConfig(); // who initialized it?
    const logger = getLogger(); // what if it's null?
  }
}

// ✅ Dependencies are arguments, not discoveries
class OrderService {
  constructor(
    private readonly db: Database,
    private readonly config: Config,
    private readonly logger: Logger,
  ) {}

  async processOrder(id: string) {
    // this.db, this.config, this.logger — explicit, testable, replaceable
  }
}
```

**Why:** Implicit dependencies are invisible to the reader, untestable without global state, and impossible to swap. Explicit dependencies are documentation by signature.

---

## 3. The Parse, Don't Validate Principle

**Bad:** Check data, throw if wrong.
**Good:** Transform data, make wrong states unrepresentable.

```typescript
// ❌ Validation that leaves you with untyped data
function validateEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
// Caller still has a `string` — they must remember to check

// ✅ Parsing that gives you a typed result
class Email {
  private constructor(private readonly value: string) {}

  static create(raw: string): Result<Email> {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(raw)) {
      return Result.err(new InvalidEmail(raw));
    }
    return Result.ok(new Email(raw));
  }

  toString(): string { return this.value; }
}
// Caller has an `Email` — wrong states literally cannot exist
```

**Why:** Validation is a runtime guard that programmers can forget. Parsing is a type-level constraint that the compiler enforces.

---

## 4. The Tri-state Pattern

**Bad:** Boolean flags that encode three meanings.
**Good:** Explicit tri-state with named semantics.

```typescript
// ❌ What does `undefined` mean here?
type NotificationPref = {
  emailEnabled: boolean | undefined;
};

// ✅ Three states, each with a name
type NotificationPref =
  | { status: 'enabled'; channel: EmailAddress }
  | { status: 'disabled' }
  | { status: 'unset' };
```

**Why:** `null`, `undefined`, and `false` are three different things. Encoding them as a boolean loses meaning. The tri-state makes every case explicit and forces the caller to handle all three.

---

## 5. The Fail-Fast Boundary

**Bad:** Push errors up the stack.
**Good:** Catch errors at the boundary where they can be handled.

```typescript
// ❌ Error propagation without context
async function getUser(id: string) {
  const user = await db.users.findById(id); // throws raw DB error
  return user;
}

// ✅ Error translation at the boundary
async function getUser(id: string): Promise<Result<User, GetUserError>> {
  try {
    const user = await this.users.findById(id);
    if (!user) return Result.err(new UserNotFound(id));
    return Result.ok(user);
  } catch (e) {
    if (e instanceof DatabaseTimeout) {
      return Result.err(new GetUserTimeout(id, e));
    }
    throw e; // re-throw truly unexpected errors
  }
}
```

**Why:** Raw errors are implementation details leaking into your domain. Translated errors are contract guarantees for your callers.

---

## 6. The Single Level of Abstraction Rule

**Bad:** Mixing levels of detail in one function.
**Good:** Each function operates at exactly one level.

```typescript
// ❌ Low-level and high-level mixed
async function processPayment(order: Order) {
  const stripe = new Stripe(process.env.STRIPE_KEY);
  const charge = await stripe.charges.create({
    amount: order.total,
    currency: 'usd',
    source: order.paymentToken,
  });
  await db.query('UPDATE orders SET status = $1 WHERE id = $2', ['paid', order.id]);
  await sendGrid.send({
    to: order.customerEmail,
    template: 'payment-received',
    variables: { amount: order.total },
  });
}

// ✅ Each function is one level
async function processPayment(order: Order): Promise<Result<Payment, PaymentError>> {
  const payment = await this.chargePayment(order);
  if (payment.isErr()) return payment;
  await this.confirmOrder(order.id);
  await this.notifyCustomer(order);
  return Result.ok(payment.value);
}

private async chargePayment(order: Order): Promise<Result<Charge, PaymentError>> {
  // only Stripe details here
}

private async confirmOrder(orderId: string): Promise<void> {
  // only persistence details here
}

private async notifyCustomer(order: Order): Promise<void> {
  // only notification details here
}
```

**Why:** When a function does multiple things at different abstraction levels, you cannot name it, test it in isolation, or reason about it without holding all levels in your head simultaneously.

---

## 7. The Tolerant Reader Principle

**Bad:** brittle contracts that break on unexpected fields.
**Good:** Read only what you need, ignore the rest.

```typescript
// ❌ Brittle: breaks if API adds a field
const user = await fetchUser();
const name = user.name;
const email = user.email;
// if API returns { name, email, avatar }, this still works
// but if you typed the response, adding a field to the type breaks compilation

// ✅ Tolerant: schema validates what you need, ignores the rest
const UserSchema = z.object({
  name: z.string(),
  email: z.string().email(),
}).passthrough(); // unknown fields pass through

type User = z.infer<typeof UserSchema>;

// ✅ Or even better: explicit extraction
function toDomainUser(raw: unknown): Result<User, ValidationError> {
  const parsed = UserSchema.safeParse(raw);
  if (!parsed.success) return Result.err(new ValidationError(parsed.error));
  return Result.ok({
    name: parsed.data.name,
    email: parsed.data.email,
    // explicitly mapped, not blindly spread
  });
}
```

**Why:** Systems evolve. If your reader breaks when the source adds a field, you have created a coupling that makes every team afraid to change anything.

---

## 8. The Error Value Pattern

**Bad:** Errors as thrown exceptions.
**Good:** Errors as return values with typed variants.

```typescript
// ❌ Unchecked errors — caller has no idea what can fail
async function transfer(from: AccountId, to: AccountId, amount: number) {
  const source = await getAccount(from); // can throw 5 different things
  const dest = await getAccount(to);     // can throw 3 different things
  // caller must know all 8 failure modes... or not
}

// ✅ Checked errors — caller sees the contract
type TransferError =
  | { kind: 'insufficient_funds'; available: number; requested: number }
  | { kind: 'account_not_found'; id: AccountId }
  | { kind: 'account_frozen'; id: AccountId; until: Date }
  | { kind: 'daily_limit_exceeded'; limit: number; attempted: number };

async function transfer(
  from: AccountId,
  to: AccountId,
  amount: number,
): Promise<Result<TransferResult, TransferError>> {
  // every error is a named, typed, documented variant
}
```

**Why:** Thrown exceptions are invisible contracts. The caller cannot know what can fail without reading the implementation. Typed errors are visible contracts — the compiler forces the caller to handle every case.

---

## 9. The Type-Safe Builder Pattern

**Bad:** Configuration objects with optional fields everywhere.
**Good:** Builders that enforce required fields at compile time.

```typescript
// ❌ Every field optional — nothing is guaranteed
type SendEmailOptions = {
  to?: string;
  from?: string;
  subject?: string;
  body?: string;
  cc?: string[];
  bcc?: string[];
};

// ✅ Builder enforces required fields
class EmailBuilder {
  private to?: string;
  private from?: string;
  private subject?: string;
  private body?: string;

  static create(): EmailBuilder {
    return new EmailBuilder();
  }

  to(address: string): this { this.to = address; return this; }
  from(address: string): this { this.from = address; return this; }
  subject(text: string): this { this.subject = text; return this; }
  body(html: string): this { this.body = html; return this; }

  build(): Result<Email, ValidationError> {
    if (!this.to) return Result.err(new ValidationError('to is required'));
    if (!this.from) return Result.err(new ValidationError('from is required'));
    if (!this.subject) return Result.err(new ValidationError('subject is required'));
    if (!this.body) return Result.err(new ValidationError('body is required'));
    return Result.ok({
      to: this.to,
      from: this.from,
      subject: this.subject,
      body: this.body,
    });
  }
}
```

**Why:** An object with all fields optional tells you nothing about what is actually required. A builder that fails at `build()` time gives you a clear error. A builder that fails at type-check time is even better.

---

## 10. The Anti-Corruption Layer

**Bad:** Domain logic tangled with external APIs.
**Good:** A thin adapter that translates between your domain and the outside world.

```typescript
// ❌ Stripe API leaking into your domain
async function chargeCustomer(customer: Stripe.Customer, amount: number) {
  return stripe.charges.create({
    amount,
    currency: 'usd',
    customer: customer.id,
  });
}

// ✅ Anti-corruption layer isolates your domain
class PaymentGateway {
  constructor(private readonly stripe: Stripe) {}

  async charge(
    customerId: CustomerId,
    amount: Money,
  ): Promise<Result<ChargeId, PaymentError>> {
    try {
      const result = await this.stripe.charges.create({
        amount: amount.cents,
        currency: amount.currency,
        customer: customerId.value,
      });
      return Result.ok(new ChargeId(result.id));
    } catch (e) {
      return Result.err(this.translateStripeError(e));
    }
  }

  private translateStripeError(e: unknown): PaymentError {
    // Stripe-specific error → domain error
  }
}

// Domain code never sees Stripe types
class CheckoutHandler {
  constructor(private readonly payments: PaymentGateway) {}

  async execute(command: CheckoutCommand): Promise<Result<Receipt, CheckoutError>> {
    const charge = await this.payments.charge(command.customerId, command.total);
    // charge is a ChargeId or PaymentError — no Stripe types anywhere
  }
}
```

**Why:** External APIs change. If your domain is coupled to Stripe's types, a Stripe API change becomes a domain change. The anti-corruption layer absorbs external changes so your domain doesn't have to.

---

## 11. The Sentinel Object Pattern

**Bad:** Magic values (`null`, `-1`, `""`, `"N/A"`).
**Good:** Named sentinel objects that carry meaning.

```typescript
// ❌ What does -1 mean here?
function getDiscount(price: number, userId: string): number {
  const tier = getUserTier(userId);
  if (tier === -1) return 0; // what is -1?
  return price * (tier / 100);
}

// ✅ Sentinels with names
type UserTier =
  | { kind: 'percentage'; value: number }
  | { kind: 'free_for_life' }
  | { kind: 'no_discount' };

function getDiscount(price: number, userId: string): Money {
  const tier = getUserTier(userId);
  switch (tier.kind) {
    case 'percentage': return price.multiply(tier.value / 100);
    case 'free_for_life': return Money.zero;
    case 'no_discount': return price;
  }
}
```

**Why:** Magic values require you to read the implementation to understand the code. Named sentinels are self-documenting — the name IS the meaning.

---

## 12. The Composition Over Inheritance Rule

**Bad:** Deep inheritance hierarchies.
**Good:** Small, composable behaviors.

```typescript
// ❌ Inheritance: rigid, fragile, deep
class BaseNotification {
  send() { /* ... */ }
}
class EmailNotification extends BaseNotification {
  send() { super.send(); /* email specific */ }
}
class UrgentEmailNotification extends EmailNotification {
  send() { super.send(); /* urgent specific */ }
}
// 3 levels deep, each layer adds coupling

// ✅ Composition: flexible, flat, testable
interface NotificationChannel {
  send(notification: Notification): Promise<Result<void, SendError>>;
}

class EmailChannel implements NotificationChannel { /* ... */ }
class SmsChannel implements NotificationChannel { /* ... */ }
class PushChannel implements NotificationChannel { /* ... */ }

class UrgencyPolicy {
  constructor(private readonly channels: NotificationChannel[]) {}

  async notify(notification: Notification): Promise<Result<void, SendError>> {
    const results = await Promise.all(
      this.channels.map(ch => ch.send(notification))
    );
    return results.every(r => r.isOk())
      ? Result.ok(undefined)
      : Result.err(new PartialSendFailure(results));
  }
}

// Usage: combine behaviors, not inherit them
const urgentEmail = new UrgencyPolicy([new EmailChannel(), new SmsChannel()]);
```

**Why:** Inheritance creates a "is-a" relationship that is rigid — you cannot change a parent without affecting all children. Composition creates "has-a" relationships that are flexible — you can swap behaviors independently.

---

## 13. The Specification Pattern

**Bad:** Complex conditional logic scattered across business rules.
**Good:** Each rule is a composable, testable predicate.

```typescript
// ❌ Rules tangled in procedure
function canApproveExpense(expense: Expense, approver: Employee): boolean {
  if (expense.amount > 10000 && approver.level < 5) return false;
  if (expense.category === 'travel' && !expense.hasPreApproval) return false;
  if (expense.submittedAt > addDays(expense.incurredAt, 30)) return false;
  if (approver.department !== expense.department && approver.level < 7) return false;
  return true;
}

// ✅ Each rule is a Specification
interface Specification<T> {
  isSatisfiedBy(candidate: T): boolean;
  and(other: Specification<T>): Specification<T>;
  or(other: Specification<T>): Specification<T>;
  not(): Specification<T>;
}

class AmountLimit implements Specification<ApprovalContext> {
  constructor(private readonly maxAmount: number) {}

  isSatisfiedBy(ctx: ApprovalContext): boolean {
    return ctx.expense.amount <= this.maxAmount;
  }
}

class PreApprovalRequired implements Specification<ApprovalContext> {
  isSatisfiedBy(ctx: ApprovalContext): boolean {
    return ctx.expense.category !== 'travel' || ctx.expense.hasPreApproval;
  }
}

// Rules composed, not scattered
const canApprove = new AmountLimit(10000)
  .and(new PreApprovalRequired())
  .and(new SubmissionTimeliness(30))
  .and(new DepartmentOrSeniority(7));

const result = canApprove.isSatisfiedBy(context);
```

**Why:** When rules are scattered in if-else chains, adding a new rule means finding every chain. When rules are Specifications, adding a new rule means adding one class and composing it. The compiler tells you where the composition happens.

---

## 14. The Result Type Pattern

**Bad:** Throwing exceptions for expected failures.
**Good:** Returning Result types that encode success and failure.

```typescript
// ❌ Exceptions for expected failures
function parseConfig(raw: string): Config {
  const parsed = JSON.parse(raw); // throws on invalid JSON
  if (!parsed.host) throw new Error('host is required'); // throws on missing field
  return parsed; // caller has no idea what can throw
}

// ✅ Result type
type ConfigError =
  | { kind: 'invalid_json'; raw: string; cause: SyntaxError }
  | { kind: 'missing_field'; field: string };

function parseConfig(raw: string): Result<Config, ConfigError> {
  const parsed = JSON.parse(raw); // still throws on truly unexpected errors
  if (!parsed.host) {
    return Result.err({ kind: 'missing_field', field: 'host' });
  }
  return Result.ok({ host: parsed.host, port: parsed.port ?? 3000 });
}

// Caller handles the error explicitly
const config = parseConfig(raw);
if (config.isErr()) {
  switch (config.error.kind) {
    case 'invalid_json': /* handle */ break;
    case 'missing_field': /* handle */ break;
  }
}
```

**Why:** Exceptions are control flow that hides behind a normal-looking function call. Result types make control flow visible — the caller MUST handle the error, and the compiler enforces it.

---

## 15. The Bounded Context Rule

**Bad:** One model used everywhere.
**Good:** Separate models for separate business contexts.

```typescript
// ❌ One User model for everything
interface User {
  id: string;
  email: string;
  passwordHash: string; // auth context
  displayName: string; // profile context
  shippingAddress: Address; // order context
  stripeCustomerId: string; // billing context
  lastLoginAt: Date; // analytics context
}

// ✅ Separate models per context
// Auth context
interface AuthUser {
  id: UserId;
  email: EmailAddress;
  passwordHash: PasswordHash;
}

// Profile context
interface UserProfile {
  userId: UserId;
  displayName: string;
  avatarUrl: Url;
}

// Order context
interface OrderCustomer {
  userId: UserId;
  shippingAddress: Address;
  billingMethod: PaymentMethod;
}

// Each model has only what IT needs
```

**Why:** A single model that serves every context becomes a God Object — every change risks breaking unrelated systems. Separate models let each context evolve independently.

---

## The Meta-Rule

**Code is a communication medium.** Every pattern above serves one purpose: making the code say what it means, so the next reader doesn't have to guess.

- If the reader must look at the implementation to understand the call → the abstraction is wrong.
- If the reader must hold multiple levels of detail in their head → the function is too big.
- If the reader must check for null/undefined/empty → the type system is underused.
- If the reader must read the caller to understand the callee → the dependency is inverted.

**The best code is the code that explains itself without comments.**
