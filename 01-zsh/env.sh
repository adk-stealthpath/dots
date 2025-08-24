#!/usr/bin/zsh
# Path to your oh-my-zsh installation.
export ZSH="/home/akingston/.config/zsh/oh-my-zsh"
export ZSH_CUSTOM="/home/akingston/.config/zsh/oh-my-zsh"
export ZDOTDIR="/home/akingston/.config/zsh"
export KUBECONFIG=/home/akingston/.kube/k0s/config.yaml
export PATH=$HOME/.local/bin:$PATH
# You may need to manually set your language environment
export LANG=en_US.UTF-8
#
# Go environment 
export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:/usr/local/go/bin:$PATH

# Rust environment 
# export PATH=$HOME/.cargo/bin:$PATH

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
export KUBECONFIG="/opt/k8s-kubeconfig/.kube/k0s/merged.yaml"
