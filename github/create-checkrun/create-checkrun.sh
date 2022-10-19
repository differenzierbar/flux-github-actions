#!/bin/bash

GITHUB_TOKEN=$1
GIT_SHA=$2
name=$3
shift 3

>&2 echo "GITHUB_TOKEN: $GITHUB_TOKEN"
>&2 echo "GIT_SHA: $GIT_SHA"
>&2 echo "name: $name"
>&2 echo "command: $@"

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
    text=$(echo "$t_err" | jq -Rsa .)
fi

>&2 echo "conclusion: $conclusion"
>&2 echo "summary: $summary"
>&2 echo "text: $text"

samples=("")
if [ "${DRY_RUN,,}" != "true" ]; then
    # create checkrun
    checkrun=$(curl \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs \
    --fail \
    -d "{\"name\":\"$name\",\"head_sha\":\"${GIT_SHA}\",\"status\":\"in_progress\",\"started_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\""$name"\",\"summary\":\"\",\"text\":\"\"}}")
    checkrun_id=$(echo $checkrun | jq .id)

    # update checkrun
    checkrun_update="{\"name\":\"$name\",\"status\":\"completed\",\"conclusion\":\"$conclusion\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"$name\",\"summary\":\"$summary\",\"text\":$text}}"
    # >&2 echo $checkrun_update
    curl \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs/$checkrun_id \
    --fail \
    -d "$checkrun_update"
else 
    >&2 echo "DRY_RUN=$DRY_RUN - skipping checkrun creation"
fi