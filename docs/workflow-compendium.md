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

The maintainer's current values are documented later in
[Maintainer Setup](#maintainer-setup).

Important: the committed helper scripts and tmux bindings are currently
wired for the maintainer setup. The placeholders in this guide show what
to change if you adapt the repo for another machine.

## Mental Model

Each practice window has three panes:

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

The left pane is for choosing problems. The top-right pane is for
editing code. The bottom-right pane is for commands and output.

The workflow glue is:

- `lc-watch` watches for newly picked solution files.
- When the TUI creates a fresh primary `.py` file, `lc-watch` opens it
  in Neovim.
- `lc-watch` writes the current file path to `<workdir>/.current/path`.
- `<tmux-prefix> T` and `<tmux-prefix> S` run test/submit against that
  exact current file.

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
4. starts the file watcher in the bottom-right pane if missing
5. attaches from a normal terminal
6. switches clients if you are already inside another tmux session

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
9. Detach with `<tmux-prefix> d` when done.

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

Switch windows with:

```text
<tmux-prefix> n      next window
<tmux-prefix> p      previous window
<tmux-prefix> w      window list
<tmux-prefix> 1      window 1
<tmux-prefix> 2      window 2
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
make tmux      open or resume the practice session
make venv      create/sync Python env
make ml        install optional ML dependencies
make clean     clear caches
make repl      launch ipython
```

## Design Rules

This workflow is intentionally narrow:

- one named tmux session
- one standard layout
- one active solution path
- no manual pane setup
- no guessing which numbered file to test

When in doubt, return to the simple path:

```bash
cd <repo-dir>
make tmux
```
