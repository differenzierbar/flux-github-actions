#!/bin/bash

GITHUB_TOKEN=$1
GIT_SHA=$2

name=$3
conclusion=$4
title=$5
summary=$6
text=$7

checkrun=$(curl \
-X POST \
-H "Accept: application/vnd.github+json" \
-H "Authorization: token ${GITHUB_TOKEN}" \
https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs \
--fail \
-d "{\"name\":\"$name\",\"head_sha\":\"${GIT_SHA}\",\"status\":\"in_progress\",\"started_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"$title\",\"summary\":\"\",\"text\":\"\"}}")

checkrun_id=$(echo $checkrun | jq .id)
checkrun_update="{\"name\":\"$name\",\"status\":\"completed\",\"conclusion\":\"$conclusion\",\"completed_at\":\"$(date -u +"%Y-%m-%dT%H:%M:%S"Z)\",\"output\":{\"title\":\"$title\",\"summary\":\"$summary\",\"text\":$text}}"
echo $checkrun_update
curl \
-X PATCH \
-H "Accept: application/vnd.github+json" \
-H "Authorization: token ${GITHUB_TOKEN}" \
https://api.github.com/repos/${GITHUB_REPOSITORY}/check-runs/$checkrun_id \
--fail \
-d "$checkrun_update"