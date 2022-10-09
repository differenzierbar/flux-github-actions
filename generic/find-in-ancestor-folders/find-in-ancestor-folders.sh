#!/bin/bash
set -e

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

top="$1"
start="$2"
pattern="$3"
type="${4:-"d"}"

>&2 echo "top: $top"
>&2 echo "start: $start"
>&2 echo "pattern: $pattern"
>&2 echo "type: $type"

result=()
path="$start"
while : ; do
    result+=($(find "$top/$path" -maxdepth 1 -mindepth 1 -regex "$top/$path/$pattern" -type $type -exec realpath --relative-to $top {} +))
    [[ "$(readlink -f $top/$path)" != $(readlink -f $top) ]] && [[ "$(readlink -f $path)" != "/" ]] || break
    path="$(realpath --relative-to $top $(readlink -f $top/$path/../))"
done

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs
