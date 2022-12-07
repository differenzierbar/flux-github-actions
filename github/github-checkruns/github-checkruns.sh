#!/bin/bash

GITHUB_TOKEN=$1
GIT_SHA=$2
KUSTOMIZATION_ROOT=$3

# >&2 echo "GITHUB_TOKEN: $GITHUB_TOKEN"
# >&2 echo "GIT_SHA: $GIT_SHA"
# >&2 echo "3: $3"


# while IFS= read -r kustomization; do
#     checkrun=$(curl \
#     -X POST \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: token ${GITHUB_TOKEN}" \
#     https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs \
#     --fail \
#     -d "{\"name\":\"$kustomization\",\"head_sha\":\"${GIT_SHA}\",\"status\":\"in_progress\",\"started_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"Mighty Readme report\",\"summary\":\"\",\"text\":\"\"}}")
#     checkrun_id=$(echo $checkrun | jq .id)
#     { kustomize_err="$( { kustomize build $3/$kustomization; } 2>&1 1> $3/$kustomization/kustomize.out)"; } || true
#     if [ -z "$kustomize_err" ]
#     then
#     kustomize_out=$(cat $3/$kustomization/kustomize.out | jq -Rsa .)
#     echo $kustomize_out
#     checkrun_update="{\"name\":\"$kustomization\",\"status\":\"completed\",\"conclusion\":\"success\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"Kustomization output\",\"summary\":\"kustomize build ${kustomzation}\",\"text\":$kustomize_out}}"
#     else
#     kustomize_err_esc=$(echo $kustomize_err | jq -Rsa .)
#     echo $kustomize_err_esc
#     checkrun_update="{\"name\":\"$kustomization\",\"status\":\"completed\",\"conclusion\":\"failure\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"Kustomization error\",\"summary\":\"kustomize build ${kustomzation} failed\",\"text\":$kustomize_err_esc}}"
#     fi
#     echo $checkrun_update
#     curl \
#     -X PATCH \
#     -H "Accept: application/vnd.github+json" \
#     -H "Authorization: token ${GITHUB_TOKEN}" \
#     https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs/$checkrun_id \
#     --fail \
#     -d "$checkrun_update"
# done <<< "$4"

#!/bin/bash
set -e

here=`dirname $(realpath $0 --relative-to .)`

separator=' '

kustomizations=$($here/../../flux/find-kustomizations/find-kustomizations.sh $KUSTOMIZATION_ROOT ".spec.sourceRef.name==\"flux-system\"")
# echo $kustomizations

git_changes=$($here/../../git/git-changes/git-changes.sh $GIT_SHA $KUSTOMIZATION_ROOT)
echo "git_changes: $git_changes"

while IFS= read -r kustomization; do
    # echo "$kustomization"
    parts=(${kustomization//\?/ })
    filename=${parts[0]}
    query=${parts[1]}
    echo $filename
    echo $query

    IFS="$separator" read -r -a kustomization_changed <<< $($here/../../generic/filter-lists/filter-lists.sh "$git_changes" "$filename")
    echo "kustomization_changed: ${#kustomization_changed[@]}"

    relative_folder=$(dirname $(realpath $filename --relative-to $KUSTOMIZATION_ROOT))

    IFS="$separator" read -r -a kustomization_resources <<< $($here/../../flux/get-all-kustomization-resources/get-all-kustomization-resources.sh $kustomization "$KUSTOMIZATION_ROOT")
    echo "all kustomization_resources: ${kustomization_resources[@]}"

    echo "looking for policy_folders in $relative_folder"
    IFS="$separator" read -r -a policy_folders <<< $($here/../../generic/find-in-ancestor-folders/find-in-ancestor-folders.sh $KUSTOMIZATION_ROOT $relative_folder "policy")
    echo "policy_folders: ${policy_folders[@]}"

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
            $here/../create-checkrun/create-checkrun.sh $GITHUB_TOKEN $GITHUB_HEAD_REF "kubeconform $resource" $here/../../kubeval/kubeconform/kubeconform.sh "$resource"
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_check[@]}")

    echo "resources_to_policy_check: '${resources_to_policy_check[@]}'"
    while IFS= read -r resource; do
        echo "resource: $resource"
        if [[ -n "$resource" ]]; then
            # echo "calling conftest for resource $resource"
            # result=$($here/../../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]/#/$KUSTOMIZATION_ROOT/}")
            # echo $result
            $here/../create-checkrun/create-checkrun.sh $GITHUB_TOKEN $GITHUB_HEAD_REF "conftest test $resource" $here/../../conftest/conftest-test/conftest.sh "$resource" "${policy_folders[@]/#/$KUSTOMIZATION_ROOT/}"
        fi
    done < <(tr "$separator" '\n' <<< "${resources_to_policy_check[@]}")
        
done < <(tr ' ' '\n' <<< "${kustomizations[@]}")
