#!/bin/bash
set -e

here=`dirname $(realpath $0)`

# result=$($here/../find-kustomizations.sh $here/testdata "$query" "$separator")
# result_array=()

kustomizations=$($here/../flux/find-kustomizations/find-kustomizations.sh $here/kustomizations ".spec.sourceRef.name==\"flux-system\"")
# echo $kustomizations

while IFS= read -r kustomization; do
    # echo "$kustomization"
    parts=(${kustomization//\?/ })
    filename=${parts[0]}
    query=${parts[1]}
    echo $filename
    echo $query


    result=$($here/../flux/get-kustomization-path/get-kustomization-path.sh $filename ".$query")
    kustomization_paths=()

    IFS="$separator" read -r -a kustomization_paths <<< "$result"
    # echo "result: ${kustomization_paths[@]}"

    while IFS= read -r kustomization_path; do
        result=$($here/../kustomize/get-kustomization-tree/get-kustomization-tree.sh $here/kustomizations $kustomization_path)
    done < <(tr ' ' '\n' <<< "${kustomization_paths}")



# done <<< "${kustomizations}"
done < <(tr ' ' '\n' <<< "${kustomizations}")


    # get-kustomization-tree.sh

    #     get-kustomization-resources.sh

    #         filter-changes