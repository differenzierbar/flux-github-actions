#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

# fixed sort order on different installations/default locales
export LC_ALL=C

result=$($here/../filter-filenames.sh '\.ya?ml$' "matching/invalid.yml notmatching/valid matching.yaml matching/valid.yml notmatching/valid.txt notmatching.xml" "$separator")
assert "matching.yaml matching/invalid.yml matching/valid.yml" "$result"
