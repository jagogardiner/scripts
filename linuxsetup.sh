#!/bin/bash

# Clone in my aliases
git clone https://github.com/jagogardiner/aliases ~/.aliases
echo "source ~/.aliases/aliases" >> ~/.zshrc
echo "source ~/.aliases/hidden" >> ~/.zshrc

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Add zsh plugins and configure theme
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sed -i 's/plugins=(git)/plugins=(git cp sudo ssh-agent zsh-syntax-highlighting zsh-autosuggestions)/g' ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# Git configurations
git config --global user.name "Jago Gardiner"
git config --global core.editor nano
git config --global push.autoSetupRemote true
