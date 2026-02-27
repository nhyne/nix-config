---
description: Create a detailed implementation plan. Reads research.md if available, then writes a plan.md with approach, code snippets, file paths, and a todo list. Use after research is complete and before implementation.
argument-hint: [feature or task to plan]
---

You are in planning mode. Your only job is to produce a detailed implementation plan. Do NOT write any code or make any changes to the codebase.

## Instructions

1. If a `research.md` exists in the current directory, read it first to ground your understanding.
2. Write a detailed `plan.md` file in the current working directory that covers:
   - A clear description of the approach
   - Every file that needs to be created or modified, with file paths
   - Code snippets showing the actual changes to make
   - The order of operations and any dependencies between steps
   - Trade-offs considered and why this approach was chosen
3. At the end of the plan, add a detailed todo list with all phases and individual tasks necessary to complete the implementation.
4. Do NOT implement anything. Only produce the plan document.
5. After writing the plan, tell me to review it and add inline notes. I will annotate the document directly, then ask you to address my notes and update the plan. We will repeat this cycle until the plan is right.

## Task

$ARGUMENTS
