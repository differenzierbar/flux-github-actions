#!/bin/bash
set -e

directory=$1
pattern=$2
files=$(find $directory -name "$pattern")

IFS=" " read -r -a files <<< "$(echo "${files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
echo ${files[@]}
