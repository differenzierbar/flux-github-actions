#!/bin/bash
set -e

declare -A kustomization_changes=()
declare -A changes_map=()



# changes=$1
# ref=$1
kustomizations_root=$1
# pushd $2
# changes=$(git diff $(git merge-base HEAD $ref) --name-only)
# popd



# >&2 echo "pwd: $(pwd)"
# >&2 echo "kustomizations_root: $kustomizations_root"

# changes=$(git diff $(git merge-base HEAD origin/$GITHUB_BASE_REF) --name-only)
while IFS= read -r change; do
    changes_map[$change]="1"
    changes_map[$(dirname $change)]="1"
#     echo $change
#     # echo $(dirname $change)/kustomization.yaml
#     if [[ "${change##*/}" == "kustomization.yaml" ]];then
#         # echo kustomization.yaml itself has changed
#         kustomization_changes[$(realpath --relative-to $kustomizations_root $kustomizations_root/$(dirname $change))]="1"
#     elif [[ -f "$(dirname $change)/kustomization.yaml" ]];then
#         echo "kustomization.yaml in directory"
#         # check if the kustomization.yaml references the change
#         # FIXME do this not only for the kustomization in the current dir
#         change_in_kustomization=$(cat $(dirname $change)/kustomization.yaml | yq ".resources[] | select(. == \"$(realpath --relative-to $(dirname $change) $change)\")")
#         # echo "change_in_kustomization: $change_in_kustomization"
#         if [[ "$change_in_kustomization" != "" ]]; then
#             # echo "adding kustomization to changes $(dirname $change)/kustomization.yaml"
#             kustomization_changes[$(realpath --relative-to $kustomizations_root $kustomizations_root/$(dirname $change))]="1"
#         fi
#     elif [[ "$change" =~ .*\.ya?ml ]]; then
#         echo "no kustomization.yaml: $kustomizations_root/$(dirname $change)"
#         kustomization_changes[$(realpath --relative-to $kustomizations_root $kustomizations_root/$(dirname $change))]="1"
#     fi
done <<< "${GIT_CHANGES}"

# function kustomization_yaml {
    # echo "Parameter #1 is $1"
    # echo "Parameter #2 is $2"
    # echo "Parameter #3 is $3"
    # declare -n ma=$2

    # eval "declare -A visited_$3="${2#*=}
    # eval "declare -A ma="${2#*=}
    # proof that array was successfully created
    # declare -p ma
    # declare -n "data_ref_$3"=$2
    # data_ref[b]="Barney Rubble"

    # echo ${data_ref[a]} ${data_ref[b]}

    # va=$1
    # i=$3
    # # ma=$2
    # echo "data_ref: ${$2[@]}"
    # if [[ ! ${"data_ref_$3"["$1"]} ]]; then 
    # # if [[ ! " ${ma[*]} " =~ " $va " ]]; then
    #     # ma+=( $1 )
    #     data_ref[$1]="1"
    #     echo "ma: ${!"data_ref_$3"[@]}"
    #     let "i++"
    #     # ma+=($1)
    #     # echo "ma: ${ma[@]}"
    #     kustomization_yaml "test" $2 i
    # fi
# }


kustomization_yaml()
{
    # local kustomization_yaml=$1 name=$2"[@]"
    # local -a 'arraykeys=("${!'"$2"'[@]}")' 'lettersElements=(${!name})' visited
    # echo "x: $x"
    # echo ""
    # for ((i=0; i<${#lettersElements[*]}; i++));
    # do
    #     visited[${arraykeys[$i]}]=${lettersElements[$i]}
    # done
    # visited[$x]="test_$x"
    # visited[(2*$x)]=$x
    # if [ $1 -lt 5 ]
    # echo ${visited[@]} "|" ${!visited[@]}
    # if [[ ! ${visited[test]+exists} ]];
    # then
    #     visited["test"]="1"
    #     echo ${visited[@]} "|" ${!visited[@]}
    #     kustomization_yaml "test" visited
    # fi
    # # echo ${visited[@]}
    # echo ${visited[@]} "|" ${!visited[@]}
#     apiVersion: kustomize.config.k8s.io/v1beta1
# kind: Kustomization
# resources:
# - configmap.yml
    # resources=$(yq -N eval-all '.resources' $1)
    # local -a changes_map=(${!changes_map[@]})
    # local -A changes_map=(${name})
    local -n changes_map_local=$3
    result=()
    # echo "2: $2"
    >&2 echo "changes_map: ${!changes_map_local[@]}"
    while IFS= read -r resource; do
        # echo "resource: $resource"
        if [[ "$resource" =~ .*?\.ya?ml ]]; then
            resource_path="$(realpath --relative-to $1 $1/$2/$resource)"
            >&2 echo "checking changes : $resource_path"
            >&2 echo "checking changes : ${changes_map_local[$resource_path]}"
            if [[ "${changes_map_local[$resource_path]+exists}" ]]; then
                result+=($resource_path)
                >&2 echo "result: $result"
            fi
        else
            child_result=$(kustomization_yaml $1 "$2/$resource" changes_map)
            >&2 echo "child_result: $child_result"
            result+=($child_result)
            # >&2 echo "joined result: $result"
        fi
        # if [[ -f "$(realpath $(dirname $1/$2))/kustomization.yaml" ]];then
    done <<<$(yq e -o=j -I=0 '.resources[]' "$1/$2/kustomization.yaml" | tr -d \")
    kustomization_yaml_path="$(realpath --relative-to $1 $1/$2/kustomization.yaml)"
    # >&2 echo "checking kustomization.yaml changes : $kustomization_yaml_path"
    if [[ "${changes_map_local[$kustomization_yaml_path]+exists}" ]]; then
        >&2 echo "kustomization.yaml changed: $kustomization_yaml_path"
        result+=($kustomization_yaml_path)
    fi

    echo ${result[@]}
}

# echo done
# exit 0

# function foo {
#     local -n data_ref=$1
#     data_ref[b]="Barney Rubble"

#     echo ${data_ref[a]} ${data_ref[b]}
# }

# declare -A data
# data[a]="Fred Flintstone"
# # data[b]="Barney Rubble"
# foo data

# echo ${!kustomization_changes[@]}
flux_kustomization_files=$(find $kustomizations_root -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | filename' {} +)
>&2 echo "flux_kustomizations: $flux_kustomization_files"
result=()
while IFS= read -r kustomization_file; do
    >&2 echo "kustomizations_file: $kustomization_file"

    # kustomization_file_relative=$(realpath --relative-to $kustomizations_root $kustomizations_root/$kustomization_file)
    # echo $(realpath --relative-to . $kustomization)
    # >&2 echo "kustomizations_root: $kustomizations_root"
    # >&2 echo "kustomization: $kustomization"
    # if [[ ${kustomization_changes[$(realpath --relative-to $kustomizations_root $kustomizations_root/$kustomization)]} ]]; then result+=($kustomization); fi    # Exists
    # if ()
    kustomization_file_path="$(realpath --relative-to $kustomizations_root $kustomizations_root/$kustomization_file)"

    if [[ "${changes_map[$kustomization_file_path]+exists}" ]]; then
        # the flux kustomization object has been changed -> the complete tree (path this file points to) needs to be validated
        result+=($(yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' "$kustomizations_root/$kustomization_file"))
    else
        kustomization_path=$(yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' $kustomization_file)
        >&2 echo "kustomization_path: $kustomization_path"
        if [[ -f "$kustomizations_root/$kustomization_path/kustomization.yaml" ]];then
            # validate the existing kustomization tree recursively
            # declare -A marray
            # marray[a]="test"
            # kustomization_yaml "$kustomization_path/kustomization.yaml" marray 0
            # declare -A visited=()
            changes=($(kustomization_yaml $kustomizations_root "$kustomization_path" changes_map)) # visited
            if [ ${#changes[@]} -gt 0 ]; then
                result+=($kustomization_path)
            fi
            >&2 echo "result: ${result[@]}"

        else
            # autogenerated kustomization.yaml by flux including all yaml files in the current directory
            if [[ "${changes_map[$kustomization_path]+exists}" ]]; then
                result+=($kustomization_path)
            fi
        fi
    fi
    # kustomization_path=$(find $kustomizations_root -name "*.yml" -exec yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | filename' {} +)

    

done <<< "${flux_kustomization_files}"

echo ${result[@]}

# while IFS= read -r kustomization; do
#     { kustomize_err="$( { kustomize build $kustomization; } 2>&1 1> /dev/null)"; } || echo "kustomize build $kustomization failed: $kustomize_err"
    
# done <<< "${result}"




