#!/bin/bash
set -e

kustomizations_root=$1
flux_kustomization_files=$(find $kustomizations_root -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | filename' {} +)

IFS=" " read -r -a flux_kustomization_files <<< "$(echo "${flux_kustomization_files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
echo ${flux_kustomization_files[@]}
