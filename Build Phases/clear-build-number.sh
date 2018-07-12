#!/bin/bash

set -x
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 0" "${PRODUCT_SETTINGS_PATH}"
echo "Cleared build number in ${PRODUCT_SETTINGS_PATH}"
