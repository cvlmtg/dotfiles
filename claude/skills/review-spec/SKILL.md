---
name: review-spec
description: Review SPEC.md / ROADMAP.md for contradictions, ambiguities, missing instructions, logic gaps. Ask clarifying questions, adds checkboxes to step-based sections if absent, (draft `## Implementation Plan` if none), update and save the spec. Never add checkboxes in descriptive sections. Use when the user says "review the spec", "check the spec", "/review-spec", or names a specific spec file.
---

# Spec Review

A structured review of a spec file (SPEC.md or ROADMAP.md) to catch issues before implementation begins. The goal is a clear, complete, unambiguous spec that a developer could follow without needing to ask questions.

## Setup

1. Identify the spec file:
 - If the user named a file, use that path.
 - Otherwise, look for `ROADMAP.md` or `SPEC.md` in the current working directory or repository root.
 - If not found, ask the user where the spec file is.
 - If the user wants a *fresh executable plan* hardened through review rounds (not in-place edits to the spec doc), use `/forge-plan` instead.
2. Read the full spec file before doing anything else.
3. Read `CLAUDE.md` (project-level, if it exists) to understand project conventions and constraints — these inform whether the spec is aligned with the project's rules.

---

## Review Pass

Work through each dimension below. Collect all findings before asking questions or making changes.

### 1. Internal Contradictions
- Instructions that conflict with each other (e.g., "use X library" in one step, "avoid X" in another)
- Steps that produce output incompatible with what a later step expects
- Scope or goal statements that contradict implementation details

### 2. Ambiguities
- Vague directives without actionable detail ("make it fast", "clean up the code", "handle errors")
- Unspecified targets: which file, which function, which module?
- Undefined terms or acronyms without explanation
- Steps where the "done" condition is unclear

### 3. Missing Instructions
- Steps referenced but never defined
- Prerequisites assumed but not listed (dependencies, setup, environment)
- Teardown or rollback steps missing where the spec modifies shared state
- Open questions listed without a resolution path

### 4. Logic Gaps
- Steps whose order doesn't make sense (a step depends on output from a later step)
- Missing intermediate steps between two non-trivially-connected steps
- Steps that assume a state that hasn't been established yet
- A goal stated without a clear path to reach it

### 5. Checkbox Audit

Checkboxes belong **only inside designated tracker section**. Tracker section = top-level (`##`) heading matching, case-insensitive:

- `Implementation Plan`
- `Tasks`
- `TODO` / `To Do`
- `Checklist`
- `Delivery` / `Delivery Plan`
- `Milestones`
- `Roadmap` (only as sub-section inside larger spec, not as document title)

Everything else — `Pages`, `Boards`, `Cards`, `UI`, `Database`, `Auth`, `Tech stack`, etc. — is **descriptive**. Keeps plain bullets even when wording sounds actionable (`- Cards can be deleted`, `- Boards will have:`, `- The owner can invite other users`). Wording is not the signal; section is.

**Inside tracker section:**
- Convert plain `-` / `*` bullets → `- [ ]`.
- Leave `- [x]` as-is. Never check boxes yourself.

**Outside any tracker section:**
- Never add `- [ ]` / `- [x]`, even if bullet sounds actionable.
- Never strip existing checkbox markers — user put them there on purpose. Flag inconsistency as finding instead.

**No tracker section exists:**
- Draft `## Implementation Plan` to append at end.
- Derive phases from existing feature-area structure (one phase per major `##` section, ordered so each delivers working slice). Each phase: `### Phase N — <name>` heading + `- [ ]` items echoing spec deliverables.
- Surface under "Implementation Plan to Add" in findings **before** writing — user can redirect if phasing wrong.

**Sanity check before any checkbox edit:** ask "would marking this `[x]` make sense as completed work?" Bullet like `- Boards will have:` followed by data-field sub-bullets fails — checking meaningless. Skip.

---

## Clarification Phase

After the review pass, if there are issues you **cannot resolve yourself** (ambiguities that require the user's intent, missing info only they know, contradictions where either resolution is valid), ask all your questions in a **single numbered list**. Do not ask one question at a time. Wait for the user's answers before writing changes.

If all issues are self-evident fixes (adding missing checkboxes, rewording for clarity, reordering steps), proceed directly to the update step.

---

## Update Step

When ready:

1. Apply all fixes — resolve contradictions, fill gaps, clarify ambiguous steps, manage checkboxes in tracker, append drafted `## Implementation Plan` if missing.
2. Don't add content the user didn't ask for. No scope expansion, no invented features, no refactoring descriptive sections outside the issues found. Drafting missing tracker is the one exception — phases must echo deliverables already implied by spec, never introduce new ones.
3. Use Edit tool (not Write) for surgical changes where possible. Use Write only for a full rewrite.
4. After saving, briefly summarize what changed and why.

**Never commit the changes.** If the user asks you to commit, remind them this skill does not commit.

---

## Output Format

After the review (before asking questions or making changes), report findings grouped by category. Only show categories with actual findings. If everything is clean, say so in one sentence and proceed to the checkbox audit.

```
## Findings

### Contradictions
- [location in spec] — description

### Ambiguities
- [location in spec] — description

### Missing Instructions
- [location in spec] — description

### Logic Gaps
- [location in spec] — description

### Checkboxes to Add
- Tracker section "X" — N plain bullets need `- [ ]` format

### Implementation Plan to Add
- No tracker section found — proposing N phases derived from sections A, B, C (list phase names)
```

Then either ask clarifying questions (if needed) or proceed to update the file.

End with a one-sentence summary of spec's overall readiness.
