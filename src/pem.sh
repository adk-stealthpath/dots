#!/bin/bash

__get_pem() {
    local id = $1
    local dst = $2
    local idx = $3
    bw get item $id |\
        jq ".fields[$idx].value" -r |\
        sed 's/\(-----BEGIN[^-]*-----\)\(.*\)\(-----END[^-]*-----\)/\1\2\3/' |\
        sed 's/\([^-]\{64\}\)/\1/g' > $dst


