#!/bin/bash
set -e

APP_NAME="LakhVision"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "Building $APP_NAME..."

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

swift build -c release --package-path .

BINARY_PATH=$(find .build -name "$APP_NAME" -type f -perm +111 2>/dev/null | head -1)

if [ -z "$BINARY_PATH" ]; then
    echo "Build failed."
    exit 1
fi

cp "$BINARY_PATH" "$MACOS_DIR/$APP_NAME"
cp Resources/Info.plist "$CONTENTS_DIR/Info.plist"
echo -n "APPL????" > "$CONTENTS_DIR/PkgInfo"
chmod +x "$MACOS_DIR/$APP_NAME"

if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

codesign --force -s - "$APP_BUNDLE" 2>/dev/null || true

echo "Build complete: $APP_BUNDLE"
