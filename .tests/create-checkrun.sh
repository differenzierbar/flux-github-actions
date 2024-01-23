#!/bin/bash

set -eEuo pipefail

here=`dirname $(realpath $0 --relative-to .)`

GITHUB_TOKEN=$1
GIT_SHA=$2
name=$3
# conclusion=$4
# summary=$5
# text=$6
shift 3

>&2 echo "GITHUB_TOKEN: $GITHUB_TOKEN"
>&2 echo "GIT_SHA: $GIT_SHA"
>&2 echo "name: $name"
>&2 echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"


shellscript magic to save stdout & stderr to variables following https://stackoverflow.com/a/18086548
unset t_std t_err t_ret
eval "$( ($@) \
        2> >(t_err=$(cat); typeset -p t_err) \
         > >(t_std=$(cat); typeset -p t_std); t_ret=$?; typeset -p t_ret )"

if [ "$t_ret" -eq 0 ]; then
    conclusion="success"
    summary=$(echo "'$@' output" | jq -Rsa .)

    # json escape output
    text=$(echo "$t_std" | jq -Rsa .)
else
    # echo "FAIL: $t_err"
    conclusion="failure"
    summary=$(echo "'$@' failed" | jq -Rsa .)

    # json escape output
    text=$(echo "$t_std" | jq -Rsa .)
fi

>&2 echo "conclusion: $conclusion"
>&2 echo "summary: $summary"
>&2 echo "text: $text"

$here/../github/create-checkrun/create-checkrun.sh "$GITHUB_TOKEN" "$GIT_SHA" "'$name'" "$conclusion" "$summary" "$text"
