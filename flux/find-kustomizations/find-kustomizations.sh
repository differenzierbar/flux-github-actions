#!/bin/bash
set -e

DEFAULT_SEPARATOR=' '

kustomizations_root=$1
query=$2
separator="${3:-$DEFAULT_SEPARATOR}"

>&2 echo "kustomizations_root: $kustomizations_root"
>&2 echo "query: $query"
>&2 echo "separator: '$separator'"

result=$(find $kustomizations_root -name "*.yml" -exec yq -N eval '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2" and ('$query') ) | filename + "?metadata.name==\"" + .metadata.name + "\""' {} +)
# >&2 echo "result inner: ${result[@]}"
echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | sed 's/ *$//g'

