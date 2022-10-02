#!/bin/bash

set -e

policy_parent_directory_top="$(readlink -f "$1")"
input_file=$2

policy_folders=()
path=$(dirname $input_file)
while : ; do
    # echo $path
    policy_folders+=($(find "$path" -maxdepth 1 -mindepth 1 -name "policy" -type d))
    [[ $path != $policy_parent_directory_top ]] && [[ $path != "/" ]] || break
    path="$(readlink -f "$path"/..)"
done

# execute conftest
if [[ ${#policy_folders[@]} > 0 ]];then
    >&2 echo "executing 'conftest test $input_file ${policy_folders[@]/#/"-p "} -o github'"
    conftest test $input_file ${policy_folders[@]/#/"-p "} -o github
else
    >&2 echo "no policy folders found - skipping conftest for $input_file"
fi