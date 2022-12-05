#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

# fixed sort order on different installations/default locales
export LC_ALL=C

result=$($here/../filter-lists.sh "matching/valid matching/invalid.yml matching/valid.txt" "matching/invalid.yml matching/valid notmatching/valid.yml matching/valid.txt")
assert "matching/invalid.yml matching/valid matching/valid.txt" "$result"
