#!/bin/bash

here=`dirname $(realpath $0)`

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

directories=$1
pattern=$2
changes=$3

>&2 echo "directories: $directories"
>&2 echo "pattern: $pattern"
>&2 echo "changes: $changes"

result=()
while IFS= read -r directory; do

    while IFS= read -r change; do
        # >&2 echo "checking $directory - $change"
        if [[ $change == $directory/$pattern ]]; then
            result=("${result[@]}" "${directory}")
        fi
        # >&2 echo "current result ${result[@]}"
    done < <(tr "$separator" '\n' <<< "${changes[@]}")

done < <(tr "$separator" '\n' <<< "${directories[@]}")

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs

