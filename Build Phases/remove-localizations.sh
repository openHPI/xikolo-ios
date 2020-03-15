#!/bin/bash

set -x
if [ "${BRAND_NAME}" == "openSAP" ]; then
    rm -r "${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app/de.lproj"
fi
