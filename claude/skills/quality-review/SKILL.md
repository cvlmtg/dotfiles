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

## Review Checklist

Work through each category below. For each issue found, note the file, line (if applicable), and a brief explanation. Skip categories that are clearly not relevant to the task.

### 1. Stale Comments & Documentation
- Comments or documentation that describe old logic no longer present or that don't match current function signatures or behavior
- TODO/FIXME/HACK comments that are now resolved (or newly introduced and shouldn't be)
- Inline examples in docs that would now fail

### 2. Code Quality Issues
- Duplicated logic that could be extracted into a shared function
- Overly complex conditionals that could be simplified
- Magic numbers or strings that should be constants
- Functions doing too many things (suggest splitting if so)
- Unused variables, imports, or parameters introduced during the task
- Leftover debug statements (`console.log`, `print`, `debugger`, `breakpoint()`, etc.)

### 3. Conflicts & Inconsistencies
- Logic that contradicts other parts of the codebase (e.g., a function that validates differently than a sibling function)
- Naming inconsistencies (e.g., `user_id` in one place, `userId` in another)
- Config or constants defined in multiple places with different values
- Imports or dependencies added that duplicate an already-present library

### 4. Test Coverage Gaps
- Missing edge cases
- Boundary conditions: off-by-one, max/min values, limits
- Error paths: does the code throw? Are those exceptions tested?
- New code paths introduced by the task that have no corresponding test
- Tests that were passing before but may now be brittle due to changes

### 5. Error Handling Gaps
- Missing try/catch or error boundaries around risky operations (I/O, network, parsing)
- Errors that are caught but silently swallowed
- Missing input validation on public-facing functions or API handlers
- Promises/async functions without rejection handling

### 6. Performance Concerns (flag only obvious ones)
- Unnecessary memory allocations
- Wrong or inefficient algorithms
- N+1 query patterns introduced
- Expensive operations inside loops that could be hoisted
- Missing indexes implied by new query patterns (note, don't fix)
- Synchronous blocking calls in async contexts

---

## Output Format

Present findings grouped by category. For each category:
- If **no issues found**: one line saying so
- If **issues found**: list them with file + brief description

End with a short **Summary** section:
- Total issues found
- Which (if any) are high priority to fix now vs. can wait
- One sentence on overall code health

Be direct and specific. Don't pad the report. If something looks good, say so briefly and move on.
