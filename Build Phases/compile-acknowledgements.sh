#!/bin/bash

set -x
source ~/.bash_profile
if [[ ! $CONFIGURATION =~ "Release" ]]; then
    bundle exec $SRCROOT/Build\ Phases/compile-acknowledgements.rb
fi
