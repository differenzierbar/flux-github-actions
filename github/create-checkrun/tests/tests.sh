#!/bin/bash
set -e

here=`dirname $(realpath $0 --relative-to .)`
# . $here/../../../.tests/assert

$here/../create-checkrun.sh TOKEN commit12345 name "$here/../../../flux/find-kustomizations/tests/tests.sh"