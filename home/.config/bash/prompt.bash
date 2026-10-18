# ~/.config/bash/prompt.bash (sourced by ~/.bashrc)
# shellcheck shell=bash disable=SC2034  # GIT_PS1_* are read by __git_ps1
#
# Same look as the old sexy-bash-prompt:
#   user at host in ~/dir on main *=
#   $
# but built on git's own __git_ps1 (upstream-aware, 1-3 git calls instead of ~9,
# no hard-coded "origin", no substring branch matching). Exit status is shown in red.
#
# Set DOTFILES_PROMPT=starship in ~/.bashrc.local to use starship instead (if installed).

if [[ ${DOTFILES_PROMPT-} == starship ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
  return 0
fi

GIT_PS1_SHOWDIRTYSTATE=1        # * unstaged, + staged
GIT_PS1_SHOWSTASHSTATE=1        # $ stash present
GIT_PS1_SHOWUNTRACKEDFILES=     # % untracked: off (slow in big repos)
GIT_PS1_SHOWUPSTREAM=auto       # < behind, > ahead, <> diverged, = in sync
GIT_PS1_SHOWCONFLICTSTATE=yes   # |CONFLICT
GIT_PS1_DESCRIBE_STYLE=branch
GIT_PS1_HIDE_IF_PWD_IGNORED=1

__dotfiles_prompt() {
  local status=$?
  local r='\[\e[0m\]' b='\e[1m'
  local user="\[${b}\e[38;5;27m\]" prep="\[${b}\e[38;5;7m\]" host="\[${b}\e[38;5;39m\]"
  local dir="\[${b}\e[38;5;76m\]" git="\[${b}\e[38;5;154m\]" err="\[${b}\e[38;5;9m\]"
  [[ $EUID -ne 0 ]] || user="\[${b}\e[38;5;9m\]"     # root: red user name

  local pre="${user}\u${r} ${prep}at${r} ${host}\h${r} ${prep}in${r} ${dir}\w${r}"
  local post=$'\n'
  ((status)) && post+="${err}[${status}]${r} "
  post+="${b:+\[$b\]}\\\$${r} "

  if declare -F __git_ps1 >/dev/null; then
    __git_ps1 "$pre" "$post" " ${prep}on${r} ${git}%s${r}"
  else
    PS1="$pre$post"
  fi
}

PROMPT_COMMAND="__dotfiles_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
