#!/bin/bash

set -x
if [ $ACTION != "indexbuild" ]; then
  "Pods/R.swift/rswift" generate --rswiftignore "$SRCROOT/iOS/.rswiftignore" "$SRCROOT/iOS/R.generated.swift"
fi
