#!/bin/bash

source $DOTDIR/src/*

if ! command -v go; then
    version=$(curl -s https://go.dev/VERSION\?m\=text | head -n 1)
    __info "installing $version"
    wget "https://dl.google.com/go/$version.linux-amd64.tar.gz"
    tar -C /usr/local -xzf $version.linux-amd64.tar.gz
    __debug "installed $version"
else 
    __info "go already installed: $(go version)"
fi

__info "installing necessary go packages"
__debug "gofumpt"
go install mvdan.cc/gofumpt@latest
__debug "golines"
go install github.com/segmentio/golines@latest
__debug "goimports"
go install golang.org/x/tools/cmd/goimports@latest
__debug "gorename"
go install golang.org/x/tools/cmd/gorename@latest
__debug "gomodifytags"
go install github.com/fatih/gomodifytags@latest
__debug "gotests"
go install github.com/cweill/gotests/gotests@latest
__debug "iferr"
go install github.com/koron/iferr@latest
__debug "impl"
go install github.com/josharian/impl@latest
__debug "fillstruct"
go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
__debug "fillswitch"
go install github.com/davidrjenni/reftools/cmd/fillswitch@latest
__debug "dlv"
go install github.com/go-delve/delve/cmd/dlv@latest
__debug "ginkgo"
go install github.com/onsi/ginkgo/v2/ginkgo@latest
__debug "gotestsum"
go install gotest.tools/gotestsum@latest
__debug "govulncheck"
go install golang.org/x/vuln/cmd/govulncheck@latest
__debug "enumer"
go install github.com/dmarkham/enumer@latest
__debug "gopls"
go install golang.org/x/tools/gopls@latest
__debug "mage"
go install github.com/magefile/mage@latest
__debug "k0sctl"
go install github.com/k0sproject/k0sctl@latest
__debug "k9s"
go install github.com/derailed/k9s@latest
__debug "cosign"
go install github.com/sigstore/cosign/v2/cmd/cosign@latest
