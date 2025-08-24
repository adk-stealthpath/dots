#!/bin/bash

__title "AutoRandr"
if ! command -v audorandr; then 
    sudo apt install autorandr -y
    __info "Installed autorandr"
else 
    __info "AutoRandr already installed"
fi
