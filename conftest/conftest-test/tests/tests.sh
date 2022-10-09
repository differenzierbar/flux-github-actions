#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../conftest.sh $here/testdata/conftest/invalid/invalid-local-policy/configmap.yml "$here/testdata/conftest/invalid/invalid-local-policy/policy")
echo $result
# assert "invalid/invalid-local-policy/policy invalid/policy policy" "$result"
