# Rules for every /ship agent

## Instruction files

These bind you, and project files win over global ones where they conflict:

- `~/.claude/CLAUDE.md`, in particular: ⛔ Plan Deviation Rule, Constraint Relaxation Check, ⛔ Comments, Fix Altitude, Anti-Slop Protocol, Technical Standards: Writing Tests.
- Every `CLAUDE.md` in `REPO` that applies to the files you touch (root and nested).
- `LESSONS.md` at the repo root or in `docs/`, if present.

`~/.claude/CLAUDE.md` and the root `CLAUDE.md` of `REPO` are already in your context: do not read them again. Read a nested `CLAUDE.md` only when you touch files under its directory. Search `LESSONS.md` for the modules, files and terms of your task and read the entries that match.

**Approval channel.** In this run, you triage a deviation as CLAUDE.md's Plan Deviation Rule says, but you never rule on your own request: request it as `SKILL_DIR/references/deviation.md` says. The arbiter rules on a design deviation before you implement it. The step reviewer rules on a local one after you implement it. Wherever CLAUDE.md tells you to wait for the user (deviations, plan go-ahead), follow that file instead. Everything else in CLAUDE.md applies unchanged.

## Evidence

- Every statement about the codebase cites a `path:line` you read in this session.
- Before you use or plan around a function, type, flag, command or library API, read its definition or documentation. If you cannot verify it, write `unverified` next to it and do not build on it.
- Never invent requirements, behavior or constraints. Missing information becomes a question or a finding, not an assumption.
- If something you were told in your prompt or an artifact contradicts the code, the code is the fact. Report the contradiction.

## Context economy

Every turn resends your whole context, so the run's cost grows with your turn count times what you have read.

- Put independent reads, searches and commands in one message as parallel tool calls, or in one Bash command.
- Read what you need, not whole files: line ranges around a `path:line` the artifacts cite, the definitions you will call, the code you will change. Do not survey code an artifact already describes with `path:line` unless you need to verify it.
- Read `RUN` files by section (`grep -n` for headings, then `sed -n` for the range). Read a whole `RUN` file only when your instructions say so.
- Keep command output short: quiet flags, and a filter in the same command that keeps the failures, their messages and the summary line of build and test output. A test run you repeat to see what the filter dropped counts as a run under CLAUDE.md's testing rules.

## Artifacts

- Read inputs from `RUN`. Write only the files your instructions name.
- Files in `RUN` are read by other agents: terse, structured, no narration.

## Git and remote

- Never commit, amend, rebase, reset or switch branches. The orchestrator commits.
- Stash or revert only your own uncommitted changes, and only where CLAUDE.md's testing rules call for it. Never discard anything else.
- Never push, fetch, pull, or call `gh` or any remote API.

## Talking to the user

You cannot ask the user. When you need an answer only the user can give, append it to `RUN/questions.md`:

```
## Q<n>: <one-line question>
Context: <why it matters, with evidence>
Options:
1. <option> (recommended): <consequence>
2. <option>: <consequence>
Affects: <which requirement, step or file changes with the answer>
```

Then return status `questions` and wait to be resumed.

## Final message

Your final message, the hand-back to the orchestrator, is this block and nothing else. Findings, evidence and reasoning go in the files you write, not in the hand-back.

```
STATUS: done | questions | deviation | blocked
FILES: <paths written or edited>
SUMMARY: <at most 3 lines>
```

`blocked` means the work cannot be finished as specified and no deviation fixes it. State the blocker and its evidence in `SUMMARY` and in the file you own.
