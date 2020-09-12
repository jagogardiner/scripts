#!/bin/bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#

# Install packages
command -v pacman > /dev/null
if [[ $? != 1 ]]; then
        # The OS have pacman, it is probably Arch!
	sudo pacman -S zsh adb fastboot curl git code neofetch iwd dhcpcd gnome-terminal lightdm gnome-backgrounds lightdm-gtk-greeter telegram-desktop ttf-opensans inetutils

        # Install aurpkg
        git clone --depth=1 https://aur.archlinux.org/aurpkg.git /tmp/aurpkg
        cd /tmp/aurpkg
        makepkg -si
        cd ~

        # Install Google Chrome
        aurpkg -S google-chrome

else
        # Apart from Arch, We only do Debian/Ubuntu.
	sudo apt-get -y install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gnupg2 gperf imagemagick lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev zsh apt-utils
fi

# Run oh-my-zsh installer unatteneded
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Clone in my aliases
git clone https://github.com/nysascape/aliases ~/.aliases
echo "source ~/.aliases/aliases" >> ~/.zshrc

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Add zsh plugins
sed -i 's/plugins=(git)/plugins=(git cp gpg-agent)/g' ~/.zshrc

# Git configurations
git config --global user.name "nysascape"
git config --global user.email "jago@nysascape.tech"
git config --global credential.helper store
git config --global commit.gpgsign true
git config --global user.signingkey "A15571E738CE3CD4"

# GCC 9 is always a good thing to have
git clone https://github.com/arter97/arm64-gcc --depth=1 ~/gcc9
git clone https://github.com/arter97/arm32-gcc --depth=1 ~/gcc932

# Add my hooks
git clone https://github.com/nysascape/githooks ~/.git/hooks/
git config --global core.hooksPath ~/.git/hooks
