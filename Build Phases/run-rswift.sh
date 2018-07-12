#!/bin/bash

set -x
"$PODS_ROOT/R.swift/rswift" generate --rswiftignore "iOS/.rswiftignore" "$SRCROOT/iOS"
