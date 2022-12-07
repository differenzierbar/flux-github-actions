#!/bin/bash
set -e

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

kustomization_yml_find_pattern=".*/(Kustomization|kustomization\.ya?ml)$"

kustomization_yml_dir="$1"
kustomization_root="${2:-$(dirname $kustomization_yml_dir)}"


>&2 echo "kustomization_yml_dir=$kustomization_yml_dir"
>&2 echo "kustomization_root=$kustomization_root"

kustomization_yml_find_result=($(find $kustomization_yml_dir -maxdepth 1 -type f -regextype posix-extended -regex "$kustomization_yml_find_pattern"))
>&2 echo "kustomization_yml_find_result: $kustomization_yml_find_result"

if [ ${#kustomization_yml_find_result[@]} -gt 1 ]; then
    >&2 echo "Error: Found multiple kustomization files under: $kustomization_yml_dir"
    exit 1
elif [[ ${#kustomization_yml_find_result[@]} -eq 1 ]]; then
    result=()

    while IFS= read -r resource; do
        if [[ ! -d "$kustomization_yml_dir/$resource" ]]; then
            # result+=("$kustomization_root/$resource")
            result+=("$(realpath --relative-to $kustomization_root "$kustomization_yml_dir/$resource")")
        fi
    done <<<$(yq e -o=j -I=0 '.resources[]' "${kustomization_yml_find_result}" | tr -d \")

else
    # kustomization.yaml will be autogenerated by flux
    >&2 echo "no kustomization.yaml found - assuming autogeneration"
    result+=($(find $kustomization_yml_dir -regex ".*.ya?ml$" -exec realpath --relative-to $kustomization_root {} \;))
fi

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs
# kustomization_root=$(dirname $kustomization_yml)

