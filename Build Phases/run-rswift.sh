#!/bin/bash

set -x
"Pods/R.swift/rswift" generate --rswiftignore "$SRCROOT/iOS/.rswiftignore" "$SRCROOT/iOS/R.generated.swift"
