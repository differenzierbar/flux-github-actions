#!/bin/bash

set -e

for input_file in $@; do
    echo "validating $input_file with kubeconform"
    # kubeval --skip-kinds Kustomization --skip-kinds CustomResourceDefinition $input_file
    kubeconform --ignore-missing-schemas --strict $input_file

done