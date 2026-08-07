---
name: ux-psychology
description: "UX psychology principles for conversion optimization. Covers smart defaults, goal gradient effect, reciprocity, IKEA effect, loss aversion, and contrast effect. Use when designing onboarding flows, paywalls, booking screens, signup forms, or any conversion-focused interface."
version:1.0.0
---

# UX Psychology Principles

Load this skill when designing conversion-focused interfaces, onboarding flows, paywalls, or signup forms.

## Core Principles

### 1. Smart Defaults
**Principle:** Pre-fill forms with the most common choices. 70-90% of users never change defaults.

**Why it works:** Users read defaults as recommendations. The job shifts from "fill from scratch" to "scan and adjust."

**Application:**
- Pre-select the most common option for every field
- Show result count ("12 results waiting") to reduce perceived effort
- Never show blank forms when you know the answer

**Example:** Booking screen with pre-filled dates, guests, and search button showing "12 results waiting" vs empty form.

### 2. Goal Gradient Effect
**Principle:** The closer people feel to finishing, the faster they move toward completion.

**Why it works:** Progress creates momentum. Starting at zero feels deflating; starting at 20% feels like momentum.

**Application:**
- Never start users at zero progress
- Count any prior action as step one
- Show progress bars that start at 20%+ for signups
- LinkedIn shows profile strength meter that's never at zero

**Example:** Onboarding showing 20% complete with first step checked vs0% with5 empty steps.

### 3. Reciprocity
**Principle:** When someone gives you something first, you feel a pull to return the favor.

**Why it works:** It's one of the deepest human instincts. Free samples increase purchases by up to2,000%.

**Application:**
- Give value before asking for signup
- Show partial results (score, top issues) before requiring account
- Free trials without credit card upfront
- Costco samples, Spotify30-day premium, Notion full product access

**Example:** SEO tool showing blurred results behind lock vs showing actual report with "Want complete breakdown? Save your report."

### 4. IKEA Effect
**Principle:** When people build something themselves, they value it significantly more.

**Why it works:** Investment of time/effort creates ownership. Even small choices create attachment.

**Application:**
- Let users customize before signing up (name, title, colors, style)
- Use "Continue" instead of "Sign Up" when they've already invested
- Duolingo: language, goal, first lesson before account creation
- Make closing feel like abandoning something they made

**Example:** Signup page with email/password vs pre-signup customization where user chooses name, title, colors.

### 5. Loss Aversion
**Principle:** The pain of losing something is psychologically twice as powerful as gaining the same thing.

**Why it works:** Humans are wired to protect what they already have. Status quo bias makes inaction feel safer.

**Application:**
- Frame features as what they'll lose, not what they'll gain
- Show actual files/data at risk with countdown
- Make dismiss options feel risky ("I'll risk it" vs "Maybe later")
- Threats beat pitches because they activate loss aversion

**Example:** Storage app upgrade showing "Upgrade now" vs showing actual files with countdown and "I'll risk it" dismiss.

### 6. Contrast Effect
**Principle:** Your brain evaluates information relative to what it saw immediately before.

**Why it works:** The first number becomes the ruler. $50 feels expensive alone, cheap after $1900.

**Application:**
- Never show cost in isolation
- Show expensive option first to make others seem reasonable
- Use percentages after large numbers ("just2.6%")
- Restaurants put $90 steak to make $40 salmon look reasonable

**Example:** Protection plan $50/month alone vs $50 after $1900 laptop with "just2.6%" label.

## Quick Reference

| Principle | Key Question | Design Rule |
|-----------|--------------|-------------|
| Smart Defaults | "What do most users choose?" | Pre-fill everything |
| Goal Gradient | "How close do they feel to done?" | Start at 20%+ |
| Reciprocity | "What can I give first?" | Show value before asking |
| IKEA Effect | "What have they built?" | Let them invest before signup |
| Loss Aversion | "What will they lose?" | Frame as loss, not gain |
| Contrast Effect | "What did they see first?" | Control the anchor |

## Integration
- **MCPs:** Browser MCP for testing conversion flows
- **AgentMemory:** Save conversion patterns, A/B test results
- **Related Skills:** impeccable (design craft), a11y-patterns (accessibility)

## Common Anti-Patterns
- ❌ Blank forms with no defaults
- ❌ Progress starting at0%
- ❌ Asking for signup before giving value
- ❌ "Maybe later" dismiss options
- ❌ Price shown in isolation
- ❌ Features framed as gains

## Success Metrics
- Reduced form abandonment
- Increased signup completion
- Higher conversion rates
- Lower bounce on paywalls
- Improved onboarding completion