#!/bin/bash

set -e

input_file=$1

>&2 echo "validating $input_file with kubeconform"
kubeconform --ignore-missing-schemas --strict $input_file