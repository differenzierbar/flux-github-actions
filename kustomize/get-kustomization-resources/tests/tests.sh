#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

result=$($here/../get-kustomization-resources.sh $here/testdata/with-child/kustomization.yaml "$separator")

result_array=()
IFS="$separator" read -r -a result_array <<< "$result"

echo "result: ${result_array[@]}"

if [[ ${#result_array[@]} != 2 ]]; then
    echo "2 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "$here/testdata/with-child/configmap.yml" ]]; then
    echo "$here/testdata/with-child/configmap.yml expected"
    exit 1
fi

if [[ "${result_array[1]}" != "$here/testdata/with-child/deployment.yaml" ]]; then
    echo "$here/testdata/with-child/deployment.yaml expected"
    exit 1
fi
