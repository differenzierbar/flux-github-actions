#!/bin/bash

DEFAULT_SEPARATOR=' '
separator="${SEPARATOR:-$DEFAULT_SEPARATOR}"

left="$1"
right="$2"

>&2 echo "left: $left"
>&2 echo "right: $right"
>&2 echo "separator: '$separator'"

echo $(sort <(echo "$left"| tr "$separator" '\n') <(echo "$right"| tr "$separator" '\n') | uniq -d | tr '\n' "$separator") 
