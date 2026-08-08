# Plan: Self-Reflection Reports to OpencodeImprovements

## Context

The user wants the Tech Lead to archive agent self-reflection data to `~/OpencodeImprovements/` so the Director can see where agents underperform and improve system prompts and AGENTS.md accordingly.

**Current state:**
- AGENTS.md requires agents to self-reflect before handoff (3 questions about exploration, skill loading, re-verification)
- Tech Lead already has a SELF-IMPROVEMENT section directing improvement reports to `~/OpencodeImprovements/reports/`
- But there's no mechanism to collect agent self-reflections and write them to disk
- The REPORT_TEMPLATE.md exists but is for harness improvement reports, not agent self-reflections

**User decisions:**
- Format: Structured template (like improvement reports)
- Scope: Only when agents admit underperformance (NOT on external failures like network issues, provider problems, token exhaustion)
- Writer: Tech Lead writes all reports

---

## Changes Required

### 1. Create Self-Reflection Report Template

**File:** `/home/allen/OpencodeImprovements/SELF_REFLECTION_TEMPLATE.md`

New template specifically for agent self-reflections, separate from the harness improvement reports.

```markdown
# Agent Self-Reflection Report

**Date:** YYYY-MM-DD
**Agent:** [agent name/type]
**Task:** [what the agent was asked to do]
**Microtask ID:** [if tracked]

---

## Agent's Self-Admission

<!-- Quote the agent's own self-reflection from their handoff. What did they admit?
     Examples:
     - "I loaded skill X unnecessarily — could have been skipped"
     - "I had to read [file] because spawn was missing it"
     - "I re-ran [test] that [agent] already confirmed"
     - "I explored files not in my spawn prompt" -->

## Classification

<!-- What type of underperformance? -->
- [ ] Exploration beyond spawn data
- [ ] Unnecessary skill loading
- [ ] Re-verification of already-verified work
- [ ] Lane crossing (did another agent's job)
- [ ] Token waste (burned tokens without value)
- [ ] Missing data in spawn prompt (Tech Lead's failure)
- [ ] Other: ___

## Root Cause Analysis

<!-- Why did this happen? What in the system prompts or AGENTS.md enabled/failed to prevent it? -->

## Impact

<!-- How many tokens wasted? What was the downstream effect? -->

## Suggested Fix

<!-- What change to AGENTS.md, agent prompts, or workflow would prevent this?
     Be specific: "Add rule X to agent Y's prompt" or "Update AGENTS.md section Z" -->

## Evidence

<!-- Links to the handoff, relevant code, or conversation that supports this. -->

---

**Status:** pending | in_review | implemented | dismissed
```

---

### 2. Update Tech Lead - Add Self-Reflection Archiving Section

**File:** `/home/allen/.config/opencode/agents/team/tech-lead.md`

Add a new subsection under the existing SELF-IMPROVEMENT section (after line 1110) for archiving agent self-reflections.

**New section to add:**

```markdown
## 📝 AGENT SELF-REFLECTION ARCHIVING

**When an agent admits underperformance in their handoff, you MUST archive it to `~/OpencodeImprovements/reports/` so the Director can improve the system.**

### What Counts as Underperformance (ARCHIVE THESE)
- Agent admits exploring files not in spawn prompt
- Agent admits loading skills unnecessarily
- Agent admits re-verifying already-verified work
- Agent admits lane crossing (did another agent's job)
- Agent admits token waste
- Agent reports spawn prompt was missing data (your failure → archive it)
- Any self-reflection where the agent says "I should have..." or "I wasted..."

### What Does NOT Count (DON'T ARCHIVE)
- Network failures, provider errors, API timeouts
- Token exhaustion / usage limits
- External system failures
- The agent failed because of bad input from upstream (that's a different problem)

### How to Archive
1. Read the agent's handoff → extract the self-reflection section
2. If agent admitted underperformance → write a report using the template
3. Save to: `/home/allen/OpencodeImprovements/reports/YYYY-MM-DD_<agent>_<short-description>.md`
4. Update the agent's handoff status to include "archived: [filename]"

### Template
Use: `/home/allen/OpencodeImprovements/SELF_REFLECTION_TEMPLATE.md`

### Why This Matters
These reports are the Director's raw data for improving the system. Every admission of underperformance is a signal that a rule in AGENTS.md or an agent's prompt needs tightening. Without this data, the system can't improve.
```

---

### 3. Update Tech Lead Handoff Collection to Include Archiving

**File:** `/home/allen/.config/opencode/agents/team/tech-lead.md`

Update the Arbiter Loop (around line 778) to include self-reflection archiving step.

**Current (line 778):**
```
5. COLLECT work reports. LANE-CHECK each (no other agent's job was done).
```

**Updated:**
```
5. COLLECT work reports. LANE-CHECK each (no other agent's job was done). ARCHIVE self-reflections if agent admitted underperformance (see 📝 AGENT SELF-REFLECTION ARCHIVING).
```

---

### 4. Update AGENTS.md Self-Reflection Section

**File:** `/home/allen/.config/opencode/AGENTS.md`

Clarify the self-reflection section (around line 560-570) to distinguish between underperformance vs external failures.

**Current (lines 560-570):**
```markdown
#### 3. Self-Reflection BEFORE Handoff (post-flight)

**Before you hand off, answer these 3 questions (internally, in your report):**

1. Did I explore anything I wasn't given? → If YES, flag it: "I had to read [X] because spawn was missing it."
2. Did I load a skill I didn't need? → If YES, note: "Loaded [skill] unnecessarily — could have been skipped."
3. Did I re-verify something already verified? → If YES, note: "Re-ran [X] that [agent] already confirmed."

**These are not confessions — they are IMPROVEMENT DATA.** The Tech Lead uses them to fix spawn prompts, reduce waste, and tighten the pipeline.
```

**Updated:**
```markdown
#### 3. Self-Reflection BEFORE Handoff (post-flight)

**Before you hand off, answer these 3 questions (in your report):**

1. Did I explore anything I wasn't given? → If YES, state it: "I had to read [X] because spawn was missing it."
2. Did I load a skill I didn't need? → If YES, state: "Loaded [skill] unnecessarily — could have been skipped."
3. Did I re-verify something already verified? → If YES, state: "Re-ran [X] that [agent] already confirmed."

**These are not confessions — they are IMPROVEMENT DATA.** The Tech Lead archives them to `~/OpencodeImprovements/reports/` so the Director can improve the system.

**⚠️ ONLY report underperformance you caused. Do NOT report:**
- Network failures, provider errors, API timeouts → external, not your fault
- Token exhaustion → resource constraint, not your fault
- Bad input from upstream → report it, but it's not YOUR underperformance

**Your self-reflection = what YOU did wrong, not what went wrong around you.**
```

---

### 5. Update Tech Lead Self-Improvement Section

**File:** `/home/allen/.config/opencode/agents/team/tech-lead.md`

Update the existing SELF-IMPROVEMENT section (lines 1080-1110) to reference the new archiving process.

**Add after line 1110:**

```markdown
### How Self-Reflection Feeds Into This
1. Agents admit underperformance in their handoffs
2. You archive those admissions to `~/OpencodeImprovements/reports/`
3. The Director reviews the reports → identifies patterns
4. Director approves changes to AGENTS.md or agent prompts
5. You implement the changes → system improves

**The cycle: Agent admits mistake → You archive it → Director sees pattern → System gets fixed → Fewer mistakes.**
```

---

## Files to Modify

| File | Change |
|------|--------|
| `/home/allen/OpencodeImprovements/SELF_REFLECTION_TEMPLATE.md` | **CREATE** — new template for agent self-reflections |
| `/home/allen/.config/opencode/agents/team/tech-lead.md` | **UPDATE** — add archiving section, update arbiter loop, update self-improvement section |
| `/home/allen/.config/opencode/AGENTS.md` | **UPDATE** — clarify self-reflection section to distinguish underperformance vs external failures |

---

## Verification

1. **Read the updated tech-lead.md** — verify the new archiving section exists and is clear
2. **Read the updated AGENTS.md** — verify the self-reflection section is clarified
3. **Read the new template** — verify it captures the right fields
4. **Trace the flow** — agent handoff → Tech Lead reads → archives if underperformance → Director reviews

---

## Questions for Director

None — the requirements are clear. Ready to implement.
