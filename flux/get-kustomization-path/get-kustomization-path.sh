#!/bin/bash
set -e

kustomization_file=$1
[[ ! -z $2 ]] && query="and $2"

# >&2 echo "kustomization_file: $kustomization_file"
# >&2 echo "query: $query"

#FIXME error or warning on multiple results ?
result=$(yq -N eval '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2" '"$query"') | .spec.path' "$kustomization_file")
# >&2 echo "result: $result"
echo $result
# echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs


