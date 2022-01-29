#!/bin/bash

# Source: https://forums.swift.org/t/swift-packages-in-multiple-targets-results-in-this-will-result-in-duplication-of-library-code-errors/34892/67

movedFrameworks=()

# Nested Frameworks in Frameworks
cd "${CODESIGNING_FOLDER_PATH}/Frameworks/"
for framework in *; do
    if [ -d "$framework" ]; then
        if [ -d "${framework}/Frameworks" ]; then
            echo "Moving nested frameworks from ${framework}/Frameworks/ to ${PRODUCT_NAME}.app/Frameworks/"

            cd "${framework}/Frameworks/"
            for nestedFramework in *; do
                echo "- nested: ${nestedFramework}"
                movedFrameworks+=("${nestedFramework}")
            done
            cd ..
            cd ..

            cp -R "${framework}/Frameworks/" "${CODESIGNING_FOLDER_PATH}/Frameworks/"
            rm -rf "${framework}/Frameworks"
        fi
    fi
done

# Nested Frameworks in App Extensions
cd "${CODESIGNING_FOLDER_PATH}/Plugins/"
for plugin in *; do
    if [ -d "$plugin" ]; then
        if [ -d "${plugin}/Frameworks" ]; then

            cd "${plugin}/Frameworks/"
            for nestedFramework in *; do
                echo "Moving nested frameworks from ${plugin}/Frameworks/ to ${PRODUCT_NAME}.app/Frameworks/"
                echo "- nested: ${nestedFramework}"
                movedFrameworks+=("${nestedFramework}")
            done
            cd ..
            cd ..

            cp -R "${plugin}/Frameworks/" "${CODESIGNING_FOLDER_PATH}/Frameworks/"
            rm -rf "${plugin}/Frameworks"
        fi
    fi
done

cd "${CODESIGNING_FOLDER_PATH}/Frameworks/"

if [ "${CONFIGURATION}" == "Debug" ] & [ "${PLATFORM_NAME}" != "iphonesimulator" ] ; then
    for movedFramework in "${movedFrameworks[@]}"
    do
        codesign --force --deep --sign "${EXPANDED_CODE_SIGN_IDENTITY}" --preserve-metadata=identifier,entitlements --timestamp=none "${movedFramework}"
    done
else
    echo "Info: CODESIGNING is only needed for Debug on device (will be re-signed anyway when archiving) "
fi
