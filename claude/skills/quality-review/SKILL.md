---
name: quality-review
description: Run a thorough quality review of recently modified code. Use this skill when the user says things like "run a quality review", "check the code", "do a post-task check", "review what we just did", or any similar phrase indicating they want a sweep of the codebase after completing a task. Always use this skill for these requests — don't just do an ad-hoc review without it.
---

# Post-Task Quality Review

A systematic sweep of recently touched code to catch issues before they become problems. Run this after completing a task, when the user requests it.

## Scope

Unless the user specifies otherwise, focus the review on:
1. Files modified during the current task
2. Files directly imported or called by those files
3. Any test files related to the above

If the task touched many files, ask the user if they want a focused or broad review before starting.

---

## Execution Strategy

1. Read `git diff HEAD` (or use task context) to identify exactly which files and lines changed
2. If the project has a `CLAUDE.md`, read it to load stated rules and architectural invariants — these are the highest-priority things to check
3. For large scopes (5+ files), use parallel subagents to review independent files or categories simultaneously
4. Work through the checklist below; skip categories clearly irrelevant to the task

---

## Review Checklist

For each issue found, note the file, line (if applicable), severity tag (`[high]`, `[medium]`, `[low]`), and a brief explanation.

**Severity guide:**
- `[high]` — likely bug, violated invariant, or security issue; fix before merging
- `[medium]` — code quality or maintainability concern; fix soon
- `[low]` — style, minor improvement, or nice-to-have

### 1. Stale Comments & Documentation
- Comments or documentation that describe old logic no longer present or that don't match current function signatures or behavior
- TODO/FIXME/HACK comments that are now resolved (or newly introduced and shouldn't be)
- Inline examples in docs that would now fail
- If `PLAN.md`, `GOALS.md`, or `CLAUDE.md` exist in the project, check them too: look for references to completed work that should be marked done, open questions that have since been answered, decisions that contradict the current implementation, or architectural descriptions that no longer match the code

### 2. Project Invariants
- Read the project's `CLAUDE.md` for stated rules and architectural invariants
- Verify the modified code respects all of them (e.g. forbidden patterns, required abstractions, data model constraints, naming conventions)
- Flag any violation as `[high]` — these are the rules the project author set deliberately

### 3. Logical Correctness
- Off-by-one errors, wrong boundary conditions, inverted logic
- Conditions that can never be reached, or that are always true/false
- State mutations that break caller assumptions (e.g. modifying a value the caller still holds a reference to)
- Incorrect operator precedence or short-circuit logic
- This is distinct from test coverage — read the code itself and reason about whether it's correct

### 4. Code Quality Issues
- Duplicated logic that could be extracted into a shared function
- Overly complex conditionals that could be simplified
- Magic numbers or strings that should be constants
- Functions doing too many things (suggest splitting if so)
- Unused variables, imports, or parameters introduced during the task
- Leftover debug output (adapt to the project's language: debug print statements, log spam, temporary assertions, etc.)

### 5. Conflicts & Inconsistencies
- Logic that contradicts other parts of the codebase (e.g., a function that validates differently than a sibling function)
- Naming inconsistencies (e.g., `user_id` in one place, `userId` in another)
- Config or constants defined in multiple places with different values
- Imports or dependencies added that duplicate an already-present library

### 6. Test Coverage Gaps
- Missing edge cases
- Boundary conditions: off-by-one, max/min values, limits
- Error paths: does the code propagate errors? Are those tested?
- New code paths introduced by the task that have no corresponding test
- Tests that were passing before but may now be brittle due to changes

### 7. Error Handling Gaps
- Errors that are silently swallowed or ignored
- Missing input validation on public-facing functions or API handlers
- Unhandled error propagation in the project's language idiom (e.g. unchecked `Result`/`Option` in Rust, unhandled exceptions in Python, unhandled promise rejections in JS)
- Missing error context that would make debugging hard (e.g. re-throwing without wrapping)

### 8. Performance Concerns (flag only obvious ones)
- Unnecessary memory allocations in hot paths
- Wrong or inefficient algorithms
- N+1 query patterns introduced
- Expensive operations inside loops that could be hoisted
- Synchronous blocking calls in async contexts

---

## Output Format

Only list categories that have findings. If a category is clean, omit it entirely. If the entire review is clean, say so in one sentence.

For each finding:
```
[severity] file:line — description
```

End with a short **Summary** section:
- Total in-scope issues found, broken down by severity
- Which `[high]` issues (if any) must be fixed before merging
- One sentence on overall code health

### Out of Scope Issues

If during the review you notice issues in files **outside the current task's scope** (e.g., pre-existing bugs, stale code in unrelated files), do **not** mix them into the main findings. Instead, append a separate **"Out of Scope"** section at the very end of the report. List each issue with file + brief description and let the user decide whether to address them.

Be direct and specific. Don't pad the report.
