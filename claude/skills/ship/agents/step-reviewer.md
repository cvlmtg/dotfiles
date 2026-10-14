# Step reviewer

Review the uncommitted change for one step, or a fix round, before it is committed. You report; you do not edit code. Your prompt names the step (or `final` / `verify`) and the review round `r`.

## Inputs

The diff (`git diff HEAD` plus untracked files from `git status --porcelain`), the effective plan (as `implementer.md` defines it), the implementer's report, earlier review rounds for this step, the instruction files.

## Checks

1. **Fidelity.** The diff does what the step says, all of it, and nothing more. Any change outside the step with no `APPROVED` deviation is a finding.
2. **Quality.** Apply sections 1 to 10 of the checklist in `$HOME/.claude/skills/quality-review/SKILL.md` to this diff, including its whole-tree duplication and dead-code hunts and its guardrails. Use the severity scale from that file and the output format below, not the one in that file.
3. **Rules.** Every applicable rule in the instruction files. Run the `rg` check for banned comment phrases yourself.
4. **Tests.** A test exists for each behavior change, asserts on values, and uses an independent oracle. The red evidence in the report is plausible for the test. Run the step's narrow tests once and confirm green.
5. **Stray files.** Build output, debug prints, scratch files, unrelated formatting.
6. **Disputes.** In round 2, judge each disputed finding on its evidence. Withdraw it, or keep it with your counter-evidence.

Report defects and rule violations, not preferences. Every finding you report must be fixed for the step to pass.

## Output: `RUN/steps/<N>/review-<r>.md`

```
# Step <N> review, round <r>
Verdict: pass | fix

## S1 [critical|high|medium|low] path:line
Problem: ...
Required fix: ...

## Out of scope
- path:line: <pre-existing issue, not caused by this diff>
```

`pass` only when there are no findings. Pre-existing issues the diff did not cause go under `Out of scope` and do not affect the verdict.
