#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

XCODE_PROJECT="$REPO_ROOT/StoreKit2Framework/StoreKit2Framework.xcodeproj"
SCHEME="StoreKit2Framework"
CONFIGURATION="Release"

BUILD_DIR="$REPO_ROOT/.artifacts/xcframework-build"
OUTPUT_XCFRAMEWORK="$REPO_ROOT/MAUI.StoreKit2/StoreKit2Framework.xcframework"

IOS_ARCHIVE="$BUILD_DIR/ios"
SIM_ARCHIVE="$BUILD_DIR/iossim"

echo "Building iOS device framework archive..."
xcodebuild archive \
  -project "$XCODE_PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS" \
  -archivePath "$IOS_ARCHIVE" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  > /tmp/storekit2-ios-archive.log

echo "Building iOS simulator framework archive..."
xcodebuild archive \
  -project "$XCODE_PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$SIM_ARCHIVE" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  > /tmp/storekit2-iossim-archive.log

if [ -d "$OUTPUT_XCFRAMEWORK" ]; then
  echo "Removing existing XCFramework at $OUTPUT_XCFRAMEWORK"
  /usr/bin/find "$OUTPUT_XCFRAMEWORK" -mindepth 1 -delete
  /bin/rmdir "$OUTPUT_XCFRAMEWORK"
fi

echo "Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$IOS_ARCHIVE.xcarchive/Products/Library/Frameworks/StoreKit2Framework.framework" \
  -framework "$SIM_ARCHIVE.xcarchive/Products/Library/Frameworks/StoreKit2Framework.framework" \
  -output "$OUTPUT_XCFRAMEWORK" \
  > /tmp/storekit2-create-xcframework.log

echo "XCFramework created at $OUTPUT_XCFRAMEWORK"
echo "Available slices:"
/usr/bin/plutil -p "$OUTPUT_XCFRAMEWORK/Info.plist" | /usr/bin/grep -A 20 "AvailableLibraries"
