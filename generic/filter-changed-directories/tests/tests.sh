#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

# fixed sort order on different installations/default locales
export LC_ALL=C

result=$($here/../filter-changed-directories.sh "changed unchanged" "*.rego" "changed/rule1.rego changed/rule2.rego anotherdir/yaml.yml")
assert "changed" "$result"

result=$($here/../filter-changed-directories.sh "changed other-changed unchanged" "*.rego" "changed/rule1.rego other-changed/rule2.rego anotherdir/yaml.yml")
assert "changed other-changed" "$result"

result=$($here/../filter-changed-directories.sh changed "*.rego" "")
assert "" "$result"