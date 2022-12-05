#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

# fixed sort order on different installations/default locales
export LC_ALL=C

result=$($here/../is-directory-changed.sh changed "*.rego" "changed/rule1.rego changed/rule2.rego anotherdir/yaml.yml")
assert "true" "$result"

result=$($here/../is-directory-changed.sh changed "*.rego" "other-changed/rule1.rego other-changed/rule2.rego anotherdir/yaml.yml")
assert "false" "$result"

result=$($here/../is-directory-changed.sh changed "*.rego")
assert "false" "$result"
# result=$($here/../is-directory-changed.sh "matching/valid matching/invalid.yml matching/valid.txt" "matching notmatching/valid.yml")
# assert "matching/invalid.yml matching/valid matching/valid.txt" "$result"