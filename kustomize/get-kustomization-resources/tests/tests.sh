#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

result=$($here/../get-kustomization-resources.sh $here/testdata/with-child $here/../../..)
assert "kustomize/get-kustomization-resources/tests/testdata/with-child/configmap.yml kustomize/get-kustomization-resources/tests/testdata/with-child/deployment.yaml" "$result"
