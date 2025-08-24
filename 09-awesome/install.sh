#!/bin/bash

__title "Awesome Window Manager"
__info "Installing window manager and display manager"
sudo apt install awesome sddm 
git clone gh:JaKooLit/simple-sddm.git 
sudo mv simple-sddm /usr/share/sddm/themes
echo '[Theme]\nCurrent=simple-sddm' | sudo tee /etc/ssdm.conf

__info "Handling sound"
sudo apt install -y pulseaudio pavucontrol alsa-utils pulsemixer

__info "Handling brightness"
sudo apt install -y brightnessctl

__info "Handling misc"
sudo apt install -y fonts-noto fonts-noto-color-emoji fonts-font-awesome libnotify-bin picom 

