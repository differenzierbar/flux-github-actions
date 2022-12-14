#!/bin/bash
set -e

here=`dirname $(realpath $0)`

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

kustomization="$1"
kustomization_root="${2:-$(dirname $kustomization)}"

>&2 echo "kustomization=$kustomization"
>&2 echo "kustomization_root=$kustomization_root"

parts=(${kustomization//\?/ })
filename=${parts[0]}
query=${parts[1]}
>&2 echo "filename: $filename"
>&2 echo "query: $query"

IFS="$separator" read -r -a kustomization_paths <<< $($here/../get-kustomization-path/get-kustomization-path.sh $filename ".$query")
>&2 echo "kustomization_paths: ${kustomization_paths[@]}"

IFS="$separator" read -r -a kustomization_tree <<< $($here/../../kustomize/get-kustomization-tree/get-kustomization-tree.sh $kustomization_root "${kustomization_paths[0]}")
>&2 echo "kustomization_tree: ${kustomization_tree[*]}"

result=()

while IFS= read -r kustomization_yaml; do
    if [[ -n "$kustomization_yaml" ]]; then
        >&2 echo "getting kustomization_resources from $kustomization_yaml"
        IFS="$separator" read -r -a kustomization_resources <<< $($here/../../kustomize/get-kustomization-resources/get-kustomization-resources.sh $kustomization_root/$kustomization_yaml $kustomization_root)
        >&2 echo "kustomization_resources: '${kustomization_resources[*]}'"
        # result+="${kustomization_resources[@]}"

        result=("${result[@]}" "${kustomization_resources[@]}")
        >&2 echo "result: ${result[@]}" 

        while IFS= read -r resource; do
            >&2 echo "resource ${resource}" 
        done < <(tr "$separator" '\n' <<< "${kustomization_resources[@]}")
    fi

done < <(tr "$separator" '\n' <<< "${kustomization_tree[@]}")

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs
