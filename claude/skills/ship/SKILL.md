---
name: ship
description: Plan and implement a feature end to end with a team of subagents. Refines the prompt or spec, drafts a plan, has it challenged and audited, then implements, reviews and commits each step, and finishes with a fidelity audit and one full verification run. Runs autonomously; stops only for spec questions that evidence cannot settle and for deviations that need the user. Use when the user says "/ship", "ship this", "plan and build X", or hands over a prompt or spec file and wants it implemented hands-off.
---

# Ship

You are the orchestrator. You route work between subagents, track state, ask the user what agents escalate, and commit. You do not read source code, write the spec or plan, or edit code. Keep your context small: hold paths, statuses and the step ledger, not file contents.

## Invocation

- `/ship <prompt>`: the prompt is the input.
- `/ship <path/to/spec.md>`: the file is the input. It is copied, never edited.
- `/ship resume [slug]`: continue an interrupted run (see **Resume**).

## Paths

- `SKILL_DIR`: absolute path of this skill's directory (normally `$HOME/.claude/skills/ship`).
- `REPO`: `git rev-parse --show-toplevel`.
- `RUN`: `$HOME/.claude/ship-runs/<basename of REPO>/<slug>/`, absolute.

Run artifacts (all inside `RUN`):

| File | Written by | Purpose |
|---|---|---|
| `state.md` | orchestrator | phase, branch, base commit, complexity |
| `input.md` | orchestrator | verbatim copy of the prompt or spec |
| `context.md` | scout | codebase facts, commands |
| `spec.md` | spec analyst | refined spec, Locked Decisions |
| `questions.md` | any agent | questions for the user |
| `plan.md` | planner, plan auditor | the plan; step `Status:` lines are the step ledger |
| `review-challenge.md`, `review-architecture.md` | reviewers, planner adds dispositions | plan findings |
| `plan-audit.md` | plan auditor | audit verdict and edits |
| `deviations.md` | requesting agent, arbiter | deviation requests and rulings |
| `steps/<N>/report.md`, `steps/<N>/review-<r>.md` | implementer, step reviewer | per-step evidence |
| `final-audit.md` | final auditor | fidelity verdict |
| `verify.log` | orchestrator | formatter and full-suite output |

`spec.md` is frozen after Phase 1 and `plan.md` after Phase 5. From then on they change only through `deviations.md`, except that you append user answers to `## Locked Decisions` and update step `Status:` lines.

## Models

This table is the only place models are assigned. Pass `model` on every Agent call.

| Role | Prompt file | Model |
|---|---|---|
| scout | `agents/scout.md` | haiku |
| spec analyst | `agents/spec-analyst.md` | opus |
| planner | `agents/planner.md` | opus; fable when complexity is XL |
| challenger | `agents/challenger.md` | opus; fable when complexity is XL |
| architect | `agents/architect.md` | opus; fable when complexity is XL |
| plan auditor | `agents/plan-auditor.md` | opus |
| implementer | `agents/implementer.md` | step tag `mechanical` haiku, `standard` sonnet, `complex` opus; fix mode sonnet |
| step reviewer | `agents/step-reviewer.md` | sonnet; opus when the step is `complex` |
| arbiter | `agents/arbiter.md` | opus |
| final auditor | `agents/final-auditor.md` | opus |

## Spawning agents

Use the Agent tool with `subagent_type: "general-purpose"`, the model from the table, and this prompt:

```
You are the <role> in a /ship run.
Your instructions: <SKILL_DIR>/agents/<file>.md
Rules for every agent: <SKILL_DIR>/references/agent-rules.md
SKILL_DIR: <SKILL_DIR>
RUN: <RUN>
REPO: <REPO>
<role inputs: mode, step number, files to act on, base commit>
```

Every agent ends with a status block (defined in `references/agent-rules.md`):

- `done`: continue.
- `questions`: see **Asking the user**, then resume the same agent with `SendMessage`, passing the answers.
- `deviation`: see **Deviations**, then resume the same agent with the ruling.
- `blocked`: stop the run and report the blocker to the user verbatim with the agent's evidence. Do not substitute a cheaper path.

Keep each agent's ID until its phase ends so it can be resumed with its context.

## Asking the user

Read `RUN/questions.md` and ask with `AskUserQuestion`, at most 4 questions per call, as many calls as needed, recommended option first. Answers that settle a design or product choice go into `spec.md` under `## Locked Decisions` as `- <decision>: user answer, phase <p>`. Then resume the agent with the answers and empty `questions.md`.

## Deviations

A deviation is defined in `references/deviation.md`. The requesting agent appends a pending entry `D<n>` to `deviations.md` and returns `deviation`.

1. Spawn the arbiter with the entry ID.
2. Ruling `APPROVED` or `REJECTED`: resume the requesting agent with the ruling.
3. Ruling `ESCALATED`: ask the user the question the arbiter wrote under the entry, record the answer as `User: <answer>` under it, then resume the requesting agent.

Never rule on a deviation yourself.

## Phase 0: Setup

1. Stop if not inside a git repository, or if `git status --porcelain` is not empty. Report it; never stash, commit or discard the user's changes.
2. Choose a kebab-case slug of 2 to 5 words. If `RUN` exists, append `-2`, `-3`, and so on.
3. If the current branch is the default branch (`main`, `master`, or the target of the local ref `refs/remotes/origin/HEAD`), run `git switch -c ship/<slug>`. Otherwise stay on the current branch.
4. Write `input.md` and `state.md`:

```
# Ship run: <slug>
Repo: <REPO>
Input: <spec path, or "prompt">
Branch: <branch>
Base: <git rev-parse HEAD>
Complexity: pending
Phase: 1
```

## Phase 1: Spec

1. Spawn the scout. It writes `context.md`.
2. Spawn the spec analyst. It writes `spec.md`, and `questions.md` when evidence cannot settle something.
3. Copy the `Complexity:` line from `spec.md` into `state.md`.

## Phase 2: Plan

Spawn the planner in `draft` mode. It writes `plan.md`.

## Phase 3: Review

Spawn the challenger and the architect in one message so they run in parallel. They write `review-challenge.md` and `review-architecture.md`. Neither edits the plan.

## Phase 4: Revise

Resume the planner with `SendMessage` in `revise` mode, naming both review files. It applies or rejects every finding and records a disposition under each.

## Phase 5: Audit

Spawn the plan auditor. It fixes local defects in `plan.md` itself and writes `plan-audit.md` with a verdict.

- `approved`: the plan is frozen. Go to Phase 6.
- `structural`: resume the planner in `revise` mode with `plan-audit.md`, then spawn a fresh plan auditor. Allow this once. A second `structural` verdict stops the run: report the open issues to the user.

## Phase 6: Build

For each step in `plan.md` whose `Status:` is `pending`, in order:

1. Spawn the implementer for step `N` with the model the step's tag selects. It writes `steps/<N>/report.md` and does not commit.
2. Spawn the step reviewer for step `N`. It writes `steps/<N>/review-1.md` with verdict `pass` or `fix`.
3. On `fix`: resume the implementer with the review file, then resume the reviewer for round 2 (`review-2.md`). At most 2 fix rounds.
4. Still `fix` after round 2: spawn a new implementer one model tier higher (haiku to sonnet, sonnet to opus, opus to fable) with every report and review of the step, and a new reviewer. One attempt. Still `fix`: stop and report to the user.
5. On `pass`: `git add -A`, then commit with the message drafted at the end of `report.md`, adding the session's commit attribution trailer if the harness provides one. If a hook rejects the commit, treat its output as a review finding and go to step 3.
6. Set the step's line to `- Status: done (<short hash>)` in `plan.md`.

Update `Phase:` in `state.md` at each phase change.

## Phase 7: Final audit

1. Spawn the final auditor with the base commit. It writes `final-audit.md` with verdict `clean` or `fixes-needed`.
2. On `fixes-needed`: spawn the implementer in `fix` mode with `final-audit.md`, then the step reviewer on that diff (use `steps/final/` for their files). Fix rounds and commit as in Phase 6. One cycle; findings still open go to the final report.

## Phase 8: Verify

Run the formatter, then the full suite, once each, using the commands in the plan's `## Verification` section. Send output to `RUN/verify.log`; read the exit codes and, on failure, only the tail of the log.

- Formatter changed files: commit them as `style: format`.
- Suite fails: spawn the implementer in `fix` mode with `verify.log`, review and commit as in Phase 6 (files under `steps/verify/`), then run the suite once more. A second failure stops the run.

## Final report

Print to the user:

- Branch, base commit, and the list of commits (`git log --oneline <base>..HEAD`).
- Spec resolutions the analyst made without asking (the `## Resolutions` section of `spec.md`, one line each).
- Deviations: each `D<n>` with its ruling, and who decided (arbiter or user).
- Final audit verdict and any open findings.
- Verification result.
- Issues outside the plan: `Out of scope` from reviews and `Observed` from implementer reports.
- The `RUN` path.

Never push. The user decides what happens to the branch.

## Resume

1. Find runs under `$HOME/.claude/ship-runs/<basename of REPO>/`. With no slug and more than one run, ask which one.
2. Read `state.md`, check out its branch, and continue from its `Phase:`. In Phase 6, continue at the first `pending` step.
3. If the working tree is dirty, the interrupted step left changes. Ask the user whether to keep them, in which case the step reviewer reviews them as round 1, or to discard them, which the user does. Never discard them yourself.

Agent IDs do not survive a session. Resumed phases use fresh agents.
