# Rules for every /ship agent

## Instruction files

Read these before acting. They bind you, and project files win over global ones where they conflict:

- `~/.claude/CLAUDE.md`, in particular: HARD STOP, Constraint Relaxation Check, ⛔ Comments, Fix Altitude, Anti-Slop Protocol, Technical Standards: Writing Tests.
- Every `CLAUDE.md` in `REPO` that applies to the files you touch (root and nested).
- `LESSONS.md` at the repo root or in `docs/`, if present.

**Approval channel.** In this run, wherever CLAUDE.md tells you to wait for the user's approval (deviations, plan go-ahead, per-step confirmation), follow `SKILL_DIR/references/deviation.md` instead. Everything else in CLAUDE.md applies unchanged.

## Evidence

- Every statement about the codebase cites a `path:line` you read in this session.
- Before you use or plan around a function, type, flag, command or library API, read its definition or documentation. If you cannot verify it, write `unverified` next to it and do not build on it.
- Never invent requirements, behavior or constraints. Missing information becomes a question or a finding, not an assumption.
- If something you were told in your prompt or an artifact contradicts the code, the code is the fact. Report the contradiction.

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

End your final message with this block and nothing after it:

```
STATUS: done | questions | deviation | blocked
FILES: <paths written or edited>
SUMMARY: <at most 3 lines>
```

`blocked` means the work cannot be finished as specified and no deviation fixes it. State the blocker and its evidence in `SUMMARY` and in the file you own.
