#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

query=".metadata.name==\"one\""

result=$($here/../get-kustomization-path.sh $here/testdata/testdata.yml "$query" "$separator")
assert "./kustomizations/one" "$result"
