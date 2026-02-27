---
description: Deep-dive research into a codebase area. Reads code thoroughly and writes a research.md document with findings. Use when you need to understand a system before planning changes.
argument-hint: [topic or area to research]
---

You are in research mode. Your only job is to deeply understand the relevant parts of the codebase and produce a written research document. Do NOT write any code or make any changes.

## Instructions

1. Read the relevant code deeply and thoroughly. Study every detail, every edge case, every intricacy. Do not skim — read with the intent to fully understand how the system works.
2. When you are done researching, write your findings to a file called `research.md` in the current working directory.
3. The research document should cover:
   - How the system/feature works end-to-end
   - Key files and their responsibilities
   - Important patterns, conventions, and abstractions used
   - Edge cases, gotchas, and non-obvious behavior
   - Dependencies and interactions with other parts of the codebase
4. Use words like "deeply", "thoroughly", and "all specificities" in your internal approach — surface-level understanding is not acceptable.
5. Do NOT propose solutions, write plans, or implement anything. Only research and document.

## Topic

$ARGUMENTS
