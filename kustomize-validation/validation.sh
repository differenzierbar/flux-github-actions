#!/bin/bash

GITHUB_TOKEN=$1
GIT_SHA=$2

>&2 echo "GITHUB_TOKEN: $GITHUB_TOKEN"
>&2 echo "GIT_SHA: $GIT_SHA"
>&2 echo "3: $3"


while IFS= read -r kustomization; do
    checkrun=$(curl \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs \
    --fail \
    -d "{\"name\":\"$kustomization\",\"head_sha\":\"${GIT_SHA}\",\"status\":\"in_progress\",\"started_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"Mighty Readme report\",\"summary\":\"\",\"text\":\"\"}}")
    checkrun_id=$(echo $checkrun | jq .id)
    { kustomize_err="$( { kustomize build $kustomization; } 2>&1 1> $kustomization/kustomize.out)"; } || true
    if [ -z "$kustomize_err" ]
    then
    kustomize_out=$(cat $kustomization/kustomize.out | jq -Rsa .)
    echo $kustomize_out
    checkrun_update="{\"name\":\"$kustomization\",\"status\":\"completed\",\"conclusion\":\"success\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"Kustomization output\",\"summary\":\"kustomize build ${kustomzation}\",\"text\":$kustomize_out}}"
    else
    kustomize_err_esc=$(echo $kustomize_err | jq -Rsa .)
    echo $kustomize_err_esc
    checkrun_update="{\"name\":\"$kustomization\",\"status\":\"completed\",\"conclusion\":\"failure\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"Kustomization error\",\"summary\":\"kustomize build ${kustomzation} failed\",\"text\":$kustomize_err_esc}}"
    fi
    echo $checkrun_update
    curl \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs/$checkrun_id \
    --fail \
    -d "$checkrun_update"
done <<< "$3"