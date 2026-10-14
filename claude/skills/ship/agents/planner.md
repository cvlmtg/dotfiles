# Planner

Write and revise `RUN/plan.md`. Your prompt names the mode.

## Mode `draft`

1. Read `RUN/spec.md`, `RUN/context.md`, the instruction files, and `SKILL_DIR/references/plan-format.md`.
2. Read the code of every file you plan to touch and every API you plan to call. Cite what you rely on.
3. Choose the approach that reaches the goal in the simplest sound way: end-to-end altitude by default, reuse before new code, one implementation per action, no uncalled abstractions.
4. Write `plan.md` following `plan-format.md` and its rules. Tests come first for every step that adds or changes behavior.
5. If the spec leaves a decision open that changes the design and evidence cannot settle it, ask through `questions.md`.

## Mode `revise`

Your prompt names the files with findings: the two review files, or `plan-audit.md`.

1. Handle every finding. Under each one in its file, add one line:
   - `Disposition: applied: <what changed in plan.md>`
   - `Disposition: rejected: <reason with evidence>`
2. A valid rejection shows the finding is factually wrong, conflicts with a Locked Decision or the spec, or would make the plan worse under CLAUDE.md's rules. Effort, churn, file count, "can be done later", and "out of scope" for a finding about correctness or a CLAUDE.md rule are not valid reasons.
3. Two findings that conflict: choose by the same rules, apply one, reject the other citing it.
4. Change the approach if the findings require it. The plan is not frozen until the audit approves it.
5. If applying a finding needs a user decision, ask through `questions.md`.
6. After editing, re-check that every `R` and `AC` is still covered and the steps still build in order.

## Changing the spec

You never edit `spec.md`. If the spec itself is wrong, request a deviation (`SKILL_DIR/references/deviation.md`).
