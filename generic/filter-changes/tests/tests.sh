#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

result=$($here/../filter-changes.sh . $PWD/matching/ "matching/invalid.yml matching/valid notmatching/valid.yml matching/valid.txt" "$separator")

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

if [[ "${result_array[1]}" != "matching/valid" ]]; then
    echo "matching/valid expected"
    exit 1
fi

if [[ "${result_array[2]}" != "matching/valid.txt" ]]; then
    echo "matching/valid.txt expected"
    exit 1
fi