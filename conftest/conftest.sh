#!/bin/bash

# find all policy directories in parent folders 
git_root_dir=$(git rev-parse --show-toplevel)

set -e
path="$(readlink -f "$1")"
root_dir="$(readlink -f "$2")"
result=()

while : ; do
    # echo $path
    [[ $path != $root_dir ]] && [[ $path != "/" ]] || break
    result+=($(find "$path" -maxdepth 1 -mindepth 1 -name "policy" -type d))
    path="$(readlink -f "$path"/..)"
done

# conftest test -p ../../../policies/ ../../policies -
# echo "executing conftest test ${result[@]/#/\"-p \"} -"
conftest test ${result[@]/#/"-p "} - <&0

