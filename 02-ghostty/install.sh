#!/bin/bash

__title "Ghostty"
if ! command -v ghostty; then
    __info "Pulling Ghostty deb"
    wget https://github.com/mkasberg/ghostty-ubuntu/releases/download/1.1.3-0-ppa2/ghostty_1.1.3-0.ppa2_amd64_24.04.deb
    sudo dpkg -i ghostty_1.1.3-0.ppa2_amd64_24.04.deb
    
    rm ghostty_1.1.3-0.ppa2_amd64_24.04.deb
    __info "Installed Ghostty"
else 
    __info "Ghostty already installed. Skipping..."
fi
