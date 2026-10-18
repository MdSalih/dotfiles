# ~/.bash_profile: read by bash LOGIN shells only (ssh, tmux panes, macOS Terminal).
# Keep it thin: everything interactive lives in ~/.bashrc.

# Once ~/.bash_profile exists bash stops reading ~/.profile, which is where
# Debian/Ubuntu put PATH additions (~/.local/bin, ~/bin). Keep reading it.
if [ -r "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# Ubuntu's ~/.profile already sources ~/.bashrc; don't load it twice.
if [[ $- == *i* && -z ${__DOTFILES_BASHRC_LOADED-} && -r $HOME/.bashrc ]]; then
  . "$HOME/.bashrc"
fi
