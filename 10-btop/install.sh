#!/bin/bash

__title "Btop"
if ! command -v btop; then 
    sudo apt install btop
    __info "Installed btop"
else 
    __info "btop already installed. Skipping..."
fi
