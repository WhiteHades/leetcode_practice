# dsa-ml-practice

Terminal-first LeetCode practice with a ready-made tmux workspace and
an optional OpenCode tutor window.

The goal is simple: open one command, browse problems, edit in Neovim,
test, submit, ask for help, and come back later without rebuilding the
layout by hand.

```text
+-------------+---------------------------+
| LEFT        | TOP-RIGHT                 |
| leetcode    | nvim                      |
| TUI         | solution editor           |
|             +---------------------------+
|             | BOTTOM-RIGHT              |
|             | test/submit shell         |
+-------------+---------------------------+
```

`make tmux` also opens a normal Ghostty OpenCode window outside tmux. If
the LeetCode tmux terminal is on Hyprland workspace `N`, OpenCode is
placed on workspace `N + 1` and reads the current LeetCode problem context
from `leetcode/.current/`.

## Quick Start

Use placeholders for your machine:

- `<repo-dir>`: where this repo is cloned
- `<leetcode-cli-dir>`: where the LeetCode CLI fork is cloned
- `<tmux-prefix>`: your tmux prefix, usually `C-b` unless changed

First-time setup:

```bash
git clone https://github.com/WhiteHades/dsa-ml-practice.git <repo-dir>
git clone https://github.com/WhiteHades/leetcode-cli.git <leetcode-cli-dir>
cd <repo-dir>
make LEETCODE_CLI_SRC=<leetcode-cli-dir> setup
make login
make tmux
```

Daily use after setup:

```bash
cd <repo-dir>
make tmux
```

`make setup` builds and links the LeetCode CLI fork from
`LEETCODE_CLI_SRC`; it does not download that CLI by itself. The default
value is `../leetcode-cli`, so a sibling checkout works without passing
the variable.

OpenCode is not installed by `make setup`. Install it separately from
the OpenCode project/package for your system if you want the tutor
window. Without OpenCode, the normal LeetCode panes still work.

Note: the committed helper scripts and tmux bindings are currently wired
for the maintainer defaults listed below. Public placeholders show what
to replace if you adapt this repo for another machine.

## Daily Workflow

1. Use the left pane to browse LeetCode problems.
2. Press `p` in the LeetCode TUI to pick a problem.
3. The solution file opens automatically in the top-right Neovim pane.
4. Write your solution and save it.
5. Press `<tmux-prefix> T` to run tests in the bottom-right pane.
6. Press `<tmux-prefix> S` to submit the current solution.
7. Switch one workspace to the right, or run `make oc`, when you want
   OpenCode help for the current problem.
8. Press `<tmux-prefix> d` to detach when you are done.
9. Run `make tmux` later to resume.

## Key Bindings

The LeetCode-specific bindings are tmux bindings, not Neovim bindings.
Use your own tmux prefix in place of `<tmux-prefix>`.

| binding | action |
| --- | --- |
| `<tmux-prefix> T` | test the current solution file |
| `<tmux-prefix> S` | submit the current solution file |
| `<tmux-prefix> c` | create a new tmux window |
| `<tmux-prefix> n` / `<tmux-prefix> p` | move to next / previous tmux window |
| `<tmux-prefix> w` | choose a tmux window from a list |
| `<tmux-prefix> d` | detach from tmux |

The test/submit bindings must be added to your tmux config. This repo
includes helper scripts for them under `scripts/`. See the full guide for
the generic binding shape and the maintainer-specific tmux config path.

## OpenCode Tutor

`make tmux` keeps tmux limited to the three LeetCode/Neovim/shell panes.
OpenCode runs as a normal foreground TUI in a separate Ghostty window via
`scripts/lc-opencode-window` and `scripts/lc-opencode`.

The OpenCode tutor uses:

- `AGENTS.md` for repo-specific agent behavior
- `.skills/leetcode-dsa-teach/SKILL.md` for terminal-only DSA teaching
- `.opencode/dsa-prompt.md` for startup context
- `leetcode/.current/problem.md` and `leetcode/.current/problem.json`
  for the current problem

The OpenCode session title follows `leetcode/.current/topic-slug`, so a
problem tagged `linked-list` opens or reuses the `linked-list` chat. The
external watcher closes/reopens the Ghostty OpenCode window when that
topic changes. It never backgrounds OpenCode inside its own terminal.

The default model is:

```text
opencode-go/deepseek-v4-flash
```

If that model is unavailable during first session setup, the launcher
falls back to:

```text
opencode/deepseek-v4-flash-free
```

To use another model for one run:

```bash
LC_OPENCODE_MODEL=<provider/model> make tmux
```

To focus or reopen the tutor directly:

```bash
make oc
```

The launcher sets `TMPDIR` only for its own OpenCode process, using
repo-local `.cache/tmp`. It does not edit global OpenCode config, shell
aliases, or dotfiles, so normal OpenCode use outside this repo is left
alone. Repo OpenCode mouse support is enabled; use Shift-drag when you
want terminal-level selection in a mouse-aware TUI.

## Maintainer Defaults

This repo is currently tuned for the maintainer's local setup:

| setting | maintainer value |
| --- | --- |
| repo path | `~/Codes/dsa-ml-practice` |
| LeetCode CLI path | `~/Codes/leetcode-cli` |
| solution workdir | `~/Codes/dsa-ml-practice/leetcode` |
| tmux session | `dsa-ml-practice` |
| tmux prefix | `C-a` |
| dotfiles source | `~/dotfiles` |
| tmux left pane width | `45%` |
| OpenCode default model | `opencode-go/deepseek-v4-flash` |
| OpenCode fallback model | `opencode/deepseek-v4-flash-free` |

So in the maintainer setup, the daily commands are:

```bash
cd ~/Codes/dsa-ml-practice
make tmux
```

and the main bindings are `C-a T` for test and `C-a S` for submit.

## tmux Plugins

The core 3-pane workflow needs tmux and the helper scripts. Automatic
restore after reboot needs extra tmux plugins.

Recommended plugin path:

1. Install TPM: <https://github.com/tmux-plugins/tpm>
2. Add plugins such as:
   - `tmux-plugins/tmux-resurrect`
   - `tmux-plugins/tmux-continuum`
3. Reload tmux config.
4. Use TPM's install binding, usually `<tmux-prefix> I`.

Without `tmux-resurrect` / `tmux-continuum`, tmux windows can still be
detached and reattached while the tmux server is alive, but they will not
be automatically restored after reboot.

## Full Guide

Read the detailed workflow guide here:

- [docs/workflow-compendium.md](docs/workflow-compendium.md)

It covers repeated attempts, next-day sessions, multiple windows, tmux
session safety, troubleshooting, generated files, snapshots, plugin
expectations, and the maintainer-specific setup.

## Common Questions

**I solved a problem yesterday. Today I want a new approach. What do I do?**

Go to the problem in the left pane and press `p` again. The old current
solution is archived as a numbered file like `1.two-sum.1.py`, and a
fresh unnumbered file like `1.two-sum.py` opens in Neovim.

**Which file is the active attempt?**

The unnumbered file is always the active attempt. Numbered files are old
attempts kept for reference.

**Can I solve multiple problems at the same time?**

Yes. Press `<tmux-prefix> c` to create another tmux window. Each window
gets its own left TUI pane, Neovim pane, and test/submit shell pane.

**How does OpenCode know which problem I mean?**

The LeetCode CLI writes the current problem to `leetcode/.current/`.
OpenCode is instructed to reread those files when you ask for help, so
the context follows the latest problem without scraping tmux panes.

`leetcode/.current/problem.md` is overwritten for the latest viewed
problem. The CLI also keeps deterministic per-problem copies under
`leetcode/.current/problems/<difficulty>/<topic>/<id.slug>.md`, so
reopening the same problem updates the same file instead of creating
duplicates.

**Can I attach without `make tmux`?**

Yes, but it is not the recommended path. `tmux attach -t dsa-ml-practice`
can attach to an existing session, but it skips the repair step. Use
`make tmux` when you want the plug-and-play behavior.

## Make Targets

```text
make help      show commands
make setup     install the LeetCode CLI fork and configure the workspace
make install   build/link the LeetCode CLI fork into PATH
make config    point the CLI workspace at this repo
make login     log in to LeetCode with browser cookies
make whoami    check LeetCode login status
make tmux      open or resume the tmux practice workspace
make venv      create/sync the Python environment
make ml        install optional ML dependencies
make clean     clear local cache directories
make repl      launch ipython
```

## Requirements

- tmux
- Neovim
- Node/npm for the LeetCode CLI fork
- `inotifywait`
- `uv` for Python environment management
- optional: OpenCode for the tutor window
- optional: TPM, `tmux-resurrect`, and `tmux-continuum` for restore

Generated LeetCode solutions are git-ignored and live under the
configured LeetCode workspace directory.
