#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

result=$($here/../find-files.sh $here/testdata ".*.ya?ml$" "true")

result_array=()
IFS="$separator" read -r -a result_array <<< "$result"

echo "result: ${result_array[@]}"

if [[ ${#result_array[@]} != 3 ]]; then
    echo "3 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "$here/testdata/child/child.yaml" ]]; then
    echo "testdata/child/child.yaml expected"
    exit 1
fi
if [[ "${result_array[1]}" != "$here/testdata/one.yaml" ]]; then
    echo "testdata/one.yaml expected"
    exit 1
fi

if [[ "${result_array[2]}" != "$here/testdata/two.yml" ]]; then
    echo "testdata/two.yml expected"
    exit 1
fi

