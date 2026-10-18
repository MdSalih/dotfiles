#!/usr/bin/env bash
# Idempotent dotfiles installer: symlinks every file under ./home into $HOME,
# mirroring the directory structure. Safe to re-run; bash 3.2 (macOS) compatible.
#
#   ./bootstrap.sh            link files, backing up anything in the way
#   ./bootstrap.sh -n         dry run: print what would happen, change nothing
#   ./bootstrap.sh --plugins  also install vim-plug + Vim plugins
#   ./bootstrap.sh --nvim     also clone the Neovim config if ~/.config/nvim is missing
set -euo pipefail

DRY_RUN=0
DO_PLUGINS=0
DO_NVIM=0
NVIM_REPO=${NVIM_REPO:-https://github.com/MdSalih/kickstart.nvim.git}

usage() { sed -n '2,9s/^# \{0,1\}//p' "$0"; }
while [ $# -gt 0 ]; do
  case $1 in
    -n|--dry-run) DRY_RUN=1 ;;
    -p|--plugins) DO_PLUGINS=1 ;;
    --nvim)       DO_NVIM=1 ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
SRC_DIR=$REPO_DIR/home
[ -d "$SRC_DIR" ] || { echo "missing $SRC_DIR" >&2; exit 1; }
: "${HOME:?HOME is not set}"
BACKUP_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backup/$(date +%Y%m%d-%H%M%S)-$$

info() { printf '%s\n' "$*"; }
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

# Move $1 (file, dir or symlink - never followed) into the backup dir, keeping its path.
backup() {
  local target=$1 rel=${1#"$HOME"/}
  run mkdir -p "$(dirname -- "$BACKUP_DIR/$rel")"
  run mv -- "$target" "$BACKUP_DIR/$rel"
  info "  backup  ~/$rel -> $BACKUP_DIR/$rel"
}

link() {
  local src=$1 target=$2
  if [ -L "$target" ] && [ "$(readlink -- "$target")" = "$src" ]; then
    return 0                                     # already correct: nothing to do
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then  # -L also catches dangling links
    backup "$target"
  fi
  run mkdir -p "$(dirname -- "$target")"
  run ln -sn -- "$src" "$target"                 # -n: never descend into a dir symlink
  info "  link    ${target/#"$HOME"/\~} -> $src"
}

info "Dotfiles: $REPO_DIR -> $HOME$( [ "$DRY_RUN" -eq 1 ] && echo ' (dry run)')"

# 1. Retire files from the old layout that would shadow the new XDG locations
#    (~/.vimrc beats ~/.vim/vimrc, ~/.tmux.conf beats ~/.config/tmux/tmux.conf,
#    ~/.gitconfig overrides ~/.config/git/config). Symlinks are always moved;
#    real files are moved for vim/tmux, but only reported for .gitconfig
#    because tools like `gh auth setup-git` write credential helpers there.
for f in .vimrc .vimfiles .tmux.conf .aliases .bash_prompt .git-completion.bash \
         .git-prompt.sh .gitignore .gitconfig; do
  t=$HOME/$f
  if [ -L "$t" ]; then
    backup "$t"
  elif [ -e "$t" ]; then
    case $f in
      .gitconfig) info "  NOTE: ~/.gitconfig is a real file; it overrides ~/.config/git/config. Merge it into ~/.config/git/config.local and remove it." ;;
      .gitignore) info "  NOTE: ~/.gitignore is not read by git unless core.excludesFile points at it; global ignores now live in ~/.config/git/ignore." ;;
      *)          backup "$t" ;;
    esac
  fi
done

# 2. Link everything under ./home
while IFS= read -r -d '' src; do
  rel=${src#"$SRC_DIR"/}
  link "$src" "$HOME/$rel"
done < <(find "$SRC_DIR" \( -type f -o -type l \) -print0 | sort -z)

# 3. Optional: Vim plugins (only for real Vim; on some hosts `vim` is Neovim)
if [ "$DO_PLUGINS" -eq 1 ]; then
  if command -v vim >/dev/null 2>&1 && vim --version 2>/dev/null | head -n1 | grep -q '^VIM - Vi IMproved'; then
    plug=$HOME/.vim/autoload/plug.vim
    if [ ! -f "$plug" ]; then
      run curl -fsSLo "$plug" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    run vim -N -u "$HOME/.vim/vimrc" -i NONE -es +'PlugInstall --sync' +qall || info "  vim plugin install reported errors"
  else
    info "  skipping Vim plugins: 'vim' is missing or is not Vim (Neovim uses ~/.config/nvim)"
  fi
fi

# 4. Optional: Neovim config (kept in its own repo)
if [ "$DO_NVIM" -eq 1 ]; then
  if [ -e "$HOME/.config/nvim" ]; then
    info "  ~/.config/nvim already exists; leaving it alone"
  elif command -v git >/dev/null 2>&1; then
    run git clone --depth 1 "$NVIM_REPO" "$HOME/.config/nvim"
    if command -v nvim >/dev/null 2>&1; then
      run nvim --headless '+Lazy! sync' +qa || info "  nvim plugin sync reported errors"
    fi
  fi
fi

info 'Done. Machine-specific settings go in ~/.bashrc.local, ~/.config/git/config.local,'
info 'and in ~/.config/tmux/local.conf, ~/.vim/vimrc.local (none are tracked).'
[ -d "$BACKUP_DIR" ] && info "Backups: $BACKUP_DIR"
exit 0
