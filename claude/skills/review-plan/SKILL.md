---
name: review-plan
description: Review a plan file for contradictions, ambiguities, missing instructions, and logic gaps. Asks clarifying questions, adds checkboxes to step-based sections if absent, then updates and saves the plan. Use when the user says things like "review the plan", "check the plan", "/review-plan", or names a specific plan file to review.
---

# Plan Review

A structured review of a plan file to catch issues before implementation begins. The goal is a clear, complete, unambiguous plan that a developer could follow without needing to ask questions.

## Setup

1. Identify the plan file:
   - If the user named a file, use that path.
   - Otherwise, look for `ROADMAP.md` or `SPEC.md` in the current working directory or repository root.
   - If not found, ask the user where the plan file is.

2. Read the full plan file before doing anything else.

3. Read `CLAUDE.md` (project-level, if it exists) to understand project conventions and constraints — these inform whether the plan is aligned with the project's rules.

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
- Teardown or rollback steps missing where the plan modifies shared state
- Open questions listed without a resolution path

### 4. Logic Gaps
- Steps whose order doesn't make sense (a step depends on output from a later step)
- Missing intermediate steps between two non-trivially-connected steps
- Steps that assume a state that hasn't been established yet
- A goal stated without a clear path to reach it

### 5. Checkbox Audit
- Identify every section or list that enumerates discrete steps or tasks.
- If those items use plain `-` or `*` bullets (not `- [ ]` checkboxes), convert them to `- [ ]` format.
- Do **not** convert descriptive or explanatory bullet lists — only action items and steps.
- Do **not** check off any boxes unless the plan already marks them complete.

---

## Clarification Phase

After the review pass, if there are issues you **cannot resolve yourself** (ambiguities that require the user's intent, missing info only they know, contradictions where either resolution is valid), ask all your questions in a **single numbered list**. Do not ask one question at a time. Wait for the user's answers before writing changes.

If all issues are self-evident fixes (adding missing checkboxes, rewording for clarity, reordering steps), proceed directly to the update step.

---

## Update Step

Once you have everything you need:

1. Apply all fixes to the plan file — resolve contradictions, fill gaps, clarify ambiguous steps, add checkboxes.
2. Do **not** add content the user didn't ask for. Don't expand scope, add new phases, or refactor sections that aren't part of the issues found.
3. Use the Edit tool (not Write) to make surgical changes where possible. Use Write only for a full rewrite.
4. After saving, briefly summarize what changed and why.

**Never commit the changes.** If the user asks you to commit, remind them this skill does not commit.

---

## Output Format

After the review (before asking questions or making changes), report findings grouped by category. Only show categories with actual findings. If everything is clean, say so in one sentence and proceed to the checkbox audit.

```
## Findings

### Contradictions
- [location in plan] — description

### Ambiguities
- [location in plan] — description

### Missing Instructions
- [location in plan] — description

### Logic Gaps
- [location in plan] — description

### Checkboxes to Add
- Section "X" — N items need `- [ ]` format
```

Then either ask clarifying questions (if needed) or proceed to update the file.

End with a one-sentence summary of the plan's overall readiness.
