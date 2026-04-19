---
name: iterate-plan
description: Iteratively draft and harden an implementation plan from a prompt or spec file, running up to 5 review rounds with decision-locking until all readiness checks pass or the round cap is reached. Use when the user says things like "iterate on a plan", "harden this plan", "/iterate-plan", or gives a prompt/spec and wants a rigorously refined implementation plan.
---

# Iterate Plan

Draft an implementation plan and harden it through bounded review rounds. The goal is a plan a developer could execute without follow-up questions, reached without bikeshedding or infinite revision.

**Must run inside plan mode.** If plan mode is not active, stop immediately and tell the user: *"This skill must run in plan mode. Type `plan` to enter plan mode, then re-invoke /iterate-plan."* Do not proceed.

---

## Phase 0 — Setup

1. Confirm plan mode is active. If not, halt per the note above.
2. Identify the input:
   - If the user gave a path to a `.md` file, read it in full.
   - Otherwise, treat the user's message as the prompt verbatim.
3. Identify the plan file path:
   - If the plan-mode system specified one, use it.
   - Otherwise, ask the user for a path in a single question.
4. Read `CLAUDE.md` (project root, if present) and any files the input references. These are hard constraints every round must respect.
5. Assemble a `CONTEXT_BLOCK` containing the input, `CLAUDE.md`, and referenced-file contents. Keep it in mind across rounds — ground truth does not change.

---

## Phase 1 — Initial Draft

Write the first version of the plan to the plan file. Include these sections, in this order:

- `## Implementation Contract` — the binding clause, written verbatim from the template below. Must be the first section.
- `## Context` — why this change, what problem it solves
- `## Approach` — the strategy, in 2–4 sentences
- `## Files to modify` — concrete paths and what changes in each
- `## Steps` — numbered `- [ ]` checklist
- `## Verification` — how to test end-to-end
- `## Locked Decisions` — starts empty. Records binding architectural choices the **user** made by answering a clarification question (e.g. "use X or Y?" → user answers X → "X" is logged). Every entry is user-authored; the agent never locks a decision it made on its own.
- `## Scope Additions` — starts empty; records every scope expansion the user accepted and why

**Implementation Contract template — copy verbatim into every plan:**

```markdown
## Implementation Contract

This plan is the agreed approach. Follow it faithfully.

- **No silent rewrites.** If you encounter unexpected complexity, a "better" approach, or friction (large file counts, unfamiliar edge cases, cleaner refactors you spot mid-flight), STOP. State `⛔ DEVIATION DETECTED: …` and wait for explicit approval before changing approach.
- **Volume is not a reason to deviate.** "52 functions to modify" is a workload, not a signal to re-architect. If the plan says touch 52 functions, touch 52 functions.
- **Locked Decisions are axioms.** Items in `## Locked Decisions` may not be revisited, simplified away, or "improved" during implementation.
- **Scope is fixed.** Do not add features beyond `## Scope Additions`. Do not post-hoc defer work the plan lists as in-scope.
- **Friction reports, not workarounds.** Newly discovered edge cases, API mismatches, or complexity surprises are reasons to stop and ask, never reasons to pick a different path.
```

Do not call `ExitPlanMode` yet. Proceed to Phase 2.

---

## Phase 2 — Iteration Loop

Run up to **5 rounds**. Each round has four steps.

### Step A — Review

Read the current plan file in full, validate it against the current codebase. Collect findings across these dimensions. Only list categories with actual findings.

**Universal checks (every round):**
1. **SSOT violations** — duplicated state, config, or logic across sections
2. **Separation of concerns** — mixed layers (business logic in view, I/O in domain, etc.)
3. **Fail-fast / no silent fallbacks** — `unwrap_or`, default-on-error, swallowed errors
4. **Scope discipline** — adjacent features added without anchoring a design decision (feature creep, not dead-code-avoidance)
5. **Verifiability** — missing or vague "how to verify" section
6. **No backwards-compat cruft** — migration shims, deprecated aliases, re-exports without justification
7. **Anchor check** — every struct, API, or algorithm in the plan has at least one concrete caller or exercise in scope. If not, the finding is "drop it or grow scope" — never leave a floating design element.
8. **Deferral hygiene** — every "defer to later" note must be strictly additive: a new command, new flag, or isolated module that can be bolted on without touching existing code. If the deferred feature would require changing data structures, function signatures, module boundaries, or architecture when added later, the deferral is invalid — implement it now. Retrofit cost is not a factor; cheap and expensive retrofits both disqualify deferral.
9. **Approach stability** — after round 1, the `## Approach` section must be semantically identical to the round-1 version unless a prior `⛔ APPROACH CHANGE` clarification was approved by the user. Any unsanctioned drift is a finding: revert it, or raise the change as a clarification.

**Scope-specific checks:**
10. Contradictions (instructions that conflict)
11. Ambiguities (vague directives, unspecified targets)
12. Missing instructions (referenced but undefined steps, absent prerequisites)
13. Logic gaps (order errors, missing intermediate steps)

**Never re-challenge anything in `## Locked Decisions`.** If a finding contradicts a locked decision, drop it.

### Step B — Classify

For each finding, decide:
- **Unambiguous fix** — the correction is obvious and mechanical (missing path, wrong order, duplicated section). Apply it in Step C.
- **Needs clarification** — genuinely needs the user's intent. Add to the question batch.
- **Fix vs. document** — always choose fix. Never downgrade an issue to a disclaimer.

### Step C — Apply & Ask

1. Apply every unambiguous fix to the plan file using `Edit` (or `Write` only for full rewrites). Do not silently add content the user did not ask for — scope expansions and approach changes follow the clarification rules in points 3 and 4.
2. For every clarification the user answered this round with a binding architectural choice, append their answer to `## Locked Decisions` as a one-line bullet: `<choice> — per user clarification, round N`. Locked Decisions are always user-authored; never lock a choice the agent made on its own.
3. If the anchor check (or any other finding) requires growing the plan beyond the original prompt, **never add the expansion silently**. Raise it as a clarification question — phrased as "drop X or expand scope to include Y?" — and apply the user's choice. If they accept the expansion, log it in `## Scope Additions` with the design element it anchors.
4. If the `## Approach` section needs to change after round 1, raise it as a `⛔ APPROACH CHANGE: <old> → <new> because <reason>` clarification. Apply the change only with explicit user approval; log the approved approach as a Locked Decision.
5. If there are clarification questions, ask them all in a **single numbered list** via `AskUserQuestion`. Wait for answers, then apply them.

### Step D — Readiness Check

Evaluate each of the 13 checks from Step A as **PASS** or **FAIL**. A check is PASS only if Step A surfaced zero findings for it this round.

Exit the loop if either:
- All 13 checks PASS, OR
- Round 5 just completed.

Otherwise increment the round counter and return to Step A.

The loop is fully automated. The agent stops only to ask clarifications it cannot resolve on its own — never to request permission to continue, skip, or terminate.

---

## Phase 3 — Final Output

1. Report the final pass/fail tally (e.g. `13/13 PASS` or `11/13 PASS`) and the round count reached.
2. If any check is FAIL after 5 rounds, list those FAIL items as remaining blockers in one terse bulleted list.
3. Call `ExitPlanMode` to hand the plan to the user for approval.

Do **not** commit. Do **not** start implementation. The skill ends at `ExitPlanMode`.

---

## Hard rules

- **Never re-open a locked decision.** Once in `## Locked Decisions`, it is settled. Round N+1 treats it as an axiom.
- **Locked Decisions are user-authored.** The agent only *records* them, never *makes* them. An entry exists because the user answered a clarification; no entry should appear without a matching question in the conversation.
- **Lock the Approach after round 1.** The `## Approach` section is frozen from round 2 onward. Any change requires a `⛔ APPROACH CHANGE` clarification approved by the user; the approved approach is logged as a Locked Decision.
- **Batch questions.** One numbered list per round, never one-at-a-time questions.
- **Prefer fix over document.** If a finding can be resolved by editing the plan, edit the plan. Do not paper over it with a caveat.
- **Respect `CLAUDE.md`.** Project-level constraints outrank every other consideration.
- **Bounded iteration.** 5 rounds is a hard cap. Do not go to round 6 "just this once".
- **No silent scope expansion.** Expansions are allowed only to anchor a design decision (avoid dead code, pin a floating struct/algorithm). Every expansion must be raised as a clarification, never added unilaterally, and logged in `## Scope Additions` once accepted.
- **Defer only additively.** A feature is deferrable only if the retrofit cost is bounded and localized — e.g., adding a new enum variant, a new handler, or a new CLI flag — not if it requires restructuring existing code paths. Anything that would require a retrofit — cheap or expensive — must be implemented now.
- **Stamp the contract.** Every final plan must begin with the `## Implementation Contract` section, copied verbatim from the Phase 1 template. Do not call `ExitPlanMode` if it is missing.

## Output Format

After the loop exits, close with:

```
## Readiness: N/13 PASS (R/5 rounds)

### Locked Decisions
- [decision 1] — per user clarification, round N
- [decision 2] — per user clarification, round N

### Scope Additions (if any)
- [addition] — the design element it anchors

### Remaining Blockers (if any check FAIL)
- [check name] — why it's unresolved
```

Then call `ExitPlanMode`. Be direct. Do not pad the report.
