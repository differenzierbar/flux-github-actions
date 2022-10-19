#!/bin/bash
set -e

here=`dirname $(realpath $0 --relative-to .)`
# . $here/../../../.tests/assert

$here/../create-checkrun.sh TOKEN SHA name "$here/../../../flux/find-kustomizations/tests/tests.sh"