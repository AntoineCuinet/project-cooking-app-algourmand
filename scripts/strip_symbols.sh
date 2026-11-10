#!/bin/bash
set -e

if [ "Release" = "${CONFIGURATION}" ]; then
    APP_DIR_PATH="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
    if [ -f "${APP_DIR_PATH}/${EXECUTABLE_NAME}" ]; then
        strip -rSTx "${APP_DIR_PATH}/${EXECUTABLE_NAME}"
    fi

    APP_FRAMEWORKS_DIR="${APP_DIR_PATH}/Frameworks"
    if [ -d "${APP_FRAMEWORKS_DIR}" ]; then
        find "${APP_FRAMEWORKS_DIR}" -type f -perm +111 -maxdepth 2 -mindepth 2 -exec bash -c 'codesign -v -R="anchor apple" "{}" &> /dev/null || (echo "{}" && strip -rSTx "{}")' \;
    fi
fi
