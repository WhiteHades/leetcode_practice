SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

ROOT    := $(CURDIR)
UV      ?= uv
NPM     ?= npm
LEETCODE_CLI_SRC ?= ../leetcode-cli
WORKDIR := $(HOME)/Codes/dsa-ml-practice/leetcode
SESSION := dsa-ml-practice
SCRIPTS := $(ROOT)/scripts

.PHONY: help setup venv ml install config login whoami tmux oc clean repl

help:
	@printf '%s\n' 'dsa-ml-practice'
	@printf '%s\n' ''
	@printf '%s\n' '  make setup     install CLI, build/link, configure workspace'
	@printf '%s\n' '  make install    build/link the LeetCode CLI fork into PATH'
	@printf '%s\n' '  make config     point CLI workspace at this repo'
	@printf '%s\n' '  make login      log in to LeetCode with browser cookies'
	@printf '%s\n' '  make whoami     check LeetCode login status'
	@printf '%s\n' '  make tmux       open or resume the tmux practice workspace'
	@printf '%s\n' '  make oc         focus/open the OpenCode tutor window'
	@printf '%s\n' '  make venv       create/sync Python env'
	@printf '%s\n' '  make ml         install future ML basics'
	@printf '%s\n' '  make clean      clear cache dirs'
	@printf '%s\n' '  make repl       launch ipython in this venv'

setup: install config

venv:
	$(UV) sync

ml:
	$(UV) sync --extra ml

install:
	cd "$(LEETCODE_CLI_SRC)" && $(NPM) install && $(NPM) run build && $(NPM) link

config:
	@mkdir -p "$(WORKDIR)"
	@if leetcode workspace current >/dev/null 2>&1; then :; else leetcode workspace create default >/dev/null 2>&1 || true; fi
	@if leetcode workspace list | grep -q "$(SESSION)"; then :; else leetcode workspace create "$(SESSION)" --workdir "$(WORKDIR)"; fi
	leetcode workspace use "$(SESSION)"
	leetcode config --lang python3 --editor nvim --workdir "$(WORKDIR)"

login:
	leetcode login

whoami:
	leetcode whoami

# Open or attach the practice tmux session.
# Window 1 layout:
#   pane 1 LEFT          : leetcode TUI
#   pane 2 TOP-RIGHT     : nvim (edits the picked .py)
#   pane 3 BOTTOM-RIGHT  : shell (test/submit output, see T/S keybinds)
# Auto-3-pane for every new window in the session is enabled by the
# after-new-window hook in scripts/lc-ensure-session.
tmux:
	@base_workspace="$$(hyprctl activeworkspace -j 2>/dev/null | node -e 'const fs=require("fs"); try { const input=JSON.parse(fs.readFileSync(0,"utf8")); if (Number.isInteger(input.id)) process.stdout.write(String(input.id)); } catch {}' 2>/dev/null || true)"; \
	LC_OPENCODE_BASE_WORKSPACE="$$base_workspace" $(SCRIPTS)/lc-ensure-session
	@if [ -n "$${TMUX:-}" ]; then \
		tmux switch-client -t $(SESSION); \
	else \
		tmux attach -t $(SESSION); \
	fi

oc:
	@$(SCRIPTS)/lc-opencode-window

clean:
	rm -rf .pytest_cache .ruff_cache __pycache__ scripts/__pycache__

repl:
	$(UV) run ipython
