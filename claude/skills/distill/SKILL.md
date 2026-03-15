---
name: distill
description: Distill current conversation context into CONTEXT.md and enter plan mode with a clean slate
disable-model-invocation: true
allowed-tools: Read, Write, Edit, EnterPlanMode
---

Distill the current conversation into a context checkpoint, then enter plan mode.

## Step 1: Write .claude/CONTEXT.md

Analyze the full conversation and write `.claude/CONTEXT.md` in the project root with these sections:

### Decisions Made
- Approaches chosen and why
- Trade-offs that were evaluated and resolved

### Open Questions
- Unresolved ambiguities
- Things the user hasn't confirmed yet
- Risks or unknowns that need investigation

### Constraints
- Technical limitations discovered
- Requirements and non-negotiables
- Dependencies or blockers

### Current State
- What has been implemented so far
- What is in progress
- What remains to be done

Be concise. Use bullet points. Include file paths where relevant.
If a previous CONTEXT.md exists, replace it entirely — it represents a prior checkpoint.

## Step 2: Enter plan mode

After writing CONTEXT.md, enter plan mode. The plan should build on the
distilled context — do NOT rehash the full conversation history. Reference
`.claude/CONTEXT.md` as the source of truth for prior decisions and state.

## Step 3: Remind user to clear

Tell the user:
> CONTEXT.md written. You're now in plan mode.
> Run `/clear` for a clean slate — CONTEXT.md has everything you need.

From this point forward, treat `.claude/CONTEXT.md` as the canonical record of
everything before this moment. Do not repeat or summarize old conversation
context — if you need prior context, read the file.
