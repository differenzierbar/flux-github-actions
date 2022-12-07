#!/bin/bash

GITHUB_TOKEN=$1
GIT_SHA=$2
name=$3
shift 3

>&2 echo "GITHUB_TOKEN: $GITHUB_TOKEN"
>&2 echo "GIT_SHA: $GIT_SHA"
>&2 echo "name: $name"
>&2 echo "command: $@"
>&2 echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"

# shellscript magic to save stdout & stderr to variables following https://stackoverflow.com/a/18086548
unset t_std t_err t_ret
eval "$( ($@) \
        2> >(t_err=$(cat); typeset -p t_err) \
         > >(t_std=$(cat); typeset -p t_std); t_ret=$?; typeset -p t_ret )"

if [ "$t_ret" -eq 0 ]; then
    conclusion="success"
    summary=$(echo "'$@' output" | jq -Rsa .)

    # json escape output
    text=$(echo "$t_std" | jq -Rsa .)
else
    # echo "FAIL: $t_err"
    conclusion="failure"
    summary=$(echo "'$@' error" | jq -Rsa .)

    # json escape output
    text=$(echo "$t_std" | jq -Rsa .)
fi

>&2 echo "conclusion: $conclusion"
>&2 echo "summary: $summary"
>&2 echo "text: $text"

# create checkrun
checkrun_create="{\"name\":\"$name\",\"head_sha\":\"${GIT_SHA}\",\"status\":\"in_progress\",\"started_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\""$name"\",\"summary\":\"\",\"text\":\"\"}}"
>&2 echo "$checkrun_create" | jq
if [ "${DRY_RUN,,}" != "true" ]; then
    checkrun=$(curl \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs \
    --fail \
    -d "$checkrun_create")
    checkrun_id=$(echo $checkrun | jq .id)
else 
    >&2 echo "DRY_RUN=$DRY_RUN - skipping checkrun creation"
fi

# update checkrun
checkrun_update="{\"name\":\"$name\",\"status\":\"completed\",\"conclusion\":\"$conclusion\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"$name\",\"summary\":$summary,\"text\":$text}}"
>&2 echo "$checkrun_update" | jq
if [ "${DRY_RUN,,}" != "true" ]; then
    curl \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs/$checkrun_id \
    --fail \
    -d "$checkrun_update"
else 
    >&2 echo "DRY_RUN=$DRY_RUN - skipping checkrun update"
fi

return $t_ret