#!/bin/bash

set -x
source ~/.bash_profile
bundle exec $SRCROOT/Build\ Phases/compile-acknowledgements.rb
