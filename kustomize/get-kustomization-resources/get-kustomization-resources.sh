    #!/bin/bash
set -e

DEFAULT_SEPARATOR=' '

kustomization_yml="$1"
separator="${2:-$DEFAULT_SEPARATOR}"

result=()

kustomization_root=$(dirname $kustomization_yml)

while IFS= read -r resource; do
    if [[ ! -d "$kustomization_root/$resource" ]]; then
        result+=("$kustomization_root/$resource")
    fi
done <<<$(yq e -o=j -I=0 '.resources[]' "${kustomization_yml}" | tr -d \")

echo "${result[@]}" | tr "$separator" '\n' | sort -u | tr '\n' "$separator" | xargs






