#!/bin/bash
set -e

kustomization_file=$1

yq -N eval-all '. | select(.kind == "Kustomization" and .apiVersion == "kustomize.toolkit.fluxcd.io/v1beta2") | .spec.path' "$kustomization_file"
