# dsa-ml-practice

Terminal-first LeetCode practice with a ready-made tmux workspace.

The goal is simple: open one command, browse problems, edit in Neovim,
test, submit, and come back later without rebuilding the layout by hand.

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
7. Press `<tmux-prefix> d` to detach when you are done.
8. Run `make tmux` later to resume.

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
make tmux      open or resume the 3-pane practice session
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
- optional: TPM, `tmux-resurrect`, and `tmux-continuum` for restore

Generated LeetCode solutions are git-ignored and live under the
configured LeetCode workspace directory.
