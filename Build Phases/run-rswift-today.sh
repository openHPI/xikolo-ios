#!/bin/bash

set -x
"$PODS_ROOT/R.swift/rswift" generate --rswiftignore "$SRCROOT/TodayExtension/.rswiftignore" "$SRCROOT/TodayExtension/R.generated.swift"
