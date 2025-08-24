#!/bin/bash

source $DOTDIR/src/*

__info "Installing network manager and l2tp plugin"
sudo apt install -y network-manager network-manager-l2tp network-manager-pptp
__info "Disabling networkd"
sudo systemctl disable systemd-networkd
sudo systemctl --global mask systemd-networkd


_dst=/etc/netplan
_item_id="0f3515de-9726-4868-b3a7-b34301447d7c"
_system_network_id="yea9rlst9a5ojcgr7p8p3xi71nf6uu5f"
_vpn_id="xi1lmkvkoxx2h4qm5kktvkouqumqaspc"

export BW_SESSION=$(bw unlock --raw)

bw get attachment $_system_network_id --itemid $_item_id --output /tmp/00-system.yaml --session $BW_SESSION
sudo mv /tmp/00-system.yaml /etc/netplan

bw get attachment $_vpn_id --itemid $_item_id --output /tmp/10-sp-vpn.yaml --session $BW_SESSION
sudo mv /tmp/10-sp-vpn.yaml /etc/netplan

sudo netplan apply
