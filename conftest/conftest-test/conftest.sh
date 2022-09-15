#!/bin/bash

# find all policy directories in parent folders 
git_root_dir=$(git rev-parse --show-toplevel)

set -e
file="$(readlink -f "$1")"
path="$(dirname $file)"
root_dir="$(readlink -f "$2")"
policy_folders=()

while : ; do
    # echo $path
    policy_folders+=($(find "$path" -maxdepth 1 -mindepth 1 -name "policy" -type d))
    [[ $path != $root_dir ]] && [[ $path != "/" ]] || break
    path="$(readlink -f "$path"/..)"
done

# execute conftest
if [[ ${#policy_folders[@]} > 0 ]];then
    echo "executing 'conftest test $file ${policy_folders[@]/#/"-p "} -o github'"
    conftest test $file ${policy_folders[@]/#/"-p "} -o github
else
    echo "no policy folders found - skipping contest"
fi
