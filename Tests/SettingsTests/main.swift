import Foundation

var failures = 0
var assertions = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    assertions += 1
    if !condition() { failures += 1; print("FAIL: \(message)") }
}
func withDefaults(_ run: (UserDefaults) -> Void) {
    let name = "com.inbedsoft.WhereIsMyMouse.settings-check.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer { defaults.removePersistentDomain(forName: name) }
    run(defaults)
}

withDefaults { defaults in
    let settings = Settings(defaults: defaults)
    check(!settings.locateEnabled, "Fresh shake setting must be off")
    check(!settings.crossingEnabled, "Fresh crossing setting must be off")
    settings.migrateFeaturePermissions(inputMonitoring: true, accessibility: true)
    check(!settings.locateEnabled && !settings.crossingEnabled, "Permissions alone must not opt in")
}
withDefaults { defaults in
    defaults.set(true, forKey: "locate")
    defaults.set(true, forKey: "crossing")
    defaults.set(7, forKey: "guideThickness")
    let settings = Settings(defaults: defaults)
    settings.migrateFeaturePermissions(inputMonitoring: false, accessibility: false)
    check(!settings.locateEnabled && !settings.crossingEnabled, "Clear unusable legacy defaults")
    check(settings.guideThickness == 7, "Preserve unrelated settings")
    settings.locateEnabled = true
    let reopened = Settings(defaults: defaults)
    reopened.migrateFeaturePermissions(inputMonitoring: false, accessibility: false)
    check(reopened.locateEnabled, "Remember explicit opt-in while macOS requests a restart")
    check(!reopened.crossingEnabled, "Never opt in the other feature")
}
withDefaults { defaults in
    defaults.set(true, forKey: "locate")
    defaults.set(true, forKey: "crossing")
    let settings = Settings(defaults: defaults)
    settings.migrateFeaturePermissions(inputMonitoring: true, accessibility: false)
    check(settings.locateEnabled, "Keep a working locator enabled")
    check(!settings.crossingEnabled, "Clear crossing when Accessibility is missing")
}
withDefaults { defaults in
    defaults.set(true, forKey: "locate")
    defaults.set(true, forKey: "crossing")
    let settings = Settings(defaults: defaults)
    settings.migrateFeaturePermissions(inputMonitoring: true, accessibility: true)
    check(settings.locateEnabled && settings.crossingEnabled, "Preserve working installations")
}
print("Settings checks: \(assertions) assertions, \(failures) failures")
exit(failures == 0 ? EXIT_SUCCESS : EXIT_FAILURE)
