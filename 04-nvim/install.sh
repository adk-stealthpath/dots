#!/bin/bash

source $DOTDIR/src/*


if ! command -v nvim; then
    __info "neovim not found - installing"
    _build_dir=$HOME/from_src

    sudo apt-get install -y ninja-build gettext cmake build-essential 
    git clone https://github.com/neovim/neovim $_build_dir/neovim

    pushd $_build_dir/neovim

    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install

    popd

    __info "successfully installed neovim"
    __info "installing packer"
    git clone --depth 1 https://github.com/wbthomason/packer.nvim\
        ~/.local/share/nvim/site/pack/packer/start/packer.nvim
    __info "successfully installed packer"
    __info "installing plugins"
    nvim --headless -c "PackerInstall" -c "qa"
    __info "successfully installed plugins"
else 
    __info "neovim already installed $(nvim -v | grep NVIM)"
fi


