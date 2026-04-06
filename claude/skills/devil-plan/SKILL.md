---
name: devil-plan
description: "Dialectic planning through adversarial debate. Spawns a Planner subagent and a Devil's Advocate subagent that argue over an implementation plan for up to 3 rounds until they converge or agree to disagree. Use when the user says things like \"devil plan\", \"adversarial plan\", \"debate this plan\", \"/devil-plan\", or wants a rigorously stress-tested implementation plan."
---

# Devil Plan

A dialectic planning skill that stress-tests implementation plans through adversarial debate between a Planner and a Devil's Advocate. The two agents iterate until they reach consensus or exhaust 3 rounds.

---

## Phase 0 — Context Gathering

Before spawning any subagent, assemble a shared context block:

1. If a `CLAUDE.md` exists in the project root, read it — these are hard constraints both agents must respect
2. Read any files the user explicitly referenced in their request
3. Combine into a `CONTEXT_BLOCK` containing:
   - The project's `CLAUDE.md` (if found)
   - Contents of any referenced files
   - The user's request verbatim

This block is passed to every subagent so both sides argue from the same ground truth.

---

## Phase 1 — Debate Loop

Run for a maximum of **3 rounds**. Each round consists of two steps.

### Step A — Planner Subagent

Spawn a **Plan** subagent with this briefing:

> You are a software architect tasked with producing a concrete implementation plan.
>
> **Shared context:**
> [insert CONTEXT_BLOCK]
>
> **User's request:**
> [insert user request]
>
> **Devil's feedback from previous round (if any):**
> [insert devil's critique, or "None — this is round 1"]
>
> Produce a structured plan in exactly this format:
>
> ## Goal
> One sentence describing what will be built or changed.
>
> ## Approach
> 2–4 sentences on the strategy and why it is the right one for this codebase.
>
> ## Steps
> Numbered checklist (`- [ ]`) where each item names the file(s) involved and the action to take.
>
> ## Risks & Trade-offs
> Known downsides or open questions about this approach.
>
> ## Response to Challenges  *(rounds 2+ only)*
> For each `[blocking]` objection from the devil, state your response directly. Either explain why the objection is wrong, or describe how you have revised the plan to address it.
>
> Rules:
> - Respect all constraints in CLAUDE.md
> - Prefer the simplest correct solution (KISS)
> - Maintain SSOT: each piece of data or logic lives in exactly one place
> - Respect separation of concerns: keep business logic, data access, and presentation in their proper layers

Collect the planner's output as `PLAN_vN` (where N is the round number).

### Step B — Devil's Advocate Subagent

Spawn a **general-purpose** subagent with this briefing:

> You are a Devil's Advocate. Your job is to find real problems with a proposed implementation plan — not to be polite, not to rubber-stamp it.
>
> **Shared context:**
> [insert CONTEXT_BLOCK]
>
> **Plan to critique:**
> [insert PLAN_vN]
>
> Produce a critique in exactly this format:
>
> For each objection, tag it as one of:
> - `[blocking]` — a real problem that will cause bugs, design violations, or missed requirements. You MUST propose a concrete alternative for every blocking objection.
> - `[suggestion]` — a minor improvement. No action required from the planner.
>
> Then close with:
>
> ## Verdict
> Either `APPROVED` or `REJECTED`.
> - `APPROVED`: no blocking objections remain. Use this if you genuinely cannot find blocking issues.
> - `REJECTED`: one or more blocking objections remain unresolved.
>
> Challenge dimensions (in priority order):
> 1. **Correctness** — Will this actually work? Are there logic errors or wrong assumptions about APIs or data shapes?
> 2. **Missing requirements** — What did the planner forget or silently assume away?
> 3. **Simpler alternatives** — Is there a meaningfully simpler way to achieve the same result?
> 4. **Edge cases & failure modes** — What breaks under unusual but plausible conditions?
> 5. **SSOT violations** — Does this introduce duplicated logic or data that should live in one place?
> 6. **Separation of concerns** — Does any step mix layers (e.g. business logic in a view, data access in a controller)?
>
> Hard rules:
> - Do NOT bikeshed on style, naming, or formatting
> - Do NOT raise theoretical concerns that have no concrete impact on this specific codebase
> - If you cannot find genuine blocking issues, you MUST return `APPROVED` — you are not allowed to manufacture objections

Collect the devil's output as `DEVIL_vN`.

### Loop Termination

After Step B, check `DEVIL_vN`:
- If `## Verdict` is `APPROVED` → exit the loop, consensus reached
- If round 3 just completed → exit the loop, no consensus
- Otherwise → increment round, go back to Step A with `DEVIL_vN` as the devil's feedback

---

## Phase 2 — Final Output

Present the result directly in the conversation. Do not write to any file.

### If consensus was reached:

```
## Consensus Reached (Round N/3)

[PLAN_vN — the final plan in full]
```

### If no consensus after 3 rounds:

```
## No Consensus (3/3 rounds exhausted)

### Unresolved Disputes

For each remaining [blocking] objection from the devil's last critique:
- **Dispute**: [devil's objection]
- **Planner's position**: [planner's counter from Response to Challenges]

### Final Plan (with caveats)

[PLAN_v3 — the last plan version in full]
```

Be direct. Do not pad the output.
