this repository is only for my leetcode practice. it keeps the browser, editor, test shell, and optional tutor ready so i can focus on solving problems instead of rebuilding the setup each time.

## workflow

1. `make tmux` opens or repairs the `leetcode_practice` tmux session.
2. the left pane runs the leetcode terminal interface.
3. picking a problem opens its python file in neovim in the top right pane.
4. the bottom right pane receives test and submit output.
5. a separate ghostty window runs opencode and follows the current problem through `leetcode/.current`.

the generated solutions, notes, tests, caches, and current problem state stay local and are not committed.

## setup

the leetcode cli source is expected at `~/Codes/projects/leetcode-cli` by default. another location can be passed through `LEETCODE_CLI_SRC`.

```bash
git clone https://github.com/whitehades/leetcode_practice.git
cd leetcode_practice
make setup
make login
make tmux
```

`make setup` installs the cli from its existing source repository and configures its workspace to use this repository's `leetcode` directory.

## daily use

```bash
make tmux
```

1. press `p` in the leetcode interface to pick a problem.
2. solve it in the neovim pane.
3. press `<tmux_prefix> t` to test the current solution.
4. press `<tmux_prefix> s` to submit the current solution.
5. run `make oc` to focus or reopen the opencode tutor.
6. detach from tmux when finished and run `make tmux` later to resume.

the configured tmux prefix on my system is `c a`, so the two main bindings are `c a t` and `c a s`.

## requirements

1. tmux
2. neovim
3. node and npm
4. the leetcode cli source repository
5. `inotifywait`
6. uv
7. ghostty and opencode for the optional tutor window
