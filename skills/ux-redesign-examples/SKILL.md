---
name: ux-redesign-examples
description: "UX redesign patterns from real AB tests. Covers paywall optimization, price presentation, and booking screen psychology. Use when designing paywalls, pricing pages, booking flows, or conversion-focused screens."
version:1.0.0
---

# UX Redesign Examples

Load this skill when redesigning paywalls, pricing screens, booking flows, or any conversion-focused interface.

## Three Core Patterns

### Pattern1: Paywall Questions
**The Insight:** Every screen asks the user a question. The question determines whether they act or hesitate.

**Bad Pattern (Hard Question):**
- Headline: "Get access to1,000+ games"
- Price: $19/month
- Features:3 bullet points
- Button: "Subscribe and start7 days free"
- **Question asked:** "Is this worth $19/month?" → Homework → "I'll think about it later"

**Good Pattern (Easy Question):**
- Headline: "How your free trial works"
- Timeline: Today → Day5 → Day7
- Day5 note: "We'll remind you before charging"
- Button: "Start my free trial" + "Start in2 taps"
- **Question asked:** "Can I try this for free?" → Obvious yes

**Key Elements:**
1. **Timeline beats feature list** - Show what happens when, not what you get
2. **Transparency builds trust** - "We'll remind you before charging" triggers transparency bias
3. **"Start" beats "Subscribe"** - Light beginning vs heavy commitment
4. **"My" beats "Your"** - Creates ownership before action
5. **Specific numbers kill uncertainty** - "2 taps" beats "quick setup"
6. **Show the product** - Actual characters vs decorative illustrations

### Pattern2: Price Presentation
**The Insight:** How you show a number matters more than the number itself.

**Bad Pattern (Ranges):**
- Go X:$13-17
- Comfort:$17-22
- Go XL:$16-21
- **Problem:** Brain anchors on high number, too many unknowns → no decision

**Good Pattern (Single Numbers):**
- Go X:$15 (12:53 PM,2 min away)
- Comfort:$19
- Go XL:$18
- Badge: "cheaper" (green)
- **Solution:** Clear comparison, reframes cost as convenience

**Key Elements:**
1. **Single numbers beat ranges** - Eliminates mental negotiation
2. **Anchoring works both ways** - High anchor makes others seem cheap
3. **Time reframes cost** - "2 min away" shifts from price to convenience
4. **One-word badges do thinking** - "cheaper" categorizes without explanation
5. **Destination first** - Commitment consistency (already decided where)
6. **Evaluative ease** - Less work = more likely to decide

### Pattern3: Booking Screen Emotion
**The Insight:** Informing doesn't book villas. Transporting does.

**Bad Pattern (Informative):**
- Small photo thumbnail
- Title: "Beach house with garden"
- Price:€89/night
- Form fields: Check-in, Check-out, Guests
- Button: "Reserve"
- **Result:** Filling out a form → no excitement

**Good Pattern (Emotional):**
- Large photo (top half of screen)
- Navigation badges: Superhost, Guest favorite
- Title: "Beachside escape steps from the sand"
- Price: ~~€129~~ €89 (-31% badge)
- Dates: "Friday, March28 → Wednesday, April2" (5 nights badge)
- Button: "Reserve $445 total" + "Free cancellation before March26"
- **Result:** Transported to the place → emotional connection

**Key Elements:**
1. **Size creates feeling** - Large photos transport, small thumbnails inform
2. **Sensory language** - "Steps from the sand" activates imagination
3. **Anchoring for deals** - Strikethrough price makes current feel like a win
4. **Day names make trips real** - "Friday arrival" beats "March28"
5. **Night count saves math** - Removes cognitive friction
6. **Total price eliminates anxiety** - No hidden fees fear
7. **Cancellation answers objection** - "What if plans change?" answered before asked

## Quick Reference

| Screen Type | Bad Pattern | Good Pattern |
|-------------|-------------|--------------|
| Paywall | Feature list + price | Timeline + transparency |
| Pricing | Ranges/negotiation | Single numbers + anchors |
| Booking | Form to fill | Emotion to feel |
| Signup | What they'll get | How it works |
| Upgrade | Gain framing | Loss framing |

## Design Checklist

### Paywalls
- [ ] Ask easy question, not hard one
- [ ] Show timeline, not feature list
- [ ] Include "we'll remind you" transparency
- [ ] Use "Start" not "Subscribe"
- [ ] Use "my" not "your"
- [ ] Include specific number ("2 taps")
- [ ] Show actual product, not decoration

### Pricing
- [ ] Single numbers, not ranges
- [ ] Control what they see first (anchor)
- [ ] Add time/convenience context
- [ ] Use one-word badges ("cheaper")
- [ ] Show destination/commitment first

### Bookings
- [ ] Large hero image (top half)
- [ ] Emotional titles ("escape" not "house")
- [ ] Strikethrough anchoring
- [ ] Day names + night count
- [ ] Total price upfront
- [ ] Free cancellation badge

## Integration
- **MCPs:** Browser MCP for testing conversion flows
- **AgentMemory:** Save A/B test results, conversion patterns
- **Related Skills:** ux-psychology (core principles), impeccable (command-driven design tool)

## Common Mistakes
- ❌ Asking "Is this worth $X?" instead of "Can I try for free?"
- ❌ Showing price ranges instead of single numbers
- ❌ Small thumbnails instead of immersive photos
- ❌ Form fields before emotional connection
- ❌ "Subscribe" buttons with commitment weight
- ❌ Hiding total price or cancellation terms

## Success Metrics
- Reduced paywall bounce
- Increased trial starts
- Higher booking conversion
- Lower price perception friction
- Improved trust signals