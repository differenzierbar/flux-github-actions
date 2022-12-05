#!/bin/bash
set -e

kustomization_file=$1
[[ ! -z $2 ]] && query="and $2"

#FIXME error or warning on multiple results ?
result=$(yq -N eval '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2" '"$query"') | .spec.path' "$kustomization_file")

kustomization_root=$(dirname $kustomization_file)
# >&2 echo "---------------------kustomization-path: ${result[@]/#/$kustomization_root/}"
echo "${result[@]/#/$kustomization_root/}"

