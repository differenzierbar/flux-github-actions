#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../filter-changes.sh . $PWD/matching/ "matching/invalid.yml matching/valid notmatching/valid.yml matching/valid.txt" "$separator")
assert "matching/invalid.yml matching/valid matching/valid.txt" "$result"
