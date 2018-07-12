#!/bin/bash

set -x
rm -rf ${PROJECT_DIR}/iOS/assets-ios-brand.generated.xcassets
cp -R ${PROJECT_DIR}/iOS/Branding/${PRODUCT_NAME}/assets-ios-brand.xcassets ${PROJECT_DIR}/iOS/assets-ios-brand.generated.xcassets
