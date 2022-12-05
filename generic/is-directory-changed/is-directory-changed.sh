#!/bin/bash

here=`dirname $(realpath $0)`

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

directory=$1
pattern=$2
changes=$3

>&2 echo "directory: $directory"
>&2 echo "pattern: $pattern"
>&2 echo "changes: $changes"

result=false
while IFS= read -r change; do
    >&2 echo "checking $change"
    if [[ $change == $directory/$pattern ]]; then
        result=true
    fi
done < <(tr "$separator" '\n' <<< "${changes[@]}")

echo $result

