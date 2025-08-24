#!/bin/bash

source $DOTDIR/src/*

if ! command -v rofi; then 
    __info "installing rofi"
    sudo apt install -y rofi
else
    __info "rofi already installed"
fi
