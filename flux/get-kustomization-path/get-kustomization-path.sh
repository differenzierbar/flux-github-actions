#!/bin/bash
set -e

kustomization_file=$1
[[ ! -z $2 ]] && query="and $2"

#FIXME error or warning on multiple results ?
yq -N eval '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2" '"$query"') | .spec.path' "$kustomization_file"

