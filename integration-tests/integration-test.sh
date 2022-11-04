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

    IFS="$separator" read -r -a kustomization_changed <<< $($here/../generic/filter-lists/filter-lists.sh "$git_changes" "$filename")
    echo "kustomization_changed: ${#kustomization_changed[@]}"

    IFS="$separator" read -r -a kustomization_resources <<< $($here/../flux/get-all-kustomization-resources/get-all-kustomization-resources.sh $kustomization)

    # echo "(dirname $here/kustomizations/$kustomization_yaml): $(dirname $kustomization_yaml)"
    IFS="$separator" read -r -a policy_folders <<< $($here/../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $here $(dirname kustomizations/$kustomization_yaml) "policy")
    echo "policy_folders: ${policy_folders[@]}"


    if [[ "${kustomization_changed}" ]]; then
        resources_to_check="$kustomization_resources"
    else
        IFS="$separator" read -r -a filtered_resources <<< $($here/../generic/filter-lists/filter-lists.sh "$git_changes" "${kustomization_resources[@]}")
        resources_to_check="$filtered_resources"
    fi


        # IFS="$separator" read -r -a filtered_resources <<< $($here/../generic/filter-lists/filter-lists.sh "$git_changes" "${kustomization_resources[@]}")
        # echo "filtered_resources: ${filtered_resources[@]}"


    while IFS= read -r resource; do
        echo "resource: $resource"
        # echo "calling conftest for resource $resource"
        # echo "prefixed policy folders: ${policy_folders[@]/#/$here/}"
        # result=$($here/../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]/#/$here/}")
        # echo $result
    done < <(tr ' ' '\n' <<< "${resources_to_check[@]}")


        

        # kubval

        # .github/workflows/pr.yml integration-tests/kustomizations/valid/with-child/configmap.yml

        # while IFS= read -r kustomization_resource; do
        #     echo "$($here/../conftest/conftest-test/conftest.sh $here/$kustomization_resource)"
        #     conftest_result=$($here/../conftest/conftest-test/conftest.sh $here/kustomizations $kustomization_resource)
        #     echo "conftest result: $conftest_result"
        # done < <(tr ' ' '\n' <<< "${kustomization_resources}")    


done < <(tr ' ' '\n' <<< "${kustomizations[@]}")
