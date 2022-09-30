#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

query=".metadata.name==\"one\""

result=$($here/../get-kustomization-path.sh $here/testdata/testdata.yml "$query" "$separator")
result_array=()

IFS="$separator" read -r -a result_array <<< "$result"
echo "result: ${result_array[@]}"

if [[ ${#result_array[@]} != 1 ]]; then
    echo "2 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "./kustomizations/one" ]]; then
    echo "./kustomizations/one expected"
    exit 1
fi
