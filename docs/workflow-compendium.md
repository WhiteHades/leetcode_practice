# LeetCode Workflow Compendium

This is the detailed guide for the `dsa-ml-practice` workflow. It uses
generic placeholders first, then lists the maintainer-specific values in
a separate section.

## Placeholders

Use these names when adapting the workflow:

| placeholder | meaning |
| --- | --- |
| `<repo-dir>` | where this repo is cloned |
| `<leetcode-cli-dir>` | where the LeetCode CLI fork is cloned |
| `<workdir>` | where generated LeetCode solution files are written |
| `<tmux-prefix>` | your tmux prefix, usually `C-b` unless changed |
| `<session-name>` | the tmux session name, default `dsa-ml-practice` |
| `<provider/model>` | an OpenCode model id, for example `opencode-go/deepseek-v4-flash` |

The maintainer's current values are documented later in
[Maintainer Setup](#maintainer-setup).

Important: the committed helper scripts and tmux bindings are currently
wired for the maintainer setup. The placeholders in this guide show what
to change if you adapt the repo for another machine.

## Mental Model

The default tmux workspace has one problem window with three panes:

```text
+-------------+---------------------------+
| LEFT        | TOP-RIGHT                 |
| leetcode    | nvim                      |
| TUI         | current solution file     |
|             +---------------------------+
|             | BOTTOM-RIGHT              |
|             | shell for test/submit     |
+-------------+---------------------------+
```

OpenCode is not run inside tmux. `make tmux` opens or reuses a normal
Ghostty OpenCode window on the Hyprland workspace immediately to the
right of the terminal where you launched tmux. If LeetCode tmux starts on
workspace `N`, OpenCode goes to workspace `N + 1`.

The left pane is for choosing problems. The top-right pane is for
editing code. The bottom-right pane is for commands and output.

The workflow glue is:

- `lc-watch` watches for newly picked solution files.
- When the TUI creates a fresh primary `.py` file, `lc-watch` opens it
  in Neovim.
- `lc-watch` writes the current file path to `<workdir>/.current/path`.
- the LeetCode CLI writes the current problem context to
  `<workdir>/.current/problem.md` and `<workdir>/.current/problem.json`.
- `<tmux-prefix> T` and `<tmux-prefix> S` run test/submit against that
  exact current file.
- the OpenCode tutor reads `<workdir>/.current/` when you ask for help.
- `lc-opencode-watch` watches the topic slug and refreshes the external
  Ghostty OpenCode window when the topic changes.

That last point matters. The workflow targets the current file path, not
just the problem number. That prevents old numbered attempts from being
tested by accident.

## First-Time Setup

Clone both repositories:

```bash
git clone https://github.com/WhiteHades/dsa-ml-practice.git <repo-dir>
git clone https://github.com/WhiteHades/leetcode-cli.git <leetcode-cli-dir>
```

Then run setup:

```bash
cd <repo-dir>
make LEETCODE_CLI_SRC=<leetcode-cli-dir> setup
make login
```

`make setup` runs `make install` and `make config`.

`make install` does this:

- enters `LEETCODE_CLI_SRC`
- runs `npm install`
- runs `npm run build`
- runs `npm link`

Important: `make setup` does not clone the LeetCode CLI. You must clone
it first. The default CLI path is `../leetcode-cli`, so a sibling clone
works without passing `LEETCODE_CLI_SRC`.

`make login` runs:

```bash
leetcode login
```

It asks for browser cookie values from LeetCode. After logging in, check
auth with:

```bash
make whoami
```

## tmux Prefix And Bindings

The guide uses `<tmux-prefix>` because every tmux setup can be different.

Examples:

- stock tmux default: `C-b`
- maintainer setup: `C-a`

So if the guide says:

```text
<tmux-prefix> T
```

then:

- with stock tmux, press `C-b`, release, then `T`
- with the maintainer setup, press `C-a`, release, then `T`

## Required tmux Wiring

The LeetCode-specific test/submit bindings are not built into tmux. They
must be added to tmux config.

Generic binding shape:

```tmux
bind T run-shell -b 'LC_TMUX_PANE="#{pane_id}" <repo-dir>/scripts/lc-test-pane'
bind S run-shell -b 'LC_TMUX_PANE="#{pane_id}" <repo-dir>/scripts/lc-submit-pane'
```

The helper scripts are guarded so the bindings only act inside the
configured LeetCode tmux session. They should not send LeetCode commands
into unrelated tmux sessions.

## tmux Plugins

Core workflow:

- tmux
- the bindings above
- the helper scripts in this repo

Automatic restore after reboot:

- TPM
- `tmux-plugins/tmux-resurrect`
- `tmux-plugins/tmux-continuum`

Install direction:

1. Install TPM from <https://github.com/tmux-plugins/tpm>.
2. Add plugin lines to your tmux config:

   ```tmux
   set -g @plugin 'tmux-plugins/tpm'
   set -g @plugin 'tmux-plugins/tmux-resurrect'
   set -g @plugin 'tmux-plugins/tmux-continuum'
   ```

3. Reload tmux config.
4. Press TPM's install binding, usually `<tmux-prefix> I`.

Optional maintainer plugin:

- `christoomey/vim-tmux-navigator`

That plugin helps move between Vim and tmux panes. It is convenient, but
not required for the LeetCode workflow.

Without `tmux-resurrect` and `tmux-continuum`, you can still detach and
reattach while tmux is running. You just should not expect automatic
restore after a full reboot.

## Starting The Workspace

Recommended:

```bash
cd <repo-dir>
make tmux
```

This is better than plain `tmux attach` because it runs the repo repair
script first.

`make tmux` does this:

1. ensures the `<session-name>` tmux session exists
2. creates the standard 3-pane layout if needed
3. repairs a stale or half-restored first window when it can
4. removes any stale old tmux tutor window from previous workflow versions
5. starts the file watcher in the bottom-right pane if missing
6. opens or reuses external Ghostty OpenCode on workspace `N + 1`
7. starts the external topic watcher if missing
8. attaches from a normal terminal
9. switches clients if you are already inside another tmux session

Manual attach is possible if the session already exists:

```bash
tmux attach -t <session-name>
```

If you are already inside another tmux session:

```bash
tmux switch-client -t <session-name>
```

Manual attach skips the repair step. If panes are weird, use
`make tmux`.

## Main Key Bindings

Use your own tmux prefix in place of `<tmux-prefix>`.

| binding | action |
| --- | --- |
| `<tmux-prefix> T` | test the current solution |
| `<tmux-prefix> S` | submit the current solution |
| `<tmux-prefix> c` | create a new practice window |
| `<tmux-prefix> n` | next window |
| `<tmux-prefix> p` | previous window |
| `<tmux-prefix> w` | list windows |
| `<tmux-prefix> 1` | go to the first problem window |
| `<tmux-prefix> d` | detach |
| `<tmux-prefix> [` | enter tmux copy-mode |
| `q` or `Esc` | leave tmux copy-mode |

If you install `tmux-resurrect`, its default manual save binding is:

```text
<tmux-prefix> C-s
```

## Normal Daily Flow

1. Start:

   ```bash
   cd <repo-dir>
   make tmux
   ```

2. In the left pane, browse or search for a problem.
3. Press `p` in the LeetCode TUI.
4. Wait for the top-right Neovim pane to open the solution file.
5. Write code and save it in Neovim.
6. Press `<tmux-prefix> T`.
7. Read test output in the bottom-right pane.
8. If tests pass, press `<tmux-prefix> S`.
9. Use the Ghostty OpenCode window on the workspace to the right when you
   want help with the current problem. Run `make oc` to focus or reopen it.
10. Detach with `<tmux-prefix> d` when done.

## OpenCode Tutor Window

The OpenCode tutor is a normal Ghostty window, not a tmux pane. This keeps
OpenCode's keyboard, mouse, scrolling, selection, and TUI state separate
from tmux.

The repo provides:

```text
AGENTS.md
.skills/leetcode-dsa-teach/SKILL.md
.opencode/dsa-prompt.md
.opencode/config.env
scripts/lc-opencode
scripts/lc-opencode-window
scripts/lc-opencode-watch
```

`AGENTS.md` tells OpenCode to read the latest files under:

```text
<workdir>/.current/
```

The important files are:

```text
problem.md              live current problem in terminal-friendly Markdown
problem.json            live current problem as structured data
problem-cache-md        path to the deterministic per-problem Markdown cache
problem-cache-json      path to the deterministic per-problem JSON cache
problems/<difficulty>/<topic>/<id.slug>.md
problems/<difficulty>/<topic>/<id.slug>.json
problem-id              current viewed problem id
problem-slug            current viewed problem slug
topic-name              first topic tag name
topic-slug              first topic tag slug
id                      active picked solution id
path                    active picked solution path
```

Viewing a problem in the LeetCode CLI overwrites `problem.md` and
`problem.json` with the latest viewed problem. It also writes a
deterministic per-problem cache file under `problems/<difficulty>/<topic>/`.

Example:

```text
<workdir>/.current/problem.md
<workdir>/.current/problem.json
<workdir>/.current/problems/Easy/array/1.two-sum.md
<workdir>/.current/problems/Easy/array/1.two-sum.json
```

Reopening Two Sum updates the same `1.two-sum.*` cache files. It does
not create duplicates.

Difficulty comes from LeetCode's difficulty field: `Easy`, `Medium`, or
`Hard`. Topic comes from the first LeetCode topic tag slug. All topic
tags are still written inside `problem.md` and `problem.json`.

Picking a solution updates `id` and `path`. Merely viewing a problem
does not change the active test/submit path unless that path already
matches the viewed problem.

### Asking For Help

In the external Ghostty OpenCode window, ask normally:

```text
explain the current problem
give me hints
debug my current code
teach me the pattern for this problem
what edge cases should I test?
```

OpenCode is instructed to reread `<workdir>/.current/problem.md` and the
current solution path when those requests need problem or code context.

### Session Titles

When `scripts/lc-opencode` starts, it reads:

```text
<workdir>/.current/topic-slug
```

and uses that as the OpenCode session title. Examples:

```text
linked-list
array
dynamic-programming
```

If a session with the same title and repo directory already exists,
OpenCode reuses it. If not, the launcher creates one.

The separate `scripts/lc-opencode-watch` process watches
`<workdir>/.current/topic-slug`. If you browse to a problem whose first
topic slug is different, it closes the current external OpenCode Ghostty
window and reopens the matching topic chat. If the new problem has the
same first topic slug, the same OpenCode chat stays open.

The chat session is per topic, not per problem. For example, two
different linked-list problems use the same `linked-list` OpenCode
session.

You normally do not run the raw launcher by hand. Use:

```bash
make oc
```

That focuses or reopens the external Ghostty OpenCode window for the
current topic.

### Models

Default model:

```text
opencode-go/deepseek-v4-flash
```

Fallback model for first-session setup:

```text
opencode/deepseek-v4-flash-free
```

The defaults live in:

```text
.opencode/config.env
```

The launcher asks OpenCode's database for the exact matching topic title
and repo directory. It does not delete, cap, or limit your OpenCode
sessions.

Temporary OpenCode seed logs and watcher state go to a repo-local cache directory at
`<repo-dir>/.cache/opencode`, and are removed after successful startup.
OpenCode temp files for this launcher use `<repo-dir>/.cache/tmp`. The
`.cache/` directory is ignored by git.

This customization is scoped to this repo launcher. It exports `TMPDIR`
only for the OpenCode process it starts. It does not edit global OpenCode
config, shell aliases, zsh config, tmux config, or dotfiles. Normal
OpenCode use outside this workflow is left alone.

For a one-off model swap:

```bash
LC_OPENCODE_MODEL=<provider/model> make tmux
```

or directly:

```bash
LC_OPENCODE_MODEL=<provider/model> make oc
```

### Mouse And Selection

Repo OpenCode mouse support is enabled. The mouse wheel should scroll the
OpenCode chat instead of walking prompt history.

Because OpenCode is a mouse-aware terminal TUI, unmodified drag events go
to OpenCode. For terminal-level selection and Ghostty copy-on-select, use
Shift-drag.

### If OpenCode Is Not Installed

The LeetCode workflow still works. The external tutor window is skipped.
Install the OpenCode CLI for your system, then run:

```bash
cd <repo-dir>
make oc
```

## Next Day: Continue The Same Solution

If you come back the next day and want to continue the same answer:

1. Run `make tmux`.
2. If Neovim still has the file open, keep editing.
3. Save in Neovim.
4. Press `<tmux-prefix> T` to test.
5. Press `<tmux-prefix> S` to submit.

The current active file is the unnumbered file:

```text
1.two-sum.py
```

If that is the file open in Neovim, you are editing the active attempt.

## Next Day: Try A Different Solution To The Same Problem

Imagine yesterday you solved Two Sum and it passed. Today you reopen the
session and Neovim still shows the correct old answer. You now want a
fresh attempt.

Recommended flow:

1. Go to the left pane.
2. Navigate to the same problem in the LeetCode TUI.
3. Press `p` again.
4. The old current file is renamed to a numbered archive.
5. A fresh unnumbered file is created.
6. Neovim opens the fresh unnumbered file automatically.

Example:

```text
before:
1.two-sum.py          # yesterday's working solution

after pressing p again:
1.two-sum.1.py        # archived old solution
1.two-sum.py          # fresh current attempt
```

So yes: go to the problem pane and press `p`. That is the recommended
way to start another attempt for the same problem.

Do not manually create `1.two-sum.2.py` as your active file. Numbered
files are archives. The workflow treats the unnumbered file as current.

## How Numbering Works

The rule is simple:

```text
unnumbered file = current attempt
numbered file   = archived older attempt
```

Example:

```text
1.two-sum.py
1.two-sum.1.py
1.two-sum.2.py
1.two-sum.3.py
```

Meaning:

- `1.two-sum.py` is the active attempt.
- `1.two-sum.1.py` is the first archived attempt.
- `1.two-sum.2.py` is the second archived attempt.
- `1.two-sum.3.py` is the third archived attempt.

The numbering is not backwards. The higher number is newer among the
archives, but the unnumbered file is still the current one.

## Testing And Submitting

Use:

```text
<tmux-prefix> T
```

to test.

Use:

```text
<tmux-prefix> S
```

to submit.

Both commands target the path stored in:

```text
<workdir>/.current/path
```

That file is updated when you press `p` in the TUI and a fresh primary
solution file is created.

The output appears in the bottom-right pane.

If the bottom-right pane is in tmux copy-mode, the scripts cancel
copy-mode before sending commands. This prevents tmux from interpreting
letters inside `leetcode test` as copy-mode jump commands.

## Multiple Problems At The Same Time

Use one tmux window per problem.

Create a new practice window:

```text
<tmux-prefix> c
```

That new window gets the same three panes:

- left: LeetCode TUI
- top-right: Neovim
- bottom-right: shell and watcher

Pick a different problem in the new window by pressing `p` in that
window's left pane.

There is one shared external OpenCode tutor window. It follows the latest
problem context written to `<workdir>/.current/`. If you are working on
several problem windows, open or pick the problem you want help with
before asking OpenCode.

Switch windows with:

```text
<tmux-prefix> n      next window
<tmux-prefix> p      previous window
<tmux-prefix> w      window list
<tmux-prefix> 1      window 1
```

## Saving And Restoring Windows

tmux itself preserves sessions while the tmux server is running. For
restore after a reboot, install `tmux-resurrect` and `tmux-continuum`.

With those plugins installed, recommended shutdown flow:

```text
<tmux-prefix> C-s
<tmux-prefix> d
```

Then shut down.

After booting again:

```bash
cd <repo-dir>
make tmux
```

tmux restore is not perfect. It usually restores windows, panes,
commands, and pane contents, but terminal apps can still come back
imperfectly after a hard shutdown. `make tmux` runs the repair step and
gives you a healthy standard window if saved state is stale.

## Other tmux Sessions

This workflow uses one named tmux session. By default:

```text
dsa-ml-practice
```

Your other tmux sessions can still exist. This repo does not take over
the whole tmux server.

The intended session-specific behavior is:

- `make tmux` creates or repairs only the LeetCode practice session.
- new-window auto-layout is installed as a session hook for that
  session.
- test/submit helper scripts refuse to run outside that session.

If you are inside another tmux session and run:

```bash
cd <repo-dir>
make tmux
```

tmux switches your current client to the practice session. It does not
nest tmux inside tmux.

To go back to another session, use your tmux session chooser, commonly:

```text
<tmux-prefix> s
```

or:

```bash
tmux switch-client -t <other-session-name>
```

## File Locations

Generic:

```text
<repo-dir>                    tracked repo files
<workdir>                     generated LeetCode solutions
<workdir>/.current/path       current solution sentinel
<workdir>/.current/problem.md current problem for OpenCode
```

LeetCode workspace config and snapshots usually live under the CLI's
workspace storage, for example:

```text
~/.leetcode/workspaces/<workspace-name>
```

Generated solution files are git-ignored. They are practice work, not
repo source code.

## Snapshots

The CLI also has explicit snapshots:

```bash
leetcode snapshot save 1 brute-force
leetcode snapshot save 1 hashmap
leetcode snapshot list 1
leetcode snapshot restore 1 brute-force
leetcode snapshot diff 1 1 2
```

Use snapshots when you want named versions. Use the normal `p` re-pick
workflow when you just want a fresh attempt.

## Maintainer Setup

This is the current setup on the maintainer machine. These values are
examples, not public requirements.

| setting | value |
| --- | --- |
| repo path | `~/Codes/dsa-ml-practice` |
| LeetCode CLI path | `~/Codes/leetcode-cli` |
| LeetCode CLI remote | `https://github.com/WhiteHades/leetcode-cli` |
| solution workdir | `~/Codes/dsa-ml-practice/leetcode` |
| tmux session | `dsa-ml-practice` |
| tmux prefix | `C-a` |
| dotfiles source | `~/dotfiles` |
| tmux config source | `~/dotfiles/tmux/.tmux.conf` |
| tmux left pane width | `45%` |
| OpenCode default model | `opencode-go/deepseek-v4-flash` |
| OpenCode fallback model | `opencode/deepseek-v4-flash-free` |

Maintainer daily command:

```bash
cd ~/Codes/dsa-ml-practice
make tmux
```

Maintainer key examples:

```text
C-a T      test current solution
C-a S      submit current solution
C-a c      create another practice window
C-a d      detach
C-a C-s    save tmux-resurrect state
```

Maintainer tmux plugins:

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'christoomey/vim-tmux-navigator'
```

## Recommended Habits

- Start with `make tmux`.
- Use one tmux window per active problem.
- Press `p` to create or refresh the active attempt.
- Treat the unnumbered file as current.
- Treat numbered files as archived attempts.
- Save in Neovim before testing.
- Use `<tmux-prefix> T` for test and `<tmux-prefix> S` for submit.
- Use the external Ghostty OpenCode window for current-problem teaching
  and debugging.
- If using tmux restore plugins, save with `<tmux-prefix> C-s` before
  shutdown.
- Use `make tmux` after reboot instead of direct `tmux attach`.

## Troubleshooting

### Test or submit binding does nothing

Check that you are inside the practice tmux session:

```bash
tmux display-message -p '#S'
```

If not, run:

```bash
cd <repo-dir>
make tmux
```

### Bottom-right pane feels stuck in visual mode

That is usually tmux copy-mode.

Manual fix:

```text
q
```

or:

```text
Esc
```

The test/submit scripts also cancel copy-mode automatically before
running commands.

### Neovim did not open the picked file

Run:

```bash
cd <repo-dir>
make tmux
```

That restarts the watcher if it is missing.

Then pick the problem again with `p`.

### I attached manually and the panes look wrong

Use:

```bash
cd <repo-dir>
make tmux
```

Manual `tmux attach` skips the repair step.

### I want a totally fresh practice window

Inside the session:

```text
<tmux-prefix> c
```

Then pick a problem in the new left pane.

### OpenCode is talking about the wrong problem

Check the current context:

```bash
cat <workdir>/.current/problem.md
```

If it is stale, go to the left LeetCode pane for the problem you want
and open that problem again. Picking with `p` also refreshes the active
solution path.

### I want the OpenCode chat title to match the latest topic

You should not need to do anything manually. The external watcher watches:

```text
<workdir>/.current/topic-slug
```

When that file changes to a new topic slug, the watcher closes the
current external Ghostty OpenCode window and reopens the existing
matching session, creating one only when needed.

If the OpenCode window is missing or idle, run `make oc` from
`<repo-dir>` to focus or reopen it.

### I want to inspect old attempts

List them from your workdir:

```bash
find <workdir> -name '1.two-sum*' -print
```

Open an archived file manually in Neovim if you want to read it. Keep in
mind that test/submit uses the current unnumbered file, not archives.

## Command Reference

```text
make help      show commands
make setup     install CLI and configure workspace
make install   build/link the LeetCode CLI fork
make config    point CLI workspace at this repo
make login     log in to LeetCode
make whoami    check login status
make tmux      open or resume the practice workspace
make oc        focus/open the external OpenCode tutor
make venv      create/sync Python env
make ml        install optional ML dependencies
make clean     clear caches
make repl      launch ipython
```

## Design Rules

This workflow is intentionally narrow:

- one named tmux session
- one standard problem layout
- one repo-root external Ghostty OpenCode tutor window
- one active solution path
- no manual pane setup
- no guessing which numbered file to test

When in doubt, return to the simple path:

```bash
cd <repo-dir>
make tmux
```
