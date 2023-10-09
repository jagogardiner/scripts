#!/bin/bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#

# Clone in my aliases
git clone https://github.com/nysascape/aliases ~/.aliases
echo "source ~/.aliases/aliases" >> ~/.zshrc

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Add zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sed -i 's/plugins=(git)/plugins=(git cp gpg-agent ssh-agent zsh-syntax-highlighting zsh-autosuggestions sudo)/g' ~/.zshrc

# Git configurations
git config --global user.name "Jago Gardiner"
git config --global user.email "jagogardiner@gmail.com"
git config --global credential.helper store
git config --global commit.gpgsign true
git config --global user.signingkey "4F0F91DBC451CA96"
git config --global core.editor nano

# Add my hooks
git clone https://github.com/nysascape/githooks ~/.git/hooks/
git config --global core.hooksPath ~/.git/hooks
