#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../conftest.sh $here/testdata/conftest/invalid/invalid-local-policy/configmap.yml "$here/testdata/conftest/invalid/invalid-local-policy/policy")

read -r -d '' expected <<'EOF'
::group::Testing 'conftest/conftest-test/tests/testdata/conftest/invalid/invalid-local-policy/configmap.yml' against 1 policies in namespace 'main'
::error file=conftest/conftest-test/tests/testdata/conftest/invalid/invalid-local-policy/configmap.yml::missing testdata
::endgroup::
1 test, 0 passed, 0 warnings, 1 failure, 0 exceptions
EOF

if [[ "$result" != "$expected" ]]; then
    echo "actual: '$result'"
    echo "expected: '$expected'"
    exit 1
fi

# assert "invalid/invalid-local-policy/policy invalid/policy policy" "$result"
