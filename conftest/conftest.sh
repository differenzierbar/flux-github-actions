#!/bin/bash

# find all policy directories in parent folders 
git_root_dir=$(git rev-parse --show-toplevel)

set -e
path="$(readlink -f "$1")"
root_dir="$(readlink -f "$2")"
policy_folders=()

while : ; do
    echo $path
    policy_folders+=($(find "$path" -maxdepth 1 -mindepth 1 -name "policy" -type d))
    [[ $path != $root_dir ]] && [[ $path != "/" ]] || break
    path="$(readlink -f "$path"/..)"
done

if [[ ${#policy_folders[@]} > 0 ]];then
    echo "executing 'conftest test ${policy_folders[@]/#/"-p "} - <&0'"
    conftest test ${policy_folders[@]/#/"-p "} - <&0
else
    echo "no policy folders found - skipping contest"
fi
