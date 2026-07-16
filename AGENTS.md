# AGENTS.md

Read this file before every task. Working code only. Finish the job. Plausibility is not correctness.

This repo is a terminal-first LeetCode practice workspace. The normal workflow is tmux plus
LeetCode CLI plus Neovim plus an OpenCode tutor window.

## Repo-Specific Rules

1. For any request that sounds like "explain", "teach", "hint", "walk me through", "debug my approach", "why does this fail", or "help with this problem", use `.skills/leetcode-dsa-teach/SKILL.md`.
2. Before answering those requests, read the latest files under `leetcode/.current/`. At minimum read `leetcode/.current/problem.md` when it exists. If code context is needed, read the path stored in `leetcode/.current/path`.
3. Treat `leetcode/.current/problem.md` and `leetcode/.current/problem.json` as the current open problem context. They can change while the OpenCode session stays open, so reread them for each new teaching/help request.
4. Do not assume the file in `leetcode/.current/path` belongs to the current problem unless it matches the current problem id or slug. If it looks stale, say so.
5. Do not give a full solution immediately unless the user explicitly asks for one. Prefer hints, invariants, examples, dry runs, edge cases, and complexity reasoning first.
6. Do not submit solutions or run LeetCode commands unless the user explicitly asks.
7. Generated solution files under `leetcode/` are personal practice artifacts and are intentionally git-ignored. Do not commit them.
8. Keep output terminal-native. No HTML lessons, browser-only instructions, or visual artifacts for the DSA tutor flow.

## Current-Problem Files

The LeetCode CLI writes current context here:

```text
leetcode/.current/problem.md      human-readable current problem
leetcode/.current/problem.json    structured current problem
leetcode/.current/problem-cache-md    deterministic per-problem Markdown path
leetcode/.current/problem-cache-json  deterministic per-problem JSON path
leetcode/.current/problems/<difficulty>/<topic>/<id.slug>.md
leetcode/.current/problems/<difficulty>/<topic>/<id.slug>.json
leetcode/.current/problem-id      current viewed problem id
leetcode/.current/problem-slug    current viewed problem slug
leetcode/.current/topic-name      first topic tag name
leetcode/.current/topic-slug      first topic tag slug
leetcode/.current/id              active picked solution id
leetcode/.current/path            active picked solution path
```

Viewing a problem updates the `problem-*` and `topic-*` files. Picking a solution file updates
`id` and `path`.

`problem.md` and `problem.json` are live pointers and are overwritten for the latest viewed problem.
The files under `leetcode/.current/problems/` are deterministic per-problem cache files. Reopening the
same problem updates the same cache file; it does not create duplicates.

## Global Working Rules

1. No flattery, no filler. Start with the answer or the action.
2. Disagree when you disagree. Say so before doing the work.
3. Never fabricate. Read the file, run the command, or say "I don't know, let me check."
4. Stop when confused. If two interpretations are plausible and the choice matters, ask.
5. Touch only what you must. Every changed line must trace directly to the user's request.
6. Move fast, but never faster than the human can verify.
7. Git commits are one-liners: short, conventional, lowercase, and minimal.

## Before Writing Code

1. State the plan before editing.
2. Read the files you will touch and the files that call them.
3. Match existing patterns.
4. Surface assumptions out loud.
5. If two approaches exist and the tradeoff matters, present both.
6. If a simpler approach exists than what was requested, say so.

## Code Style

1. No features beyond what was asked.
2. No abstractions for single-use code.
3. No error handling for impossible scenarios.
4. Prefer boring, obvious solutions.
5. Bias toward deletion over addition.
6. Do not refactor unrelated code.
7. Match the project's indentation, naming, quotes, and file layout.

## Verification

1. Prefer running the code to guessing.
2. Never report done from a plausible-looking diff alone.
3. Address root causes, not symptoms.
4. Read full errors and logs.
5. Run the smallest meaningful verification first, then broaden when risk requires it.

## Repo Workflow

Use the repo scripts instead of hand-built tmux layouts:

```bash
make tmux
```

The default session is `leetcode_practice`. The tmux window is the problem workflow, while OpenCode
runs in a separate Ghostty window.

The LeetCode-specific tmux bindings are tmux bindings, not Neovim bindings:

```text
<tmux-prefix> T    test current solution
<tmux-prefix> S    submit current solution
```

The maintainer's tmux prefix is `C-a`, but public docs should use `<tmux-prefix>` unless a section is
explicitly maintainer-specific.

## After Modifications

Summarize:

```text
Changes made:
- [file]: [what changed and why]

Things I did not touch:
- [file]: [intentionally left alone]

Potential concerns:
- [any risks to verify]
```
