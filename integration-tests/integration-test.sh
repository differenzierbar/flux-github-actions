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

    kustomization_paths=()
    IFS="$separator" read -r -a kustomization_paths <<< $($here/../flux/get-kustomization-path/get-kustomization-path.sh $filename ".$query")
    echo "kustomization_paths: ${kustomization_paths[@]}"

    while IFS= read -r kustomization_path; do
        kustomization_tree=()
                                                    # result=$($here/../get-kustomization-tree.sh $here testdata/with-child "$separator")
        IFS="$separator" read -r -a kustomization_tree <<< $($here/../kustomize/get-kustomization-tree/get-kustomization-tree.sh $here/kustomizations $kustomization_path)
        echo "kustomization_tree: ${kustomization_tree[@]}"

        while IFS= read -r kustomization_yaml; do
            IFS="$separator" read -r -a kustomization_resources <<< $($here/../kustomize/get-kustomization-resources/get-kustomization-resources.sh $here/kustomizations/$kustomization_yaml)
            echo "kustomization_resources: ${kustomization_resources[@]}"

            while IFS= read -r kustomization_resource; do
                echo "$($here/../conftest/conftest-test/conftest.sh $here/$kustomization_resource)"
                conftest_result=$($here/../conftest/conftest-test/conftest.sh $here/kustomizations $kustomization_resource)
                echo "conftest result: $conftest_result"
            done < <(tr ' ' '\n' <<< "${kustomization_resources}")    

        done < <(tr ' ' '\n' <<< "${kustomization_tree}")

    done < <(tr ' ' '\n' <<< "${kustomization_paths}")

done < <(tr ' ' '\n' <<< "${kustomizations}")
