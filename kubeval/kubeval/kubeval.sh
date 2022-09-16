#!/bin/bash

set -e

for input_file in $@; do
    echo "validating $input_file with kubeval"
    kubeval --skip-kinds Kustomization $input_file
done