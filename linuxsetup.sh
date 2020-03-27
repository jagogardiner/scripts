#!/bin/bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#
# Let's install some packages
if [[ "$*" =~ "arch"* ]]; then
	sudo pacman -S zsh adb fastboot curl git code neofetch iwd dhcpcd gnome-terminal lightdm gnome-backgrounds lightdm-gtk-greeter telegram-desktop ttf-opensans
else
	sudo apt-get -y install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev zsh
fi

# Run oh-my-zsh installer unatteneded
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Setup Pure ZSH theme
mkdir -p "$HOME/.zsh"
git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
echo 'fpath+=("$HOME/.zsh/pure")' >> ~/.zshrc
echo 'autoload -U promptinit; promptinit' >> ~/.zshrc
echo 'prompt pure' >> ~/.zshrc

# Clone in my aliases
git clone https://github.com/nysascape/aliases ~/.aliases
echo "source ~/.aliases/aliases" >> ~/.zshrc

# Git configurations
git config --global user.name "nysascape"
git config --global user.email "jago@nysascape.digital"
git config --global credential.helper store
git config --global commit.gpgsign true
git config --global user.signingkey "A15571E738CE3CD4"

# GCC 9 is always a good thing to have
git clone https://github.com/arter97/arm64-gcc --depth=1 ~/gcc9
git clone https://github.com/arter97/arm32-gcc --depth=1 ~/gcc932

# Add my hooks
git clone https://github.com/nysascape/githooks ~/.git/hooks/
git config --global core.hooksPath ~/.git/hooks

# Change shell to ZSH
chsh -s "$zsh"

# Arch stuff
if [[ "$*" =~ "arch"* ]]; then
	# Install aurpkg
	git clone --depth=1 https://aur.archlinux.org/aurpkg.git /tmp/aurpkg
	cd /tmp/aurpkg
	makepkg -si
	cd ~

	# Install Google Chrome
	aurpkg -S google-chrome
fi

