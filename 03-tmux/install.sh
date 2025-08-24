#!/bin/bash

source $DOTDIR/src/*

if ! command -v tmux; then
    __info "installing tmux"
    sudo apt install -y tmux
    git clone https://github.com/tmux-plugins/tpm $DOTDIR/03-tmux/tpm
    bash $DOTDIR/03-tmux/tpm/plugins/tpm/bin/install_plugins
else 
    __info "tmux already installed"
fi



