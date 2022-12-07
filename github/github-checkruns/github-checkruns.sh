#!/bin/bash

set -e

GITHUB_TOKEN=$1
GIT_SHA=$2
KUSTOMIZATION_ROOT=$3


here=`dirname $(realpath $0 --relative-to .)`

separator=' '

kustomizations=$($here/../../flux/find-kustomizations/find-kustomizations.sh $KUSTOMIZATION_ROOT ".spec.sourceRef.name==\"flux-system\"")
# echo $kustomizations

git_changes=$($here/../../git/git-changes/git-changes.sh $GIT_SHA $KUSTOMIZATION_ROOT)
echo "git_changes: $git_changes"

return_value=0

while IFS= read -r kustomization; do
    # echo "$kustomization"
    parts=(${kustomization//\?/ })
    filename=${parts[0]}
    query=${parts[1]}
    echo $filename
    echo $query

    relative_file=$(realpath $filename --relative-to $KUSTOMIZATION_ROOT)

    IFS="$separator" read -r -a kustomization_changed <<< $($here/../../generic/filter-lists/filter-lists.sh "$git_changes" "$relative_file")
    echo "kustomization_changed: ${#kustomization_changed[@]}"

    relative_folder=$(dirname $relative_file)

    IFS="$separator" read -r -a kustomization_resources <<< $($here/../../flux/get-all-kustomization-resources/get-all-kustomization-resources.sh $kustomization "$KUSTOMIZATION_ROOT")
    echo "all kustomization_resources: ${kustomization_resources[@]}"

    if [[ "${kustomization_changed}" ]]; then
        resources_to_check="$kustomization_resources"
        resources_to_policy_check="$kustomization_resources"
    else
        # look for resource changes
        read -r -a filtered_resources <<< $($here/../../generic/filter-lists/filter-lists.sh "$git_changes" "${kustomization_resources[*]}")
        echo "filtered_resources: ${filtered_resources[@]}"
        resources_to_check="$filtered_resources"

        IFS="$separator" read -r -a changed_policy_folders <<< $($here/../../generic/filter-changed-directories/filter-changed-directories.sh "$policy_folders" "*" "$git_changes")
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
            # echo "calling kubeconform for resource $resource"
            # result=$($here/../../kubeval/kubeconform/kubeconform.sh "$resource")
            # echo $result
            set +e
            $here/../create-checkrun/create-checkrun.sh $GITHUB_TOKEN $GITHUB_HEAD_REF "kubeconform '$resource'" $here/../../kubeval/kubeconform/kubeconform.sh "$resource"
            ((return_value|=$?))
            set -e
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_check[@]}")

    echo "resources_to_policy_check: '${resources_to_policy_check[@]}'"
    while IFS= read -r resource; do
        echo "resource: $resource"
        if [[ -n "$resource" ]]; then
            # echo "calling conftest for resource $resource"
            # result=$($here/../../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]/#/$KUSTOMIZATION_ROOT/}")
            # echo $result
            resource_directory=$(dirname $resource)
            echo "looking for policy_folders in $resource_directory"
            IFS="$separator" read -r -a policy_folders <<< $($here/../../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $KUSTOMIZATION_ROOT $resource_directory "policy")
            echo "policy_folders: ${policy_folders[@]}"

            set +e
            $here/../create-checkrun/create-checkrun.sh $GITHUB_TOKEN $GITHUB_HEAD_REF "conftest test '$resource'" $here/../../conftest/conftest-test/conftest.sh "$resource" "\"${policy_folders[@]/#/$KUSTOMIZATION_ROOT/}\""
            ((return_value|=$?))
            set -e
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_policy_check[@]}")
        
done < <(tr ' ' '\n' <<< "${kustomizations[@]}")

exit $return_value