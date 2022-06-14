#!/bin/bash

changedFiles=$(git --no-pager diff --diff-filter=d --name-only $BASE_REF $HEAD_REF -- '*.swift')

if [ -z "$changedFiles" ]
then
    echo "No Swift files changed"
    exit 0
fi

echo $(pwd)
set -o pipefail && ./Pods/SwiftLint/swiftlint  "$@" --strict --config ./.swiftlint.yml --reporter github-actions-logging -- $changedFiles
