---
name: quality-review
description: Run a thorough quality review of recently modified code, including a codebase-wide hunt for duplicated logic and opportunities to simplify. Use this skill when the user says things like "run a quality review", "check the code", "do a post-task check", "review what we just did", or any similar phrase indicating they want a sweep of the codebase after completing a task. Always use this skill for these requests — don't just do an ad-hoc review without it.
---

# Post-Task Quality Review

A systematic sweep of recently touched code to catch issues before they become problems. Run this after completing a task, when the user requests it.

## Scope

The review target is a **set of code**, not a set of commits. The user names it: "everything after commit X", "the current diff", "what we just did". Resolve that to a diff and review every line in it.

Unless the user specifies otherwise, focus the review on:
1. Files modified during the current task
2. Files directly imported or called by those files
3. Any test files related to the above

**Commit history inside the range is not scope information.** Whatever produced the code — one commit or twenty, a prior "quality review" commit among them — the code in the range is reviewed in full, at full depth:
- Code an earlier review already covered is reviewed again. A previous pass is not evidence of quality: its findings may have been reported but never fixed, fixed wrongly, or invalidated by later edits.
- The fixes an earlier review produced are themselves code in the range, and get the same scrutiny as everything else.
- Never narrow the range, skip files, or shorten the checklist because of what a commit message claims was done.
- A finding is never downgraded, omitted, or marked "already known" because a previous review surfaced it. Report it as if seen for the first time.

If the user gave no explicit range and the task touched many files, ask whether they want a focused or broad review before starting. If they did give a range, review it as given — don't ask to shrink it.

The duplication hunt (§4) and the dead-code hunt (§5) are deliberately **not** bounded by this scope — a duplicate's twin, or code orphaned elsewhere in the tree by this diff, can live anywhere in the tree, and a finding is never downgraded for sitting outside the reviewed files.

---

## Execution Strategy

1. Resolve the review range to a single diff and read it: `git diff <base> HEAD` for "everything after commit X", `git diff HEAD` for uncommitted work, or use task context. Read it as one unified change — do not walk commit-by-commit, and do not read commit messages to decide what deserves review
2. Read stated rules and architectural invariants — these are the highest-priority things to check. Read the project's `CLAUDE.md` if one exists, and also the global `~/.claude/CLAUDE.md` if one exists — global principles (SSOT, One Action One Implementation, Zero Uncalled Abstractions, Fail Fast, etc.) apply even when the project has no CLAUDE.md of its own
3. Enumerate the **actions** the diff introduces or touches — each distinct outcome the code produces (validate X, format Y, resolve a path, dispatch a command). For each, search the whole codebase for another implementation of that same outcome: by name, by call site, by the data it reads/writes — not by text similarity alone. Renamed, reordered, and differently-styled duplicates are the ones grep misses and the ones that matter most
4. When the diff removes, replaces, or stops calling something, check whether anything upstream lost its last caller — search the whole codebase the same way step 3 does for duplication, before assuming it's a normal edit
5. For large scopes (5+ files), use parallel subagents to review independent files or categories simultaneously
6. Work through the checklist below; skip categories clearly irrelevant to the task

---

## Review Checklist

For each issue found, note the file, line (if applicable), severity tag (`[critical]`, `[high]`, `[medium]`, `[low]`), and a brief explanation.

**Severity guide:**
- `[critical]` — security vulnerability, data loss risk, or production-breaking bug; merge-blocking, fix immediately
- `[high]` — likely bug or violated invariant; fix before merging
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
- Flag any violation as `[high]` (or `[critical]` if the invariant guards security or data integrity) — these are the rules the project author set deliberately

### 3. Logical Correctness
- Off-by-one errors, wrong boundary conditions, inverted logic
- Conditions that can never be reached, or that are always true/false
- State mutations that break caller assumptions (e.g. modifying a value the caller still holds a reference to)
- Incorrect operator precedence or short-circuit logic
- This is distinct from test coverage — read the code itself and reason about whether it's correct

### 4. Duplication — One Action, One Implementation
**One Action, One Implementation**: every input path that triggers the same action (command name, scripting-engine function, keybinding, CLI flag, HTTP route, event handler) must delegate to the same function — entry points only translate their own input. Two implementations of the same outcome is an architectural bug, not acceptable duplication, whether or not they're written the same way.

- Multiple entry points each carrying their own copy of the logic instead of delegating to one shared function
- Copy-paste twins, parallel-but-divergent reimplementations, or new logic that ignores an existing utility doing the same job
- Divergent duplicates: two implementations of the same action that disagree on an edge case — flag the disagreement itself, one of them is a latent bug
- Config, constants, or defaults defined in more than one place (SSOT) — including ones deferred with "single call site for now" or "can consolidate later" reasoning; fix now, the cost only grows
- A dependency added that duplicates a library already present
- Naming inconsistencies for the same concept (e.g. `user_id` vs `userId`) — often a symptom of this same duplication

Severity: `[high]` — architectural bug, not style. `[critical]` when the two paths disagree on something security- or data-integrity-relevant.

**Guardrail against over-firing**: incidental similarity is not duplication. Two functions with the same shape but different outcomes stay separate — the test is whether a future change to the behavior would have to be made in both places.

### 5. Dead Code
Code that no longer runs, or never runs, in production — whether the diff left it behind, introduced it, or orphaned something elsewhere in the tree. The standard here isn't "could be better," it's "does anything reach this."

- Unreachable branches: conditions or fallbacks that cannot occur — prove it, don't guess (see guardrail below)
- Unused locals: variables, imports, or parameters introduced during the task and never referenced
- Orphaned by the diff: a function or branch the task added but never wired up; old code left in place after being replaced instead of deleted
- Orphaned elsewhere in the tree: if the diff removes the last caller of something, that something is now dead — search for it the same way §4 searches for duplication twins; not bounded by the reviewed-files scope
- Test-only production code: no caller outside the test suite — unless it's a dedicated test helper/fixture written to support tests, not production logic that lost its last real caller

Severity: `[medium]` normally (safe to delete, no behavior change). `[low]` for a stray unused import or variable. `[high]` when the dead code reveals the task's new logic never actually got wired in.

**Guardrail against false positives**: a missing in-repo caller doesn't always mean dead. Exported public API, CLI entry points, framework-invoked hooks (routes, serializers, migrations, event handlers), and reflection/string-based dispatch can all have callers a grep won't find. When unreachability isn't provable, report it as a question, not a finding.

### 6. Simplification
Goal is less logic to reason about, not fewer lines — a dense one-liner replacing a clear five-line block is not a finding.

- Conditionals that can collapse: redundant branches, negations that cancel, conditions subsumed by an earlier guard, `if`/`else` chains that are really a lookup table
- Control flow that can flatten: nesting removable via early return or guard clauses; loops doing work a single pass or a stdlib call already does
- Algorithms doing more work than the problem needs: repeated scans, sorting to find a min, rebuilding a structure per iteration, manual bookkeeping the language already provides
- Redundant state: variables derivable from another, flags tracking something already implied by control flow, caches with one reader
- Indirection with no second caller: pass-through wrappers, single-implementation interfaces, parameters only ever passed one value

**Hard guardrail — do not trade correctness for brevity:**
- Behavior must be identical for every input, including edge cases and error paths
- Never propose dropping a branch because it *looks* unreachable — prove it, or report it as a question instead of a simplification
- Never propose removing input validation, bounds checks, or error handling as "redundant" unless a guaranteeing invariant is named
- If a simplification would change behavior in any case, however unlikely, it is a bug report — not a simplification finding

Severity: `[medium]` normally; `[low]` for cosmetic wins; `[high]` when the complexity is actively hiding a correctness question.

### 7. Code Quality Issues
- Magic numbers or strings that should be constants
- Functions doing too many things (suggest splitting if so)
- Leftover debug output (adapt to the project's language: debug print statements, log spam, temporary assertions, etc.)
- Separation of concerns violations: logic that belongs to a different layer or abstraction (e.g. business logic in a view, data access in a controller, presentation logic in a model) — flag where responsibility should live and why

### 8. Test Coverage Gaps
- Missing edge cases
- Boundary conditions: off-by-one, max/min values, limits
- Error paths: does the code propagate errors? Are those tested?
- New code paths introduced by the task that have no corresponding test
- Tests that were passing before but may now be brittle due to changes

### 9. Error Handling Gaps
- Errors that are silently swallowed or ignored
- Missing input validation on public-facing functions or API handlers
- Unhandled error propagation in the project's language idiom (e.g. unchecked `Result`/`Option` in Rust, unhandled exceptions in Python, unhandled promise rejections in JS)
- Missing error context that would make debugging hard (e.g. re-throwing without wrapping)

### 10. Performance Concerns (flag only obvious ones)
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
index. [severity] file:line — description
```

Duplication (§4) findings must name both locations, which implementation survives, and which callers redirect to it. Dead Code (§5) findings must name the dead location and show why nothing reaches it — the caller the diff removed, or confirmation no caller ever existed. Simplification (§6) findings must show what the simplified logic looks like. None gets a bare problem description — the skill does not apply fixes itself, so the report must be actionable as-is.

End with a short **Summary** section:
- Total in-scope issues found, broken down by severity
- Which `[critical]` or `[high]` issues (if any) must be fixed before merging
- One line confirming the duplication twin-hunt ran and what it covered (e.g. "twin-hunt: checked N actions against the full tree, 0 duplicates found")
- One line confirming the dead-code hunt ran and what it covered (e.g. "dead-code hunt: checked N orphaned symbols against the full tree, 0 found")
- One sentence on overall code health

### Out of Scope Issues

If during the review you notice issues in files **outside the current task's scope** (e.g., pre-existing bugs, stale code in unrelated files), do **not** mix them into the main findings. Instead, append a separate **"Out of Scope"** section at the very end of the report. List each issue with file + brief description and let the user decide whether to address them.

**Exception**: duplication findings from §4, and dead-code findings from §5 caused by this diff, always belong in the main findings, never in Out of Scope — even when the twin implementation, or the now-orphaned code, lives outside the reviewed files. The diff created or perpetuated the issue, so it's in scope by definition. Pre-existing dead code unrelated to the diff still goes to Out of Scope.

Be direct and specific. Don't pad the report.
