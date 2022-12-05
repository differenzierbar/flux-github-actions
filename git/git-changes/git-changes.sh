#!/bin/bash

DEFAULT_SEPARATOR=' '

ref=$1
directory="${2:-.}"

separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

git_changes=$(git -C $directory diff $(git -C $directory merge-base HEAD ${ref}) --name-only --relative)

echo "${git_changes}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator"
