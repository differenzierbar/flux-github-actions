#!/bin/bash
set -e

declare -A kustomization_changes=()

# >&2 echo "GITHUB_BASE_REF: $GITHUB_BASE_REF"

changes=$1
# changes=$(git diff $(git merge-base HEAD origin/$GITHUB_BASE_REF) --name-only)
while IFS= read -r change; do
    # echo $change
    # echo $(dirname $change)/kustomization.yaml
    if [[ "${change##*/}" == "kustomization.yaml" ]];then
        # echo kustomization.yaml itself has changed
        kustomization_changes[$(dirname $change)]="1"
    elif [[ -f "$(dirname $change)/kustomization.yaml" ]];then
        # "kustomization.yaml in directory"
        # check if the kustomization.yaml references the change
        # FIXME do this not only for the kustomization in the current dir
        change_in_kustomization=$(cat $(dirname $change)/kustomization.yaml | yq ".resources[] | select(. == \"$(realpath --relative-to $(dirname $change) $change)\")")
        # echo "change_in_kustomization: $change_in_kustomization"
        if [[ "$change_in_kustomization" != "" ]]; then
            # echo "adding kustomization to changes $(dirname $change)/kustomization.yaml"
            kustomization_changes[$(dirname $change)]="1"
        fi
    elif [[ "$change" =~ .*\.ya?ml ]]; then
        kustomization_changes[$(dirname $change)]="1"
    fi
done <<< "${changes}"

# echo ${!kustomization_changes[@]}
flux_kustomizations=$(find . -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' {} +)
result=()
while IFS= read -r kustomization; do
    # echo $(realpath --relative-to . $kustomization)
    if [[ ${kustomization_changes[$(realpath --relative-to . $kustomization)]} ]]; then result+=($kustomization); fi    # Exists
done <<< "${flux_kustomizations}"

echo $result

# while IFS= read -r kustomization; do
#     { kustomize_err="$( { kustomize build $kustomization; } 2>&1 1> /dev/null)"; } || echo "kustomize build $kustomization failed: $kustomize_err"
    
# done <<< "${result}"




