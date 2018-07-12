#!/bin/bash

set -x
if [[ "${CONFIGURATION}" == *Release ]]; then
    suffix="Release"
else
    suffix="Debug"
fi

echo "Using GoogleService-Info.plist for ${suffix} mode"
cp "${PROJECT_DIR}/iOS/Branding/${PRODUCT_NAME}/GoogleService-Info-${suffix}.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
