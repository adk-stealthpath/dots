#!/usr/bin/zsh
# Path to your oh-my-zsh installation.
export ZSH="/home/akingston/.config/zsh/oh-my-zsh"
export ZSH_CUSTOM="/home/akingston/.config/zsh/oh-my-zsh"
export ZDOTDIR="/home/akingston/.config/zsh"
export PATH=$HOME/.local/bin:$PATH
# You may need to manually set your language environment
export LANG=en_US.UTF-8
#
# Go environment 
export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH:$HOME/.local/go/bin

# Rust environment 
export PATH=$HOME/.cargo/bin:$PATH
export CARGO_TARGET_DIR=$HOME/.cargo/bin

# useful environment vars 
export SHELL=/usr/bin/zsh
export EDITOR=nvim

# modular mojo 
export MODULAR_HOME="/home/akingston/.modular"
export PATH="/home/akingston/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

# local environment 
export SUBDOMAIN="adk"

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# k8s kubeconfig 
export KUBECONFIG=/home/akingston/.kube/helmet/merged.yaml

# Claude
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
