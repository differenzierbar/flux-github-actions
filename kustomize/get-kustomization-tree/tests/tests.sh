#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

result=$($here/../get-kustomization-tree.sh $here testdata/with-child "$separator")

result_array=()
IFS="$separator" read -r -a result_array <<< "$result"

echo "result: ${result_array[@]}"

if [[ ${#result_array[@]} != 2 ]]; then
    echo "2 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "testdata/with-child/child/kustomization.yaml" ]]; then
    echo "testdata/with-child/child/kustomization.yaml expected"
    exit 1
fi


if [[ "${result_array[1]}" != "testdata/with-child/kustomization.yaml" ]]; then
    echo "testdata/with-child/kustomization.yaml expected"
    exit 1
fi
