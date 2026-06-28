# dsa-ml-practice

Terminal-native LeetCode / DSA practice now, ML practice later.

The repo is built around a single 3-pane tmux session that recreates the
LeetCode.com browser experience in your terminal:

```text
+------------------+------------------------+
|  LEFT            |  TOP-RIGHT            |
|  leetcode TUI    |  nvim (code editor)   |
|  (browse, pick,  |                        |
|   hints, stats)  +------------------------+
|                  |  BOTTOM-RIGHT          |
|                  |  shell                 |
|                  |  (test/submit output)  |
+------------------+------------------------+
```

Every new tmux window in the session automatically starts with this same
3-pane layout. The session is started from a Makefile target; the
TUI-to-editor hand-off is wired by an inotifywait watcher. Test and
submit run in the bottom-right pane through tmux keybinds.

The LeetCode CLI used is the Night Slayer TypeScript fork in
`../leetcode-cli`. It is built and linked into `PATH` by `make install`.

## Setup

```bash
make setup
```

This does three things:

- builds and links the LeetCode CLI fork into your `PATH`,
- creates and uses the `dsa-ml-practice` LeetCode workspace,
- points that workspace at `~/Codes/dsa-ml-practice/leetcode` and sets
  the editor to `nvim` and the language to `python3`.

Then log in once:

```bash
make login
```

The CLI asks for your `LEETCODE_SESSION` and `csrftoken` cookie values
from a logged-in browser. Credentials are stored in the system keychain
by default.

## Daily Practice

```bash
make tmux
```

What you get:

```text
session:   dsa-ml-practice
window 1:  name=problems (3-pane layout, see above)
            pane 0 = leetcode TUI   (run by tmux)
            pane 1 = nvim           (run by tmux)
            pane 2 = shell + lc-watch watcher (inotify-based)
```

Open `make tmux` from any directory; it is the single entry point.

### Workflow inside the session

1. You start in the LEFT pane (the leetcode TUI).
2. Use the TUI to browse, filter, hint, and inspect submissions.
3. When you find a problem you want, press `p` in the TUI to pick it.
   This writes the solution `.py` file under the workspace workdir.
4. The inotifywait watcher detects the new file and sends
   `:edit <path>` to the nvim pane, so the editor auto-opens it.
5. Edit the solution in the nvim pane.
6. Press `C-a T` to run `leetcode test <id>` in the bottom-right pane.
   The id is read from the sentinel that the watcher writes; you can
   also pass a different id at the prompt.
7. Press `C-a S` to submit. Output streams in the bottom-right pane.
8. Press `C-a c` to open a new window. It is auto-split into the same
   3-pane layout, so you can solve a second problem in parallel.
9. Detach with `C-a d` and reattach with `make tmux` later. Pane state
   is preserved by `tmux-resurrect` / `tmux-continuum` (already enabled
   in your dotfiles).

## Keybinds (added in dotfiles)

- `C-a T` — run `leetcode test <id>` in the bottom-right pane.
  Argument: id or empty (uses the current sentinel).
- `C-a S` — run `leetcode submit <id>` in the bottom-right pane.
  Argument: id or empty (uses the current sentinel).
- `C-a c` — new window, auto-split into the same 3-pane layout.
- `C-a d` — detach.
- `C-a r` — reload `~/.tmux.conf` (unchanged from your dotfiles).

If `C-a T` or `C-a S` does nothing, press `C-a r` to reload the tmux
config (the keybinds are loaded into the running server, not just
into new sessions).

## How Multiple Approaches to the Same Problem Work

The night-slayer TUI's `p` (pick) action has been configured so that
re-picking an already-picked problem preserves your previous attempt
and creates a fresh template for a new method.

When you press `p` on a problem whose solution file already exists:

1. The CLI finds the next available variant number (`1`, `2`, `3`, ...).
2. The existing file is renamed to `<id>.<slug>.<N>.<ext>` (e.g.
   `1.two-sum.1.py`).
3. A fresh template is written to the original path
   (`<id>.<slug>.<ext>`).
4. The inotifywait watcher detects the new template, writes the
   problem id to the sentinel, and sends `:edit <path>` to the nvim
   pane, opening the fresh template.
5. The TUI status drawer shows the rename: e.g.
   `Saved previous as 1.two-sum.1.py; new template at 1.two-sum.py`.

So your workflow is:

1. Press `p` on a problem. Edit the file in nvim. Save with `:w`.
2. Want to try a different method? Press `p` again. Your previous
   attempt is preserved as `1.two-sum.1.py`. A fresh template is
   opened in nvim. Edit, save, repeat.
3. List all your attempts with `leetcode snapshot list 1` or by
   looking at the directory:
   `ls ~/Codes/dsa-ml-practice/leetcode/Easy/Array/1.two-sum*`.
4. Compare two attempts with `diff` (system) or with
   `leetcode snapshot diff 1 1 2` if you saved snapshots.

This is git-ignored (the workdir is excluded in `.gitignore`).

If you want the snapshot system instead, see below.

### Option: Snapshots (for explicit versioning)

```bash
leetcode snapshot save 1 brute-force
leetcode snapshot save 1 hashmap
leetcode snapshot list 1
leetcode snapshot restore 1 brute-force
leetcode snapshot diff 1 1 2
```

Snapshots live outside the repo, in
`~/.leetcode/workspaces/dsa-ml-practice/snapshots/`, so they are
git-ignored and never leak into commits.

### Important

The watcher only fires on file creation/move events. The sentinel
(`~/Codes/dsa-ml-practice/leetcode/.current/id`) updates on every
TUI pick (including re-picks), so `C-a T` will always test the
freshly opened file.

## File Layout

```text
dsa-ml-practice/
├── .env.example           # env-only auth template (optional)
├── .gitignore             # ignores .venv, .env, leetcode/.current, caches
├── .python-version
├── Makefile               # the only command surface
├── README.md
├── leetcode/              # workdir; CLI writes solutions and .notes here
├── ml/                    # placeholder for future ML practice
├── pyproject.toml         # Python deps (ipython + optional ML)
├── scripts/
│   ├── lc-new-window      # called by after-new-window tmux hook
│   ├── lc-watch           # inotifywait watcher (file -> nvim + sentinel)
│   ├── lc-test-pane       # `C-a T`: leetcode test in bottom-right pane
│   ├── lc-submit-pane     # `C-a S`: leetcode submit in bottom-right pane
│   └── lc-current-id      # print sentinel id (for shell pipelines)
└── uv.lock
```

## Where Artifacts Live Outside The Repo

- Generated solutions and notes: `~/Codes/dsa-ml-practice/leetcode/`
  (set as the active LeetCode workspace workdir).
- Workspace config and snapshots:
  `~/.leetcode/workspaces/dsa-ml-practice/`
- LeetCode credentials: OS keychain (set by `make login`).

## Make Targets (the only ones)

```text
make help      show this list
make setup     install CLI + configure workspace
make install   build/link the LeetCode CLI fork
make config    point CLI workspace at this repo
make tmux      open/attach the 3-pane session
make venv      create/sync Python env
make ml        install optional ML deps (numpy/pandas/matplotlib/sklearn)
make clean     clear cache dirs
make repl      launch ipython
```

## Manual Smoke Test

```bash
make setup        # only first time
make login        # only first time (or when cookies expire)
make tmux

# inside the session:
#   - left pane: press j/k to move, Enter to open a problem
#   - left pane: press p to pick (writes <id>.<slug>.py)
#   - right top: nvim auto-opens that file
#   - edit, save
#   - press C-a T to test in the bottom-right pane
#   - press C-a S to submit
#   - press C-a c to open a new problem window (auto 3-pane)
#   - press C-a d to detach
make tmux         # reattach later; state is preserved by tmux-resurrect
```

## Why This Setup

- The LeetCode CLI gives you the closest terminal-native LeetCode
  experience: list, pick, edit, test, submit, hints, submissions,
  snapshots, stats, notes, bookmarks, diffs, workspaces, daily, random.
- tmux gives you the layout. Three panes side by side mirror the
  LeetCode.com browser (question left, code top-right, console
  bottom-right).
- The inotifywait watcher is the smallest possible glue between the
  TUI's `p` action and the nvim pane. No forking the CLI required.
- State preservation comes from `tmux-resurrect` and `tmux-continuum`,
  which are already enabled in your dotfiles.
- Multiple approaches to the same problem are supported via the CLI's
  built-in snapshot system; the watcher does not interfere with copies
  or renames.
