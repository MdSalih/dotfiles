#!/bin/bash
die () {
	echo 1>&2 "$@"
	exit 1
}

# Check first argument, expect path to dotfiles
[ "$#" -eq 1 ] || die "Expected 1 argument - dotfiles path. eg. ~/.dotfiles"
dfpath=$1 
[ -d $dfpath ] || die "Invalid dotfiles path - directory [ $dfpath ] doesn't exist"
echo "Using [ $dfpath ] as dotfiles path";

# Backup existing files
echo "Backing up existing dotfiles/settings"
files=( ".screenrc" ".vimfiles" ".vimrc" ".aliases" ".gitconfig" ".gitignore" ".bash_profile" ".git-completion.bash" ".git-prompt.sh" ".bash_prompt")
ts=`date +%s`
for i in "${files[@]}"; do 
	if [ -e $HOME/$i ]; then
		echo -e "\t Backing up file $HOME/$i"
		mv $HOME/$i $HOME/$i.$ts || die "Could not move files $HOME/$i to $HOME/$i.$ts"
	else
		echo -e "\t File doesn't currently exist: $HOME/$i"
	fi
done
echo "Completed backing up files"

# Setup symlinks
echo "Setting up symlinks"
for i in "${files[@]}"; do 
	echo -e "\t Symlinking: ln -s $dfpath/$i $HOME/$i"
	ln -s $dfpath/$i $HOME/$i
done
echo "Completed setting up symlinks"

# Load .bash_profile from .bashrc
echo "Attempting to load .bash_profile from .bash_rc"
if grep -q "source ~/.bash_profile" $HOME/.bashrc 2>/dev/null; then
	echo -e "\t bashrc already loading bash_profile"
else
	echo "source ~/.bash_profile" >> $HOME/.bashrc
	echo -e "\t bashrc is now loading bash_profile"
fi

# Source new .bash_profile
echo "Sourcing new .bash_profile"
. ~/.bash_profile

echo "All done"
