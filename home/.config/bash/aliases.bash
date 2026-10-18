# ~/.config/bash/aliases.bash (sourced by ~/.bashrc)
# shellcheck shell=bash

alias a='alias'
alias v='vim'
alias g='git'
alias h='history'
alias df='df -h'
alias du='du -h'
alias grep='grep --color=auto'

# ls: eza if installed, else GNU/BSD ls with colour
if command -v eza >/dev/null 2>&1; then
  # shellcheck disable=SC2262
  alias ls='eza'
  alias ll='eza -l --git'
  alias la='eza -la --git --sort=modified'
elif command ls --color=auto -d . >/dev/null 2>&1; then   # GNU ls
  alias ls='ls --color=auto'
  alias ll='ls -lh'
  alias la='ls -ltrah'
else                                              # BSD / macOS ls
  export CLICOLOR=1
  alias ll='ls -lh'
  alias la='ls -ltrah'
fi

# Debian/Ubuntu install bat and fd under different names
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && ! command -v fd  >/dev/null 2>&1 && alias fd='fdfind'

# top: htop/btop if present ('top -c' means something else on macOS)
if command -v btop >/dev/null 2>&1; then alias t='btop'
elif command -v htop >/dev/null 2>&1; then alias t='htop'
else alias t='top -c'; fi

# psg PATTERN: search processes (portable; 'ps faux' is GNU-only)
# shellcheck disable=SC2009  # pgrep -a is Linux-only
psg() { ps -eo pid,user,etime,args | grep -i -- "$1" | grep -v -- 'grep -i'; }

# ---------------------------------------------------------------------------
# git
# ---------------------------------------------------------------------------
alias gst='git status'
alias glo='git log'
alias gci='git commit'
alias gcia='git commit -a'
alias gco='git checkout'
alias gsw='git switch'
alias grs='git restore'
alias gbr='git branch'
alias gdi='git diff'
alias gdica='git diff --cached'
alias gdiw='git diff -w'
alias gdt='git difftool'
alias gdtca='git difftool --cached'
alias gma='git ma'      # switch to the repo's default branch (main/master), see git config
alias gitl='git l'
alias gitll='git ll'    # was 'log --abbrev-commit --stat' (missing "git")

# Tab completion for `g` and the git aliases. git's completion is lazy-loaded
# by bash-completion, so load it first if needed.
if ! declare -F __git_complete >/dev/null && declare -F _completion_loader >/dev/null; then
  _completion_loader git 2>/dev/null
fi
if declare -F __git_complete >/dev/null; then
  __git_complete g    __git_main
  __git_complete gco  _git_checkout
  __git_complete gsw  _git_switch
  __git_complete gbr  _git_branch
  __git_complete gdi  _git_diff
  __git_complete glo  _git_log
fi
