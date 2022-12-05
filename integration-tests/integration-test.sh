#!/bin/bash
set -e

here=`dirname $(realpath $0 --relative-to .)`

separator=' '

# result=$($here/../find-kustomizations.sh $here/testdata "$query" "$separator")
# result_array=()

kustomizations=$($here/../flux/find-kustomizations/find-kustomizations.sh $here/kustomizations ".spec.sourceRef.name==\"flux-system\"")
# echo $kustomizations

git_changes=$($here/../git/git-changes/git-changes.sh HEAD)
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

    relative_folder=$(dirname $(realpath $filename --relative-to $here/../))

    IFS="$separator" read -r -a kustomization_resources <<< $($here/../flux/get-all-kustomization-resources/get-all-kustomization-resources.sh $kustomization "$here/..")
    echo "all kustomization_resources: ${kustomization_resources[@]}"

    # echo "(dirname $here/kustomizations/$kustomization_yaml): $(dirname $kustomization_yaml)"
    echo "looking for policy_folders in $relative_folder"
    IFS="$separator" read -r -a policy_folders <<< $($here/../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $here/../ $relative_folder "policy")
    echo "policy_folders: ${policy_folders[@]}"
    # result=$($here/../find-files.sh $here/testdata ".*.ya?ml$" "true")

    if [[ "${kustomization_changed}" ]]; then
        resources_to_check="$kustomization_resources"
        resources_to_policy_check="$kustomization_resources"
    else
        # look for resource changes
        read -r -a filtered_resources <<< $($here/../generic/filter-lists/filter-lists.sh "$git_changes" "${kustomization_resources[*]}")
        echo "filtered_resources: ${filtered_resources[@]}"
        resources_to_check="$filtered_resources"

        IFS="$separator" read -r -a changed_policy_folders <<< $($here/../generic/filter-changed-directories/filter-changed-directories.sh "$policy_folders" "*" "$git_changes")
        echo "policy_folders_changed: ${#changed_policy_folders[@]}"
        if [[ ${#changed_policy_folders[@]} -gt 0 ]]; then
            # policies changed - policy-check all resources
            resources_to_policy_check="$kustomization_resources"
        else
            # policies not changed - policy-check only changed resources 
            resources_to_policy_check="$filtered_resources"
        fi
    fi

    echo "resources_to_check: ${resources_to_check[@]}"
    while IFS= read -r resource; do
        echo "resource: $resource"
        if [[ -n "$resource" ]]; then
            echo "calling kubeconform for resource $resource"
            result=$($here/../kubeval/kubeconform/kubeconform.sh "$resource")
            echo $result
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_check[@]}")

    echo "resources_to_policy_check: '${resources_to_policy_check[@]}'"
    # for resource in "${resources_to_policy_check[@]}"; do
    #     # echo "processing entry $entry..."
    #     echo "resource: $resource"

    #     echo "calling conftest for resource $resource"
    #     # echo "prefixed policy folders: ${policy_folders[@]/#/$here/}"
    #     result=$($here/../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]}")
    #     echo $result
    # done


    while IFS= read -r resource; do
        echo "resource: $resource"
        if [[ -n "$resource" ]]; then
            echo "calling conftest for resource $resource"
            # echo "prefixed policy folders: ${policy_folders[@]/#/$here/}"
            result=$($here/../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]}")
            echo $result
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_policy_check[@]}")
        
done < <(tr ' ' '\n' <<< "${kustomizations[@]}")
