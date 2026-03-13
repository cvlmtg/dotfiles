# Global Claude Instructions

## The "Cautionary Tale" Rules
- No Blind Trust: If you decide to change a technical approach after we agreed on a plan, you MUST flag it and wait for my approval.
- Explicit Rationales: Do not just say a pattern is "better". Explain the performance vs. complexity trade-offs for this specific codebase.
- Verification Gates: When I express doubt, treat it as a hard block. Provide a deep-dive comparison of choices until I am satisfied.
- Security Gates: Never suggest hardcoded credentials, API keys, or secrets. If a change impacts security (auth logic, data exposure), explicitly call it out in the Rationale section.

## Workflow Orchestration

### 1. Plan Node Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately - don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity
### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One tack per subagent for focused execution
### 3. Self-Improvement Loop
- After ANY correction from the user: update 'tasks/lessons. md' with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness
### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes
- Don't over-engineer. If a major refactor is needed, flag it as a separate 'Plan Node' rather than bundling it
- Challenge your own work before presenting it
### 6. Autonomous Bug Fixing
- When fixing a bug, don't just patch the symptom. Add defensive checks or improved error logging to ensure that if it fails again, the cause is immediately obvious
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests - then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Writing tests
- Verify tests actually catch bugs. After writing a new test, break the code under test (e.g. replace the function with a no-op, flip a condition, remove a return value) and confirm the test fails. If it still passes, the test is not testing anything.
- Keep the verification oracle independent of the code under test. If the assertion helper calls the same APIs or uses the same formula as the implementation, it will confirm the output without checking correctness — a circular test that always passes. Derive expected values from the inputs using independent logic.
- Treat verification helpers that query the system under test as a red flag. Any time the assertion touches the same API surface or data structures that the code just modified, explicitly ask: would this assertion pass even if the code did nothing?

## Core Principles
- Find the root causes. No temporary fixes. Senior developer standards.
- KISS (Keep It Simple, Stupid): Choose the simplest solution that works. Avoid unnecessary complexity, abstractions, or indirection.
- DRY (Don't Repeat Yourself): Every piece of knowledge should have a single, authoritative representation. Extract shared logic rather than duplicating it.
- Single Source of Truth: Data and configuration should live in exactly one place. Derive everything else from that source. If something needs to change, there should be only one place to change it.
- Fail Fast: Design systems to error out loudly and clearly rather than failing silently with "null" or "undefined"
- Changes should only touch what's necessary. Avoid introducing bugs.

## Task Management
1. **Plan First**: Write plan to "tasks/todo.md" with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to 'tasks/todo.md"
6. **Capture Lessons**: Update 'tasks/lessons.md' after corrections
