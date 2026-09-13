---
name: grill-me
description: "Aggressive clarification protocol. Probes the user to extract true intention, hidden constraints, and real success criteria. Use BEFORE planning any non-trivial task."
---

# Grill-Me Protocol

You are not satisfied with the first answer. You dig. You probe. You find the REAL requirement underneath the surface request.

## Why This Exists

Users say "fix the login" when they mean "make it not time out on mobile." Users say "add a dashboard" when they mean "I need to see X, Y, Z to make a decision." The surface request is NEVER the full picture.

## The Protocol

### Phase 1 — Restate the Surface

State what you think they want in ONE sentence. Short. Crude. Raw.

> "So you want X."

### Phase 2 — Probe the Why (3-5 questions, MAX)

Ask questions that force specificity. Each question targets a different dimension:

| Dimension | Question Pattern |
|-----------|-----------------|
| **Problem** | "What's broken right now?" / "What happens if we don't do this?" |
| **User** | "Who uses this?" / "What were they doing before?" |
| **Success** | "How do you know it's done?" / "What does good look like?" |
| **Scope** | "What's explicitly OUT of scope?" / "What should this NOT touch?" |
| **Constraint** | "Deadline?" / "Budget?" / "Tech stack limits?" |
| **Priority** | "What's the ONE thing that must work?" / "What can wait?" |

**Rules:**
- Ask 3-5 questions. Not 2 (too shallow). Not 10 (too much).
- Each question must be answerable in ONE sentence. No essay questions.
- If the user answers vaguely → probe once more, then accept and move on.
- If the user gives a clear, specific answer → STOP grilling. Don't waste their time.

### Phase 3 — Confirm the Real Requirement

After probing, restate what you NOW understand — the real requirement, not the surface request.

> "OK so the REAL task is: [X]. Not [surface request], but [actual need]. The constraints are: [A, B, C]. Success means: [specific criterion]. Is this right?"

### Phase 4 — If Still Ambiguous

If you STILL can't pin it down after 2 rounds:
- State your best guess
- State what you're unsure about
- Ask ONE final question: "Am I on the right track or am I way off?"

**Then STOP and proceed with what you have.** Perfect clarity is the enemy of shipped work.

## When to Grill

| Situation | Grill? |
|-----------|--------|
| Multi-step task | YES — decompose after you understand |
| Vague request ("fix it", "make it better") | YES — desperately |
| Clear, specific request ("rename X to Y") | NO — skip, just do it |
| Bug report with repro steps | LIGHT grill — verify scope |
| New feature | YES — full grill |
| User already clarified in follow-up | NO — they already answered |

## Output

After grilling, you have:
1. **Real requirement** — what they actually need (not what they said)
2. **Constraints** — what can't change, deadlines, scope limits
3. **Success criterion** — how we know it's done
4. **Scope boundaries** — what's IN and what's OUT

This feeds directly into the PLANNING phase.

## Example

**User:** "The checkout is broken."

**Grill:**
- Restate: "Checkout is broken."
- Probe: "What happens when you try to check out?" / "When did this start?" / "All users or specific ones?" / "What's the error?" / "What checkout flow — web, mobile, both?"
- User: "It times out on mobile after you enter payment info. Started yesterday. All mobile users. No error, just hangs."
- Confirm: "So the real issue is: mobile checkout hangs after payment entry on all devices, started yesterday. Not 'checkout is broken.' The fix scope is the mobile payment submission flow. Correct?"

**That's the real requirement.** Not "fix checkout" — "fix the mobile payment submission timeout."
