#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/ModuleCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/ModuleCache"
swift run --disable-sandbox MouseCoreChecks
swiftc -module-cache-path "$CLANG_MODULE_CACHE_PATH" \
    Sources/WhereIsMyMouse/Settings.swift Sources/WhereIsMyMouse/GuideAppearance.swift \
    Tests/SettingsTests/main.swift -o .build/SettingsChecks
.build/SettingsChecks
