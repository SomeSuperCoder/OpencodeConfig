# 👑 Director's Playbook — You Run the Company

**This system is a software company. You are the Director. The Team Lead runs it day-to-day; you set direction.**

---

## The Org Chart

```
         👑 YOU — DIRECTOR
            vision · priorities · approvals · final decisions
                     │  directives flow DOWN
                     ▼
         🧠 TEAM LEAD (tech-lead)
            plans · assigns staff · reviews · reports to you
                     │  requests orchestration advice DOWN
                     ▼
         🧑‍💼 FIELD LEADS (team/lead/*)
            frontend · backend · quality · security · platform · product · research
            plan microtasks · recommend specialist IDs · NEVER spawn
                     ▼
         👥 STAFF (63 specialists)
            engineers · QA · security · auditors · designers · ...
                     ▲  work reports flow UP
```

**One rule governs everything: directives flow DOWN, reports flow UP.**
- You brief → the Team Lead plans → Field Leads advise on their field → the Team Lead spawns the specialists → the work → the Team Lead verifies → you get the report.
- Staff never report to you directly; everything lands on your desk through the Team Lead.
- Field Leads never spawn: they recommend which specialist handles each microtask; the Team Lead keeps command and does the spawning.

---

## Your Powers

| Power | How You Use It |
|-------|----------------|
| **Direct** | Say what you want in one line. The Team Lead plans, staffs, executes, reports. |
| **Prioritize** | "This first, that later." You set the order of work. |
| **Approve** | Sign off on specs, scope, and architecture before big work starts. |
| **Decide** | Every escalation the Team Lead flags comes to you. Options + deadline — you pick. |
| **Hire / fire** | Add or remove staff (specialist agents) when a capability is missing. |
| **Review** | Company reports, standups, and "DECISIONS MADE WHILE YOU WERE AWAY" minutes. |
| **Go dark** | Say `I'm going` — the company runs autonomously until `I'm back`. |

---

## How to Command

**You don't need to be an expert. You need to be clear.**

- **Give a directive:** `Build X` / `Fix Y` / `Investigate Z` / `Refactor the auth module`.
- **Set priority:** `X first, then Y.` — that's enough; the Team Lead sequences the rest.
- **Set constraints:** `Keep it simple.` / `Don't touch payments.` / `Must ship today.`
- **Approve or redirect:** `Good, proceed.` / `No — smaller scope, here's why.`
- **Ask for status:** `Standup` / `Status` / `Where are we?`
- **Trigger autonomous mode:** `I'm going` (company runs solo; you review on return) then `I'm back`.

---

## What Comes Back To You

| Artifact | What It Is |
|----------|------------|
| **Plan brief** | The Team Lead announces the plan + staff before executing. |
| **Work report** | Every completed directive: verdict + evidence + files + next owner. |
| **Escalation** | 🚦 A decision only you can make — presented with options and a deadline. |
| **Standup** | On-request summary: what's done, what's in flight, what's blocked. |
| **Board minutes** | DECISIONS MADE WHILE YOU WERE AWAY — reviewed when you return. |
| **Recovery report** | After an interruption: what survived, what was lost, what was re-verified. |

---

## The Company Ethos

- **Done means tested, documented, deployed, maintained.** Untested work is not done.
- **Verified work only.** Nothing is committed without tests + QA sign-off.
- **Your word is law.** Ambiguity? Say it again. Done? You decide.
- **The Team Lead escalates, never guesses.** If it's your call, it comes to you.

*You're not writing code. You're directing a company that ships software that matters.*
