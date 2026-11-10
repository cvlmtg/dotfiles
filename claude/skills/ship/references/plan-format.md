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
<types, ownership, funnels, invariants, data flow, error handling: only what the steps need, with path:line anchors into existing code. For each question several sites ask, name the one function that answers it and its inputs. State an algorithm by its contract, invariant and termination, not its body. No loop bodies or scratch variables: those are the implementer's.>

## Steps

### Step 1: <title>
- Status: pending
- Tag: mechanical | standard | complex
- Covers: R1, R3, AC2
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
- A step is one reviewable unit: split a step expected to change more than about 400 lines into steps that each build and pass.
- Every entry under `## Hot paths` in `spec.md` has a step that measures it against its budget AC on the slowest configuration the spec names, with a bench or a call count through a counting test double. Its command appears under `## Verification` as a `Measurements:` line.
- Every type, function or module the plan introduces has a caller within the plan.
- Defer only what is strictly additive: a new command, flag or isolated module that can be added later without changing existing data structures, signatures or boundaries. Anything else is implemented now.
- No compatibility shims, deprecated aliases or re-exports unless the spec requires them.
- Steps that write documentation name its audience (end users, learners, source readers) as CLAUDE.md defines them.

## Tags

The tag picks the implementer's model, so tag by how much judgment the step needs, not by size.

- `mechanical`: no decisions left. Every edit is specified: renames, wiring, config, documentation from given content.
- `standard`: implements the specified design using patterns that already exist in the codebase. Only local decisions.
- `complex`: new algorithms, concurrency, subtle invariants, cross-module refactors, or decisions the plan cannot fully pin down.
