#!/bin/bash
set -e

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../get-kustomization-tree.sh $here testdata/with-child)
assert "testdata/with-child testdata/with-child/child" "$result"


