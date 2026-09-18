#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

app="$PWD/dist/Where is My Mouse.app"
archive="Where-is-My-Mouse-macOS-universal.zip"
lipo "$app/Contents/MacOS/WhereIsMyMouse" -verify_arch arm64 x86_64
codesign --verify --deep --strict "$app"
plutil -lint "$app/Contents/Info.plist"

# Zip the bundle before upload-artifact, which otherwise loses executable bits.
ditto -c -k --sequesterRsrc --keepParent "$app" "$PWD/dist/$archive"
unzip -t "$PWD/dist/$archive"
(cd dist && shasum -a 256 "$archive" > "$archive.sha256")

# Check the deliverable, not just the bundle that preceded it.
verification="$(mktemp -d "$PWD/dist/.archive-check.XXXXXX")"
trap 'rm -rf "$verification"' EXIT
ditto -x -k "$PWD/dist/$archive" "$verification"
test -x "$verification/Where is My Mouse.app/Contents/MacOS/WhereIsMyMouse"
lipo "$verification/Where is My Mouse.app/Contents/MacOS/WhereIsMyMouse" -verify_arch arm64 x86_64
codesign --verify --deep --strict "$verification/Where is My Mouse.app"
printf 'Packaged: %s\n' "$PWD/dist/$archive"
