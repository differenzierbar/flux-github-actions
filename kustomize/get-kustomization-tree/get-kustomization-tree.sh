#!/bin/bash
set -e

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

kustomization_yml_find_pattern=".*/(Kustomization|kustomization\.ya?ml)$"

kustomization_root="$1"
kustomization_directory="$2"

>&2 echo "root_directory: $kustomization_root"
>&2 echo "kustomization_directory: $kustomization_directory"
>&2 echo "separator: '$separator'"

kustomization_yaml()
{
    kustomization_root="$1"
    kustomization_directory="$2"

    # >&2 echo "(child) kustomization_directory: $kustomization_directory"

    # >&2 echo "looking for kustomization.yaml in $kustomization_root/$kustomization_directory"
    kustomization_yml_find_result=($(find $kustomization_root/$kustomization_directory -maxdepth 1 -type f -regextype posix-extended -regex "$kustomization_yml_find_pattern"))

    if [ ${#kustomization_yml_find_result[@]} -gt 1 ]; then
        >&2 echo "Error: Found multiple kustomization files under: $kustomization_root/$kustomization_directory"
        exit 1
    elif [[ ${#kustomization_yml_find_result[@]} -eq 1 ]]; then
        result=()
        while IFS= read -r resource; do
            # >&2 echo "checking: $kustomization_root/$kustomization_directory/$resource"
            if [[ -d "$kustomization_root/$kustomization_directory/$resource" ]]; then
                # directory
                child_result=$(kustomization_yaml $kustomization_root "$kustomization_directory/$resource")
                # >&2 echo "child_result: $child_result"
                result+=($child_result)
            fi
        done <<<$(yq e -o=j -I=0 '.resources[]' "$kustomization_root/$kustomization_directory/kustomization.yaml" | tr -d \")
        kustomization_yaml_path="$(realpath --relative-to $kustomization_root $kustomization_root/$kustomization_directory/kustomization.yaml)"
        # >&2 echo "kustomization.yaml changed: $kustomization_yaml_path"
        result+=($kustomization_yaml_path)
        echo ${result[@]}
    else
        >&2 echo "Error: Found no kustomization files under: $kustomization_root"
        exit 1
    fi
}

result=()

# >&2 echo "looking for kustomization.yaml in $kustomization_root/$kustomization_directory"
kustomization_yml_find_result=($(find $kustomization_root/$kustomization_directory -maxdepth 1 -type f -regextype posix-extended -regex "$kustomization_yml_find_pattern"))

if [ ${#kustomization_yml_find_result[@]} -gt 1 ]; then
    >&2 echo "Error: Found multiple kustomization files under: $kustomization_root"
    exit 1
elif [[ ${#kustomization_yml_find_result[@]} -eq 1 ]]; then
    # validate the existing kustomization tree recursively
    child_result=($(kustomization_yaml $kustomization_root $kustomization_directory)) # visited
    # >&2 echo "child_result: ${child_result[@]}"

    result+=(${child_result[@]})
    # >&2 echo "result1: ${result[@]}"
else
    # kustomization.yaml will be autogenerated by flux
    >&2 echo "no kustomization.yaml found - assuming autogeneration"
    result+=($kustomization_directory)

fi

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs






