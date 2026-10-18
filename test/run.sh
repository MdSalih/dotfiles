#!/usr/bin/env bash
# shellcheck disable=SC2016  # single-quoted bash -c bodies are intentional
# Lint + smoke tests, run locally and in CI. Uses a throwaway $HOME; never touches yours.
set -euo pipefail
REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
FAKE_HOME=$(mktemp -d)
trap 'tmux -L dotfiles-test kill-server 2>/dev/null || true; rm -rf "$FAKE_HOME"' EXIT
fail=0
ok()  { printf 'ok    %s\n' "$*"; }
bad() { printf 'FAIL  %s\n' "$*"; fail=1; }
check() { local name=$1; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }

shell_files=("$REPO/bootstrap.sh" "$REPO/test/run.sh" "$REPO/home/.bashrc" "$REPO/home/.bash_profile"
             "$REPO/home/.config/bash/aliases.bash" "$REPO/home/.config/bash/prompt.bash")

for f in "${shell_files[@]}"; do check "bash -n ${f#"$REPO"/}" bash -n "$f"; done
if command -v shellcheck >/dev/null 2>&1; then
  check "shellcheck" shellcheck -s bash -e SC1090,SC1091 "${shell_files[@]}"
else
  echo "skip  shellcheck (not installed)"
fi

# bootstrap: dry run changes nothing; real run links; second run is a no-op
check "bootstrap dry run leaves HOME empty" bash -c \
  'HOME="$1" "$2/bootstrap.sh" -n >/dev/null && [ -z "$(ls -A "$1")" ]' _ "$FAKE_HOME" "$REPO"
echo "old" > "$FAKE_HOME/.tmux.conf"
check "bootstrap first run" env HOME="$FAKE_HOME" "$REPO/bootstrap.sh" >/dev/null
check "old ~/.tmux.conf backed up" bash -c 'grep -qx old "$1"/.local/state/dotfiles/backup/*/.tmux.conf' _ "$FAKE_HOME"
check "links point into repo" test "$(readlink "$FAKE_HOME/.config/git/config")" = "$REPO/home/.config/git/config"
second=$(HOME="$FAKE_HOME" "$REPO/bootstrap.sh")
check "bootstrap second run is a no-op" bash -c '! grep -qE "^  (link|backup) " <<<"$1"' _ "$second"

# tmux: config parses without errors
if command -v tmux >/dev/null 2>&1; then
  HOME="$FAKE_HOME" tmux -L dotfiles-test -f /dev/null new-session -d -s t
  check "tmux.conf loads cleanly" bash -c \
    'out=$(HOME="$1" tmux -L dotfiles-test source-file "$1/.config/tmux/tmux.conf" 2>&1); [ -z "$out" ] || { echo "$out"; false; }' _ "$FAKE_HOME"
fi

# vim: vimrc loads without errors (no plugins installed)
VIM_BIN=${VIM_BIN:-vim}   # e.g. VIM_BIN=vim.basic where "vim" is Neovim
if command -v "$VIM_BIN" >/dev/null 2>&1 && "$VIM_BIN" --version | head -n1 | grep -q '^VIM'; then
  check "vimrc loads cleanly" bash -c \
    'out=$(HOME="$1" "$2" -N -u "$1/.vim/vimrc" -i NONE -es +"redir => m | silent messages | redir END | put =m | %print" +"qall!" 2>&1 | grep -E "^E[0-9]+|Error" || true); [ -z "$out" ] || { echo "$out"; false; }' _ "$FAKE_HOME" "$VIM_BIN"
else
  echo "skip  vim (no real Vim found; set VIM_BIN)"
fi

# git: config parses
check "git config parses" bash -c 'GIT_CONFIG_GLOBAL="$1" git config --global --list >/dev/null' _ "$FAKE_HOME/.config/git/config"

# bash: interactive login shell starts with no stderr output
check "bash login shell is quiet" bash -c \
  'err=$(env -i HOME="$1" PATH=/usr/bin:/bin TERM=xterm-256color bash -l -i -c "declare -F __dotfiles_prompt >/dev/null" 2>&1 >/dev/null | grep -v "job control\|terminal process group" || true); [ -z "$err" ] || { echo "$err"; false; }' _ "$FAKE_HOME"

exit $fail
