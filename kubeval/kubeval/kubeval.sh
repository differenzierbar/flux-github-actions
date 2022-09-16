#!/bin/bash

set -e

for input_file in $@; do
    echo "validating $input_file with kubeval"
    # kubeval --skip-kinds Kustomization --skip-kinds CustomResourceDefinition $input_file
    kubeval --ignore-missing-schemas $input_file

done