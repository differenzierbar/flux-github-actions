#!/bin/bash

DEFAULT_SEPARATOR=' '

ref=$1
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

git_changes=$(git diff $(git merge-base HEAD ${ref}) --name-only --relative)

echo "${git_changes}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator"
