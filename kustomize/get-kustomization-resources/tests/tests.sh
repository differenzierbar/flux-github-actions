#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../get-kustomization-resources.sh $here/testdata/with-child/kustomization.yaml $here/testdata)
assert "with-child/configmap.yml with-child/deployment.yaml" "$result"
