#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

result=$($here/../filter-filenames.sh '\.ya?ml$' "matching/invalid.yml notmatching/valid matching.yaml matching/valid.yml notmatching/valid.txt notmatching.xml" "$separator")
echo $result
result_array=()
IFS="$separator" read -r -a result_array <<< "$result"

if [[ ${#result_array[@]} != 3 ]]; then
    echo "3 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "matching/invalid.yml" ]]; then
    echo "matching/invalid.yml expected"
    exit 1
fi

if [[ "${result_array[1]}" != "matching/valid.yml" ]]; then
    echo "matching/valid.yml expected"
    exit 1
fi

if [[ "${result_array[2]}" != "matching.yaml" ]]; then
    echo "matching.yaml expected"
    exit 1
fi
