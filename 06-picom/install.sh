#!/bin/bash

source $DOTDIR/src/*

if ! command -v picom; then
    __info "installing picom"
    sudo apt install -y picom
else 
    __info "picom already installed"
fi
