#!/bin/bash
set -e

kustomizations_root=$1
flux_kustomization_files=$(find $kustomizations_root -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | filename' {} +)

result=()
while IFS= read -r kustomization_file; do
    result+=($(yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' "$kustomization_file"))
done <<< "${flux_kustomization_files}"

IFS=" " read -r -a result <<< "$(echo "${result[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
echo ${result[@]}





