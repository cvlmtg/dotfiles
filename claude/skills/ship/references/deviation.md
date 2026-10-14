# Deviation protocol

## What counts

A deviation is any change that differs from a frozen artifact:

- a different approach, design, type, data shape, API or file than `plan.md` states;
- adding or dropping scope, or deferring part of a step;
- a different test strategy than the step states;
- any edit to `spec.md` beyond Locked Decisions.

Choices the plan leaves open are not deviations, as long as they stay inside the step's stated files and behavior and follow CLAUDE.md. Local names and the internal layout of a function are examples.

Before Phase 5 ends, the plan is not frozen. Changes to it during Phases 2 to 5 are revisions, not deviations. A change to `spec.md` in those phases is still a deviation.

## Requesting one

Stop the work that depends on it. Append to `RUN/deviations.md`:

```
## D<n>: <title>
Status: pending
Raised by: <role>, phase <p>, step <N or ->
Plan says: <quote from plan.md or spec.md>
Proposed: <the change>
Reason: <the bug, false assumption or plan error, with path:line evidence>
Altitude: local | end-to-end
Alternatives:
- A: <description>. Against the rules: <SSOT, One Action One Implementation, Fix Altitude, Constraint Relaxation, Anti-Slop>
- B: ...
Chosen: <letter>, because <reason>
Purpose: <does it reduce changes, touch fewer files, save time or reach green sooner? yes or no, one line>
```

Then return status `deviation`. Consider real alternatives before choosing; the quickest idea is not the default.

## Arbiter procedure

Apply these in order and stop at the first ruling.

1. **Shortcut.** If the purpose is to reduce changes, touch fewer files, save time or reach green sooner, the ruling is `REJECTED (shortcut)`. The agent continues with the plan as written. If the plan cannot be finished as written, the agent returns `blocked`.
2. **Evidence.** Read the cited code. If the reason does not hold, the ruling is `REJECTED (unverified)`.
3. **Alternatives.** Add any reasonable alternative the request missed. Rank them by: compliance with SSOT, One Action One Implementation, Fix Altitude (end-to-end by default), Constraint Relaxation and Anti-Slop; then code quality; then speed, at runtime and to implement. If the plan's own approach ranks first, the ruling is `REJECTED (plan is better)`.
4. **Escalation.** The ruling is `ESCALATED` if the top alternative:
   - changes a Locked Decision, or the scope or behavior `spec.md` states;
   - changes an interface outside callers rely on (public API, CLI, config format, persisted data, wire protocol);
   - affects authentication, authorization, secrets or data exposure;
   - trips a Constraint Relaxation trigger where any future caller can misuse it and the failure is silent or a runtime crash;
   - ties with another alternative on the rules while the two differ in what the user sees.
5. Otherwise the ruling is `APPROVED (<letter>)`.

Write the ruling under the entry and set `Status:` to the ruling:

```
Ruling: <ruling>
Arbiter: <at most 5 lines of reasoning>
```

For `ESCALATED`, also write the question for the user:

```
Question: <one line>
Options:
1. <alternative> (recommended): <consequence>
2. <alternative>: <consequence>
```

## After the ruling

- `APPROVED`: implement the chosen alternative. The approved entry is part of the effective plan from now on.
- `REJECTED`: continue with the plan as written.
- `ESCALATED`: wait. The orchestrator records `User: <answer>` under the entry and resumes you.
