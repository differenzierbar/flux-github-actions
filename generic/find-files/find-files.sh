#!/bin/bash
set -e


directory=$1
pattern=$2
recursive=$3

separator=' '

>&2 echo "directory: $directory"
>&2 echo "pattern: $pattern"
>&2 echo "recursive: $recursive"

if [[ "$recursive" == "false" ]]; then
    default_find_args="-maxdepth 1 -mindepth 1"
else
    default_find_args=""
fi

result=()

>&2 echo "executing 'find $directory $default_find_args -regex \"$pattern\"'"

result+=($(find $directory $default_find_args -regex "$pattern"))

# while IFS= read -r file; do
#     if [[ ! -z "$file" ]]; then
#         result+=($file)
#     fi
# done <<< "${files}"

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs
