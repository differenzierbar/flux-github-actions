#!/bin/bash

set -e

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

input_file="$1"
shift
IFS=$separator read -r -a policy_folders <<< "$(echo $@)"

>&2 echo "input_file: $input_file"
>&2 echo "policy_folders: ${policy_folders[@]}"
>&2 echo "separator: '$separator'"

# execute conftest
# if [[ ${#policy_folders[@]} > 0 ]];then
>&2 echo "executing 'conftest test $input_file ${policy_folders[@]/#/"-p "} --no-color'"
conftest test $input_file ${policy_folders[@]/#/"-p "} --no-color
# else
#     >&2 echo "no policy folders found - skipping conftest for $input_file"
# fi
