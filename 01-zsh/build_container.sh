#!/usr/bin/zsh

boundary () {
    str=$1
    addtnl=$2

    printf '=%.0s' $(seq 1 $((${#str} + $addtnl))); echo
}

verify_yubikey() {
    echo "Touch your Yubikey..."

    challenge=$(openssl rand -hex 32)
    if ! response=$(ykchalresp -2 "$challenge" 2>/dev/null); then
        echo "ERROR: Yubikey verification failed"
        return 1
    fi 
    echo "Yubikey authenticated. I hope you know what you're doing :)"
}

build() {
    domain=$1
    tag=$2
    if [[ -z $domain ]]; then
        domain="zot.adk.stealthpathdev.com/images"
    elif [[ $domain != "239829075165.dkr.ecr.us-east-1.amazonaws.com" ]]; then
        domain=$domain.stealthpathdev.com/images
    fi

    if [[ -z $tag ]]; then
        tag=latest
    fi
    git rev-parse --show-toplevel
    src=$(git rev-parse --show-toplevel)

    TAG=$domain/$(basename `pwd`):$tag
    # TAG=$domain/$(basename `pwd`):$tag
    boundary $TAG 18
    echo "=====> TAG=$TAG <====="
    echo "==> source=$src =="
    boundary $TAG 18
    echo ""

    # yubikey authentication before AWS build, push, and sign
#    if [[ $domain == *"amazonaws"* ]]; then 
#        echo "AWS build detected. Yubikey verification reqruied."
#        if ! verify_yubikey; then
#            return 1
#        fi
#    fi

    podman build -t $TAG -f Dockerfile $src
    podman push $TAG
    cosign sign -y --tlog-upload=false --key awskms:///arn:aws:kms:us-east-1:239829075165:alias/eagle5-cosign-key $TAG
    cosign verify --insecure-ignore-tlog --key awskms:///arn:aws:kms:us-east-1:239829075165:alias/eagle5-cosign-key $TAG
}

