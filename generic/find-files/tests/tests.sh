#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

SEPARATOR=' '

result=$($here/../find-files.sh $here/testdata ".*.ya?ml$" "true")
assert "$here/testdata/child/child.yaml $here/testdata/one.yaml $here/testdata/two.yml" "$result"
