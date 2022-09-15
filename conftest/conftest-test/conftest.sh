#!/bin/bash

# find all policy directories in parent folders 
git_root_dir=$(git rev-parse --show-toplevel)

set -e

policy_parent_directory_top="$(readlink -f "$1")"
shift
policy_parent_directory_bottom="$(readlink -f "$1")"
shift

policy_folders=()
path=$policy_parent_directory_bottom
while : ; do
    # echo $path
    policy_folders+=($(find "$path" -maxdepth 1 -mindepth 1 -name "policy" -type d))
    [[ $path != $policy_parent_directory_top ]] && [[ $path != "/" ]] || break
    path="$(readlink -f "$path"/..)"
done

# execute conftest
if [[ ${#policy_folders[@]} > 0 ]];then
    echo "executing 'conftest test $file ${policy_folders[@]/#/"-p "} -o github'"
    conftest test $@ ${policy_folders[@]/#/"-p "} -o github
else
    echo "no policy folders found - skipping contest"
fi
