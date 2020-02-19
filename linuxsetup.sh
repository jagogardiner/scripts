#!/bin/bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#
# Script for my Arch installs. Designed to be ran straight after the first reboot (although there's probably stuff I missed!!!)

# Install a bunch of packages I use
sudo pacman -S zsh adb fastboot curl git code neofetch iwd dhcpcd i3 i3status dmenu i3lock feh conky rofi scrot gnome-terminal lightdm gnome-backgrounds lightdm-gtk-greeter telegram-desktop ttf-opensans

# Enable a few systemd processes
sudo systemctl enable iwd
sudo systemctl enable lightdm
sudo systemctl enable dhcpcd

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install aurpkg
git clone --depth=1 https://aur.archlinux.org/aurpkg.git /tmp/aurpkg
cd /tmp/aurpkg
makepkg -s
git clone --depth=1 https://aur.archlinux.org/aurpkg.git
cd ~

# Install Google Chrome
aurpkg -S google-chrome

# Setup i3
rm -rf ~/.config/i3 # incase i3 config already exists
git clone https://github.com/nysascape/dotfiles ~/dotfiles
mv ~/dotfiles/i3 ~/.config/i3

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
git config --global user.email "nysadev@raphielgang.org"
git config --global credential.helper store

# GCC 9 is always a good thing to have
git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x --depth=1 ~/gcc9
git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 ~/gcc932

# Repo (thanks to LineageOS)
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Source our zshrc just so our aliases take effect
source ~/.zshrc

# Add the Gerrit change-id hook
mkdir ~/.git/hooks
git config --global core.hooksPath ~/.git/hooks
curl -Lo ~/.git/hooks/commit-msg https://review.aosip.dev/tools/hooks/commit-msg
chmod u+x ~/.git/hooks/commit-msg
