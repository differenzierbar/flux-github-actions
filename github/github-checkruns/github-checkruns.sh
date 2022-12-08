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

    start=`date +%s`

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
        resources_to_check=${kustomization_resources[@]}
        resources_to_policy_check=${kustomization_resources[@]}
    else
        resources_to_check=()
        resources_to_policy_check=()
        # look for resource changes
        while IFS= read -r resource; do
            if [[ -n "$resource" ]]; then
                read -r -a filtered_resources <<< $($here/../../generic/filter-lists/filter-lists.sh "$git_changes" "$resource")
                echo "filtered_resources: ${filtered_resources[@]}"

                if [[ ${#filtered_resources[@]} -gt 0 ]];then
                    resources_to_check+=$resource
                    resources_to_policy_check+=$resource
                else 
                    resource_directory=$(dirname $resource)
                    echo "looking for policy_folders in $resource_directory"
                    IFS="$separator" read -r -a policy_folders <<< $($here/../../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $KUSTOMIZATION_ROOT $resource_directory "policy")
                    echo "policy_folders: ${policy_folders[@]}"

                    IFS="$separator" read -r -a changed_policy_folders <<< $($here/../../generic/filter-changed-directories/filter-changed-directories.sh "$policy_folders" "*" "$git_changes")
                    echo "policy_folders_changed: ${#changed_policy_folders[@]}"
                    if [[ ${#changed_policy_folders[@]} -gt 0 ]]; then
                        # policies changed - policy-check all resources
                        resources_to_policy_check+=$resource
                    fi
                fi
            fi
        done < <(tr "$separator" '\n' <<< "${resources_to_check[@]}")

    fi


    declare -A check_failures=()
    check_status=0

    echo "resources_to_check: ${resources_to_check[@]}"
    while IFS= read -r resource; do
        echo "resource: $resource"
        if [[ -n "$resource" ]]; then
            set +e
            kubeconform_result=$($here/../../kubeval/kubeconform/kubeconform.sh "$resource")
            kubeconform_return_code=$?
            set -e
            if [[ kubeconform_return_code -ne 0 ]]; then
                check_failures["kubeconform $resource"]=$kubeconform_result
                check_status=1
            fi
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_check[@]}")

    echo "resources_to_policy_check: '${resources_to_policy_check[@]}'"
    while IFS= read -r resource; do
        echo "resource: $resource"
        if [[ -n "$resource" ]]; then
            resource_directory=$(dirname $resource)
            echo "looking for policy_folders in $resource_directory"
            IFS="$separator" read -r -a policy_folders <<< $($here/../../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $KUSTOMIZATION_ROOT $resource_directory "policy")
            echo "policy_folders: ${policy_folders[@]}"
            set +e
            conftest_result=$($here/../../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]/#/$KUSTOMIZATION_ROOT/}")
            conftest_return_code=$?
            set -e
            if [[ conftest_return_code -ne 0 ]]; then
                check_failures["conftest $resource"]=$conftest_result
                check_status=1
            fi
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_policy_check[@]}")

    checkrun_text=""
    for check in "${!check_failures[@]}"
    do
        checkrun_text+="$check failed: ${check_failures[$check]}"
    done

    if [[ check_status -ne 0 ]]; then
        conclusion="failure"
        summary="failed checks"
        $here/../create-checkrun/create-checkrun.sh $GITHUB_TOKEN $GITHUB_HEAD_REF "'$relative_file'" $conclusion $summary $text
    fi
    

    end=`date +%s`
    runtime=$((end-start))
    echo "duration for $kustomization: $runtime"
        
done < <(tr ' ' '\n' <<< "${kustomizations[@]}")

exit $return_value