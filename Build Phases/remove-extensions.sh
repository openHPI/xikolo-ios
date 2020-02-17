#!/bin/bash

set -x
if [ "${BRAND_NAME}" == "openWHO" ]; then
    rm -r "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app/Plugins/${PRODUCT_NAME}-today.appex"
fi


