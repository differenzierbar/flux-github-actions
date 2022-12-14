#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../find-in-ancestor-folders.sh "$here/testdata/conftest" "invalid/invalid-local-policy" "policy")
assert "invalid/invalid-local-policy/policy invalid/policy policy" "$result"
