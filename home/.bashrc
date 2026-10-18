# ~/.bashrc: interactive bash shells (also sourced from ~/.bash_profile for login shells).

# Non-interactive (scp, rsync, `ssh host cmd`): do nothing. Output here breaks scp.
case $- in *i*) ;; *) return ;; esac
__DOTFILES_BASHRC_LOADED=1

DOTFILES_BASH_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/bash
# (not 'have': bash-completion defines and then unsets a function with that name)
__dotfiles_have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH

# Do NOT export TERM here: the terminal emulator / tmux sets it correctly.
if __dotfiles_have vim; then export EDITOR=vim; else export EDITOR=vi; fi
export VISUAL=$EDITOR
export PAGER=less
export LESS='-RFi'          # colours, quit if one screen, smart-case search
export TREE_CHARSET=ascii

# ---------------------------------------------------------------------------
# History: big, timestamped, shared between concurrent shells
# ---------------------------------------------------------------------------
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups   # ignoreboth = ignorespace + ignoredups
HISTIGNORE='ls:ll:la:cd:cd -:pwd:exit:date:* --help'
HISTTIMEFORMAT='%F %T  '
shopt -s histappend cmdhist checkwinsize cdspell
# append each command to $HISTFILE as soon as it finishes (appended so $? is preserved for the prompt)
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a"

# ---------------------------------------------------------------------------
# Completion: use the system's bash-completion (ships an up-to-date git completion)
# ---------------------------------------------------------------------------
if ! shopt -oq posix; then
  for f in /usr/share/bash-completion/bash_completion \
           /etc/bash_completion \
           "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh" \
           /usr/local/etc/profile.d/bash_completion.sh; do
    if [ -r "$f" ]; then . "$f"; break; fi
  done
fi

# git-prompt.sh (provides __git_ps1) from the installed git, wherever the OS puts it
if ! declare -F __git_ps1 >/dev/null; then
  for f in /usr/lib/git-core/git-sh-prompt \
           /usr/share/git-core/contrib/completion/git-prompt.sh \
           /usr/share/git/completion/git-prompt.sh \
           "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/bash_completion.d/git-prompt.sh" \
           /Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh; do
    if [ -r "$f" ]; then . "$f"; break; fi
  done
fi
unset f

# ---------------------------------------------------------------------------
# Optional tools (each one is skipped if not installed)
# ---------------------------------------------------------------------------
if __dotfiles_have fzf; then
  # fzf >= 0.48 can print its own integration; fall back to the ~/.fzf installer file
  eval "$(fzf --bash 2>/dev/null)" || { [ -r ~/.fzf.bash ] && . ~/.fzf.bash; }
  __dotfiles_have fd && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  __dotfiles_have fdfind && ! __dotfiles_have fd && export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
elif [ -r ~/.fzf.bash ]; then
  . ~/.fzf.bash
fi
__dotfiles_have zoxide && eval "$(zoxide init bash)"
__dotfiles_have direnv && eval "$(direnv hook bash)"

# Ansible: readable YAML task output (replaces the removed `yaml` stdout callback)
export ANSIBLE_CALLBACK_RESULT_FORMAT=yaml

# nvm (only if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# kdb+/q (only if installed on this host)
if [ -d "$HOME/apps/kdb/current" ]; then
  export QHOME=$HOME/apps/kdb/current
  if __dotfiles_have rlwrap; then alias q='rlwrap -r "$QHOME/q"'; else alias q='"$QHOME/q"'; fi
fi

# ---------------------------------------------------------------------------
# Aliases, prompt, local overrides
# ---------------------------------------------------------------------------
[ -r "$DOTFILES_BASH_DIR/aliases.bash" ] && . "$DOTFILES_BASH_DIR/aliases.bash"
[ -r "$DOTFILES_BASH_DIR/prompt.bash" ]  && . "$DOTFILES_BASH_DIR/prompt.bash"
[ -r "$HOME/.bashrc.local" ]             && . "$HOME/.bashrc.local"   # not in git
true
