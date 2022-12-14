#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../conftest.sh $here/testdata/conftest/invalid/invalid-local-policy/configmap.yml "$here/testdata/conftest/invalid/invalid-local-policy/policy")

read -r -d '' expected <<'EOF'
FAIL - conftest/conftest-test/tests/testdata/conftest/invalid/invalid-local-policy/configmap.yml - main - missing testdata

1 test, 0 passed, 0 warnings, 1 failure, 0 exceptions
EOF

assert "$expected" "$result"
