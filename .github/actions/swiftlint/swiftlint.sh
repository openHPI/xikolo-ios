#!/bin/bash

changedFiles=$(git --no-pager diff --diff-filter=d --name-only FETCH_HEAD $(git merge-base $BASED_REF $HEAD_REF) -- '*.swift')

if [ -z "$changedFiles" ]
then
    echo "No Swift files changed"
    exit 0
fi

set -o pipefail && swiftlint "$@" --strict --reporter github-actions-logging -- $changedFiles
