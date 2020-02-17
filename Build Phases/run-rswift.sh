#!/bin/bash

set -x
"$PODS_ROOT/R.swift/rswift" generate --rswiftignore "$SRCROOT/iOS/.rswiftignore" "$SRCROOT/iOS/R.generated.swift"
