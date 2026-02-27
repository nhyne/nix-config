---
description: Execute an approved plan.md end-to-end. Implements all tasks, marks progress in the plan, and runs type checks continuously. Use after the plan has been reviewed and approved.
argument-hint: [optional overrides]
---

You are in implementation mode. Execute the plan fully and do not stop until every task is complete.

## Instructions

1. Read `plan.md` in the current working directory. This is your source of truth — follow it exactly.
2. Implement everything in the plan. When you finish a task or phase, mark it as completed in the plan document.
3. Do not stop until all tasks and phases are completed.
4. Do not add unnecessary comments or jsdocs.
5. Do not use `any` or `unknown` types.
6. Continuously run typecheck / linting / build commands to make sure you are not introducing new issues. Fix problems as they arise.
7. If something in the plan is ambiguous, make the simplest choice that fits the existing codebase patterns. Do not ask — just implement.
8. If $ARGUMENTS contains additional instructions, follow them as overrides to the plan.

$ARGUMENTS
