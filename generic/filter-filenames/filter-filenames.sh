#!/bin/bash

DEFAULT_SEPARATOR=' '

filename_filter="$1"
files="$2"
separator="${3:-$DEFAULT_SEPARATOR}"

>&2 echo "filename_filter: '$filename_filter'"
>&2 echo "files: $files"
>&2 echo "separator: '$separator'"

result=()

while IFS= read -r file; do
    >&2 echo "checking file: $file"

    if [[ $file =~ $filename_filter ]]; then
        result+=($file)
        >&2 echo "found file: $file"
    fi
done < <(tr "$separator" '\n' <<< "${files}")

# IFS="$separator" read -r -a result <<< "$(echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator")"
# echo ${result[@]}
echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator"
