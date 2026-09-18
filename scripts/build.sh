#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache"
configuration="${CONFIGURATION:-release}"
if [[ "${UNIVERSAL:-0}" == "1" ]]; then
    # Build each slice separately so Command Line Tools alone also work.
    slices=()
    for architecture in arm64 x86_64; do
        scratch="$PWD/.build/architectures/$architecture"
        swift build --disable-sandbox --scratch-path "$scratch" -c "$configuration" --arch "$architecture" --product WhereIsMyMouse
        bin_dir="$(swift build --disable-sandbox --scratch-path "$scratch" -c "$configuration" --arch "$architecture" --show-bin-path)"
        slices+=("$bin_dir/WhereIsMyMouse")
    done
    mkdir -p .build/universal
    executable="$PWD/.build/universal/WhereIsMyMouse"
    lipo -create "${slices[@]}" -output "$executable"
    lipo "$executable" -verify_arch arm64 x86_64
else
    swift build --disable-sandbox -c "$configuration" --product WhereIsMyMouse
    bin_dir="$(swift build --disable-sandbox -c "$configuration" --show-bin-path)"
    executable="$bin_dir/WhereIsMyMouse"
fi
mkdir -p dist
staging="$(mktemp -d "$PWD/dist/.bundle.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
app="$staging/Where is My Mouse.app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$executable" "$app/Contents/MacOS/WhereIsMyMouse"
chmod 755 "$app/Contents/MacOS/WhereIsMyMouse"
cp Resources/Info.plist "$app/Contents/Info.plist"
swift scripts/make-icon.swift "$PWD/.build/AppIcon.iconset"
iconutil -c icns "$PWD/.build/AppIcon.iconset" -o "$app/Contents/Resources/AppIcon.icns"
# Supply Developer ID Application identity via SIGNING_IDENTITY for distribution.
# Ad-hoc signing is suitable for a local build; notarization is a separate step.
signing_args=(--force --sign "${SIGNING_IDENTITY:--}" --options runtime)
if [[ "${SIGNING_IDENTITY:--}" != "-" ]]; then signing_args+=(--timestamp); fi
codesign "${signing_args[@]}" "$app"
codesign --verify --deep --strict "$app"
plutil -lint "$app/Contents/Info.plist"
rm -rf "$PWD/dist/Where is My Mouse.app"
mv "$app" "$PWD/dist/Where is My Mouse.app"
printf 'Built: %s\n' "$PWD/dist/Where is My Mouse.app"
