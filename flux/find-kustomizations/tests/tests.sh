#!/bin/bash

here=`dirname $(realpath $0)`

separator=' '

query='.spec.sourceRef.name=="flux-system"'

result="$($here/../find-kustomizations.sh $here/testdata "$query" "$separator")"
result_array=()

IFS="$separator" read -r -a result_array <<< "$result"
echo "result: ${result_array[@]}"

if [[ ${#result_array[@]} != 2 ]]; then
    echo "2 elements expected"
    exit 1
fi

if [[ "${result_array[0]}" != "$here/testdata/testdata.yml?metadata.name==\"one\"" ]]; then
    echo "$here/testdata/testdata.yml?metadata.name==one expected"
    exit 1
fi

if [[ "${result_array[1]}" != "$here/testdata/testdata.yml?metadata.name==\"two\"" ]]; then
    echo "$here/testdata/testdata.yml?metadata.name==two expected"
    exit 1
fi
