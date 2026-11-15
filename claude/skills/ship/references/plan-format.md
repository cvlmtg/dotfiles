# Plan format

```
# Plan: <title>

Spec: RUN/spec.md
Fix altitude: end-to-end | local
<if local: the end-to-end alternative declined, which type, boundary or funnel it would change, and why local anyway>

## Context
<why this change, what problem it solves>

## Approach
<the strategy, 2 to 4 sentences>

## Design

### Design 1: <title>
<types, ownership, funnels, invariants, data flow, error handling: only what the steps need, with path:line anchors into existing code. For each question several sites ask, name the one function that answers it and its inputs. State an algorithm by its contract, invariant and termination, not its body. No loop bodies or scratch variables: those are the implementer's.>

### Design 2: ...

## Steps

### Step 1: <title>
- Status: pending
- Tag: mechanical | standard | complex
- Covers: R1, R3, AC2
- Design: 1, 2 | none
- Deviations: none
- Goal: <one sentence>
- Files:
  - `<path>`: <what changes>
- Tests: <each test: name, what it asserts, how the expected value is derived independently of the implementation>
  <or: "behavior-preserving refactor, covered by <existing tests>; no red run">
- Done when: <observable condition>
- Commit: `<type(scope): subject>`

### Step 2: ...

## Verification
- Formatter: `<command>` (source: path:line)
- Full suite: `<command>` (source: path:line)
- Measurements: `<command>` → AC<n>, budget <number> | none (`## Hot paths` in spec.md is `None`)
- Manual checks: <if any>

## Out of scope
<explicit exclusions, each tied to the spec>
```

## Rules

- Every requirement `R<n>` and acceptance criterion `AC<n>` in `spec.md` appears in at least one step's `Covers:`.
- Each step leaves the tree building and its tests passing, and is one coherent commit.
- A step is one coherent change: prefer fewer, larger steps. Merge adjacent steps that change the same module or feature slice when the result is still one commit that builds and passes. Split a step only when it is expected to change more than about 1000 lines, into steps that each build and pass.
- Every entry under `## Hot paths` in `spec.md` has a step that measures it against its budget AC on the slowest configuration the spec names, with a bench or a call count through a counting test double. Its command appears under `## Verification` as a `Measurements:` line.
- `## Design` is split into numbered subsections. Each step's `Design:` lists every subsection its implementer needs, because the implementer and the step reviewer read only those subsections and the step itself (`SKILL_DIR/scripts/step-brief.sh`). A step must not depend on plan text outside them.
- `Deviations:` stays `none` when planning. A ruling that edits a step adds the entry ID there (`SKILL_DIR/references/deviation.md`).
- Every type, function or module the plan introduces has a caller within the plan.
- Defer only what is strictly additive: a new command, flag or isolated module that can be added later without changing existing data structures, signatures or boundaries. Anything else is implemented now.
- No compatibility shims, deprecated aliases or re-exports unless the spec requires them.
- Steps that write documentation name its audience (end users, learners, source readers) as CLAUDE.md defines them.

## Dispositions

The planner answers every review finding with `applied` or `rejected`. A valid rejection shows the finding is factually wrong, conflicts with a Locked Decision or the spec, or would make the plan worse under CLAUDE.md's rules. Effort, churn, file count, "can be done later", and "out of scope" for a finding about correctness or a CLAUDE.md rule are not valid reasons.

## Tags

The tag picks the implementer's model, so tag by how much judgment the step needs and how much risk it carries, not by size.

- `mechanical`: no decisions left. Every edit is specified: renames, wiring, config, documentation from given content.
- `standard`: implements the specified design using patterns that already exist in the codebase. Only local decisions.
- `complex`: new algorithms, concurrency, subtle invariants, cross-module refactors, or decisions the plan cannot fully pin down.

A step that changes authentication, authorization, secret handling, persisted data, or an interface outside callers rely on is at least `standard`, even when every edit is specified.
