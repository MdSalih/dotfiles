export TERM=xterm-256color
export EDITOR=vi
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

source $HOME/.aliases
source $HOME/.git-completion.bash
source $HOME/.git-prompt.sh
source $HOME/.bash_prompt

shopt -s histappend # append to bash hist file, instead of overwritting
shopt -s cdspell # auto correct typos in cd

export TREE_CHARSET=ascii
