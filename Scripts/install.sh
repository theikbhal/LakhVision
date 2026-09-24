#!/bin/bash
set -e

APP_NAME="LakhVision"
APP_PATH="build/$APP_NAME.app"
INSTALL_PATH="/Applications/$APP_NAME.app"

echo "Installing $APP_NAME..."

./Scripts/build.sh

if [ -d "$APP_PATH" ]; then
    rm -rf "$INSTALL_PATH"
    cp -R "$APP_PATH" "$INSTALL_PATH"
    echo "Installed to $INSTALL_PATH"
else
    echo "Build not found."
    exit 1
fi

open "$INSTALL_PATH"
echo "Opened $INSTALL_PATH"
