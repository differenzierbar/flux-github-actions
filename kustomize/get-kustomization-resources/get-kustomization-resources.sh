#!/bin/bash
set -e

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

kustomization_yml="$1"
kustomization_yml_dir=$(dirname $kustomization_yml)
kustomization_root="${2:-$(dirname $kustomization_yml)}"

>&2 echo "kustomization_yml=$kustomization_yml"
>&2 echo "kustomization_root=$kustomization_root"

result=()

# kustomization_root=$(dirname $kustomization_yml)

while IFS= read -r resource; do
    if [[ ! -d "$kustomization_yml_dir/$resource" ]]; then
        # result+=("$kustomization_root/$resource")
        result+=($(realpath --relative-to $kustomization_root "$kustomization_yml_dir/$resource"))
    fi
done <<<$(yq e -o=j -I=0 '.resources[]' "${kustomization_yml}" | tr -d \")

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs
