#!/bin/bash
set -e

git diff $(git merge-base HEAD origin/$GITHUB_BASE_REF) --name-only
