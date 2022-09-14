#!/bin/bash

set -e
path="$(readlink -f "$1")"
if [[ ! -f "$path/kustomization.yaml" ]]; then
    pushd $path
    # FIMXE recursive find yaml files
    kustomize create --autodetect --recursive
    popd
fi
