#!/bin/bash

here=`dirname $(realpath $0)`
. $here/../../../.tests/assert

export SEPARATOR=' '

# fixed sort order on different installations/default locales
export LC_ALL=C

result=$($here/../get-all-kustomization-resources.sh "$here/testdata/valid.yml?metadata.name==\"valid-two\"")
assert "valid/with-child/child/configmap2.yml valid/with-child/child/configmap3.yml valid/with-child/configmap.yml" "$result"
