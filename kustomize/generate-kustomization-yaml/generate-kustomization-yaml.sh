#!/bin/bash

set -e
path="$(readlink -f "$1")"
if [[ ! -f "$path/kustomization.yaml" ]]; then
    echo "generating $path/kustomization.yaml"
    pushd $path
    kustomize create --autodetect --recursive
    cat kustomization.yaml
    popd
fi
