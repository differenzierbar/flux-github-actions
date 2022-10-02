#!/bin/bash
set -e

declare -A kustomization_changes=()
declare -A changes_map=()

kustomizations_root=$1
# shift

while IFS= read -r change; do
    changes_map[$change]="1"
    changes_map[$(dirname $change)]="1"
done <<< "${GIT_CHANGES}"

kustomization_yaml()
{
    local -n changes_map_local=$4
    result=()
    # echo "2: $2"
    >&2 echo "changes_map: ${!changes_map_local[@]}"
    while IFS= read -r resource; do
        # echo "resource: $resource"
        if [[ "$resource" =~ $2 ]]; then
            resource_path="$(realpath --relative-to $1 $1/$3/$resource)"
            >&2 echo "checking changes : $resource_path"
            >&2 echo "checking changes : ${changes_map_local[$resource_path]}"
            if [[ "${changes_map_local[$resource_path]+exists}" ]]; then
                result+=($resource_path)
                >&2 echo "result: $result"
            fi
        else
            child_result=$(kustomization_yaml $1 $2 "$3/$resource" changes_map)
            >&2 echo "child_result: $child_result"
            result+=($child_result)
            # >&2 echo "joined result: $result"
        fi
        # if [[ -f "$(realpath $(dirname $1/$2))/kustomization.yaml" ]];then
    done <<<$(yq e -o=j -I=0 '.resources[]' "$1/$3/kustomization.yaml" | tr -d \")
    kustomization_yaml_path="$(realpath --relative-to $1 $1/$3/kustomization.yaml)"
    # >&2 echo "checking kustomization.yaml changes : $kustomization_yaml_path"
    if [[ "${changes_map_local[$kustomization_yaml_path]+exists}" ]]; then
        >&2 echo "kustomization.yaml changed: $kustomization_yaml_path"
        result+=($kustomization_yaml_path)
    fi

    echo ${result[@]}
}

parent_directory()
{
    result=()
    kustomizations_root=$1
    path=$2
    local -n changes_map_local=$3

    while : ; do
        # echo $path
        policy_files+=($(find "$path/policy" -maxdepth 1 -mindepth 1 -type f))
        while IFS= read -r policy_file; do
            # resource_path="$(realpath --relative-to kustomizations_root $1/$3/$subdir)"
            if [[ "${changes_map_local[$policy_file]+exists}" ]]; then
                result+=($policy_file)
            fi
        done <<< "${policy_files}"
        [[ $path != $policy_parent_directory_top ]] && [[ $path != "/" ]] || break
        path="$(readlink -f "$path"/..)"
    done

    echo ${result[@]}
}


# echo ${!kustomization_changes[@]}
flux_kustomization_files=$(find $kustomizations_root -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | filename' {} +)
>&2 echo "flux_kustomizations: $flux_kustomization_files"
result=()

# while (( "$#" )); do
#     kustomization_file=$1
while IFS= read -r kustomization_file; do
    >&2 echo "kustomizations_file: $kustomization_file"

    >&2 echo "realpath --relative-to $kustomizations_root $kustomization_file"
    policy_path="$(realpath --relative-to $kustomizations_root $kustomization_file)/policy"

    if [[ "${changes_map[$policy_path]+exists}" ]]; then
        # policy change for the flux kustomization
        # FIXME parent directories
        result+=($kustomization_file)
    fi

    kustomization_paths=($(yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' $kustomization_file))
    >&2 echo "kustomization_paths: ${kustomization_paths[@]}"
    while IFS= read -r kustomization_path; do
        # kustomization_path=$(yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' $kustomization_file)
        >&2 echo "kustomizations_root: $kustomizations_root"
        >&2 echo "realpath --relative-to $kustomizations_root $kustomizations_root/$kustomization_path"
        kustomization_path_real="$(realpath --relative-to $kustomizations_root $kustomizations_root/$kustomization_path)"
        >&2 echo "kustomization_path_real: $kustomization_path_real"
        kustomization_path_abs="$(realpath $kustomizations_root/$kustomization_path)"
        
        if [[ -f "$kustomization_path_abs/kustomization.yaml" ]]; then
            # validate the existing kustomization tree recursively
            # declare -A marray
            # marray[a]="test"
            # kustomization_yaml "$kustomization_path/kustomization.yaml" marray 0
            # declare -A visited=()
            >&2 echo "calling kustomization_yaml $kustomizations_root $filename_pattern '$kustomization_path_real' changes_map"
            changes=($(kustomization_yaml $kustomizations_root $filename_pattern "$kustomization_path_real" changes_map)) # visited
            >&2 echo "changes: ${changes}"
            >&2 echo "changes: ${changes[@]}"
            if [ ${#changes[@]} -gt 0 ]; then
                result+=($kustomization_file)
            fi
            >&2 echo "result: ${result[@]}"

        else
            >&2 echo "$kustomization_path_abs/kustomization.yaml not found"
            >&2 echo "ls -la: $(ls -la $kustomization_path_abs/kustomization.yaml)"
            # autogenerated kustomization.yaml by flux including all yaml files in the current directory
            kustomization_policy_path = "$kustomization_path_real/policy"
            if [[ "${changes_map[$kustomization_policy_path]+exists}" ]]; then
                result+=($kustomization_file)
            else 
                subdirectories=$(find $kustomization_path_real -mindepth 2 -type d)
                while IFS= read -r subdirectory; do
                    >&2 echo "checking subdirectory: $subdirectory"

                    subdir_policy_path="$subdirectory/policy"

                    if [[ "${changes_map[$subdir_policy_path]+exists}" ]]; then
                        changed="true"
                        result+=($kustomization_file)
                        break
                    fi

                    >&2 echo "result: ${result[@]}"
                done <<< "${subdirectories}"

                if [[ changed != "true"]]; then
                    changes=($(parent_directory $kustomizations_root "$kustomization_path_real" changes_map)) # visited
                    >&2 echo "changes: ${changes}"
                    >&2 echo "changes: ${changes[@]}"
                    if [ ${#changes[@]} -gt 0 ]; then
                        result+=($kustomization_file)
                    fi
                fi

            fi
        fi
    done <<< "${kustomization_paths}"
    # kustomization_path=$(find $kustomizations_root -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | filename' {} +)
    # shift
# done
done <<< "${flux_kustomization_files}"

IFS=" " read -r -a result <<< "$(echo "${result[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
echo ${result[@]}
