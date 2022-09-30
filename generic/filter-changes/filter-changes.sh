#!/bin/bash

DEFAULT_SEPARATOR=' '

root_directory=$(realpath --relative-to $1 $1)
directory=$(realpath --relative-to $1 $2)
changes="$3"
separator="${4:-$DEFAULT_SEPARATOR}"

>&2 echo "root_directory: $root_directory"
>&2 echo "directory: $directory"
>&2 echo "changes: $changes"
>&2 echo "separator: '$separator'"

result=()

while IFS= read -r change; do
    >&2 echo "checking change: $change"

    if [[ $change/ = $directory/* ]]; then
        result+=($change)
        >&2 echo "found change: $change"
    fi
done < <(tr "$separator" '\n' <<< "${changes}")

# IFS="$separator" read -r -a result <<< "$(echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator")"
# echo ${result[@]}

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator"
