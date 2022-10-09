#!/bin/bash
set -e

here=`dirname $(realpath $0 --relative-to .)`

# result=$($here/../find-kustomizations.sh $here/testdata "$query" "$separator")
# result_array=()

kustomizations=$($here/../flux/find-kustomizations/find-kustomizations.sh $here/kustomizations ".spec.sourceRef.name==\"flux-system\"")
# echo $kustomizations

git_changes=$($here/../git/git-changes/git-changes.sh refactoring)
echo "git_changes: $git_changes"

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
            IFS="$separator" read -r -a kustomization_resources <<< $($here/../kustomize/get-kustomization-resources/get-kustomization-resources.sh $here/kustomizations/$kustomization_yaml $here/../)
            echo "kustomization_resources: ${kustomization_resources[@]}"

            IFS="$separator" read -r -a filtered_resources <<< $($here/../generic/filter-lists/filter-lists.sh "$git_changes" "${kustomization_resources[@]}")
            echo "filtered_resources: ${filtered_resources[@]}"

            echo "(dirname $here/kustomizations/$kustomization_yaml): $(dirname $kustomization_yaml)"
            IFS="$separator" read -r -a policy_folders <<< $($here/../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $here $(dirname kustomizations/$kustomization_yaml) "policy")
            echo "policy_folders: ${policy_folders[@]}"

            while IFS= read -r resource; do
                echo "calling conftest for resource $resource"
                echo "prefixed policy folders: ${policy_folders[@]/#/$here/}"
                result=$($here/../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]/#/$here/}")
                echo $result
            done < <(tr ' ' '\n' <<< "${kustomization_resources}")


            

            # kubval

            # .github/workflows/pr.yml integration-tests/kustomizations/valid/with-child/configmap.yml

            # while IFS= read -r kustomization_resource; do
            #     echo "$($here/../conftest/conftest-test/conftest.sh $here/$kustomization_resource)"
            #     conftest_result=$($here/../conftest/conftest-test/conftest.sh $here/kustomizations $kustomization_resource)
            #     echo "conftest result: $conftest_result"
            # done < <(tr ' ' '\n' <<< "${kustomization_resources}")    

        done < <(tr ' ' '\n' <<< "${kustomization_tree}")

    done < <(tr ' ' '\n' <<< "${kustomization_paths}")

done < <(tr ' ' '\n' <<< "${kustomizations}")
