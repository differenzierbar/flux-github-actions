#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`

export SEPARATOR=' '

result=$($here/../get-kustomization-resources.sh $here/testdata/with-child/kustomization.yaml $here/testdata)

result_array=()
IFS="$SEPARATOR" read -r -a result_array <<< "$result"

echo "result: ${result_array[@]}"

if [[ ${#result_array[@]} != 2 ]]; then
    echo "2 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "with-child/configmap.yml" ]]; then
    echo "with-child/configmap.yml expected"
    exit 1
fi

if [[ "${result_array[1]}" != "with-child/deployment.yaml" ]]; then
    echo "with-child/deployment.yaml expected"
    exit 1
fi
