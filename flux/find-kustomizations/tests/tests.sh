#!/bin/bash

here=`dirname $(realpath $0 --relative-to .)`
. $here/../../../.tests/assert

export SEPARATOR=' '

query='.spec.sourceRef.name=="flux-system"'

result="$($here/../find-kustomizations.sh $here/testdata "$query")"
assert "$here/testdata/testdata.yml?metadata.name==\"one\" $here/testdata/testdata.yml?metadata.name==\"two\"" "$result"
