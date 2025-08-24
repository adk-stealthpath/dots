#!/bin/bash

source $DOTDIR/src/*

if ! command -v zsh; then
    sudo apt install zsh
else 
    __info "zsh already installed"
fi

export ZDOTDIR="$DOTDIR/01-zsh"
export ZSH="$DOTDIR/01-zsh/oh-my-zsh"

if ! [ -d "$(pwd)/oh-my-zsh" ]; then 
    git clone gh:ohmyzsh/ohmyzsh.git $ZSH
else
    __info "oh-my-zsh already installed"
fi
