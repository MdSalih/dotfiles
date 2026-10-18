# dotfiles

bash, git, tmux, vim (and screen) configuration. Neovim lives in its own repo
([MdSalih/kickstart.nvim](https://github.com/MdSalih/kickstart.nvim)), and `--nvim` clones it.

## Requirements

- bash 3.2+ (macOS default) or 4+/5+, git 2.38+, tmux 3.2+, Vim 9 (8.2 works without LSP)
- `curl`, needed only for `--plugins`
- Optional, picked up when installed: `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`,
  `direnv`, `delta`, `starship`, `rlwrap`, `bash-completion`

## Install

```bash
git clone https://github.com/MdSalih/dotfiles.git ~/git/dotfiles
~/git/dotfiles/bootstrap.sh -n          # dry run: shows what would change
~/git/dotfiles/bootstrap.sh --plugins   # link files and install Vim plugins
```

`bootstrap.sh` symlinks every file under `home/` to the same path in `$HOME`.
Anything already in the way is moved to `~/.local/state/dotfiles/backup/<timestamp>/`
(nothing is deleted), and you can run it again safely. The layout also works with GNU Stow:
`stow --no-folding -d ~/git/dotfiles -t ~ home`.

## Layout

```
home/.bash_profile               login shells: reads ~/.profile, then ~/.bashrc
home/.bashrc                     interactive shell: env, history, completion, tools
home/.config/bash/aliases.bash
home/.config/bash/prompt.bash    "user at host in dir on branch" prompt using __git_ps1
home/.config/git/config          + ignore
home/.config/tmux/tmux.conf
home/.vim/vimrc
home/.screenrc
config.local.example             template for ~/.config/git/config.local
test/run.sh                      lint + smoke tests (also run in CI)
```

## Machine-specific settings (not tracked)

| File | For |
|---|---|
| `~/.bashrc.local` | extra PATH entries, work aliases, `DOTFILES_PROMPT=starship` |
| `~/.config/git/config.local` | credential helper, signing key, delta, work identity |
| `~/.config/tmux/local.conf` | per-host tmux tweaks |
| `~/.vim/vimrc.local` | per-host Vim tweaks |

## Credits

The prompt was originally based on [twolfson/sexy-bash-prompt](https://github.com/twolfson/sexy-bash-prompt) (MIT).
Git completion and prompt now come from the system's git package, so they are no longer vendored.
