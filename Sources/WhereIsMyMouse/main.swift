import AppKit
import SwiftUI
import Carbon
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    let model: AppModel
    private let defaults: UserDefaults
    private let smokeDefaultsName: String?
    private var statusItem: NSStatusItem!
    private var window: NSWindow?

    override init() {
        if CommandLine.arguments.contains("--smoke-test") {
            let name = "com.inbedsoft.WhereIsMyMouse.smoke.\(UUID().uuidString)"
            smokeDefaultsName = name
            defaults = UserDefaults(suiteName: name)!
        } else {
            smokeDefaultsName = nil
            defaults = .standard
        }
        model = AppModel(settings: Settings(defaults: defaults))
        super.init()
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        // LSUIElement in the bundle and accessory policy both keep this utility
        // out of the Dock, including while the settings window is open.
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.inbedsoft.WhereIsMyMouse"
        if !CommandLine.arguments.contains("--smoke-test"),
           let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) {
            running.activate(options: [.activateAllWindows])
            NSApp.terminate(nil)
            return
        }
        buildMainMenu()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.autosaveName = "WhereIsMyMouse.StatusItem"
        statusItem.isVisible = true
        statusItem.button?.image = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "Where is My Mouse?")
        statusItem.button?.image?.isTemplate = true
        statusItem.button?.toolTip = "Where is My Mouse?"
        model.onStateChange = { [weak self] in self?.updateMenu() }
        model.start()
        // Explicit opt-in used by local installation; ordinary launches never
        // silently change the user's login-item preference.
        if CommandLine.arguments.contains("--enable-login") { model.setLogin(true) }
        updateMenu()
        let event = NSAppleEventManager.shared().currentAppleEvent
        let launchedAtLogin = event?.paramDescriptor(forKeyword: AEKeyword(keyAEPropData))?.enumCodeValue == OSType(keyAELaunchedAsLogInItem)
        let firstLaunch = !defaults.bool(forKey: "hasLaunched")
        let explicitSettings = CommandLine.arguments.contains("--settings") || CommandLine.arguments.contains("--smoke-test")
        if explicitSettings || (firstLaunch && !launchedAtLogin && !CommandLine.arguments.contains("--background")) {
            if CommandLine.arguments.contains("--enable-login") { model.selectedPage = .general }
            showSettings()
            defaults.set(true, forKey: "hasLaunched")
        }
        if let index = CommandLine.arguments.firstIndex(of: "--runtime-report"), CommandLine.arguments.count > index + 1 {
            let path = CommandLine.arguments[index + 1]
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in self?.writeRuntimeReport(to: path) }
        }
        if let index = CommandLine.arguments.firstIndex(of: "--smoke-test"), CommandLine.arguments.count > index + 1 {
            runSmokeTest(directory: CommandLine.arguments[index + 1])
        }
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings(); return true
    }
    func applicationWillTerminate(_ notification: Notification) {
        model.stop()
        if let smokeDefaultsName { defaults.removePersistentDomain(forName: smokeDefaultsName) }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationShouldSaveApplicationState(_ app: NSApplication) -> Bool { false }
    func applicationShouldRestoreApplicationState(_ app: NSApplication) -> Bool { false }

    private func buildMainMenu() {
        let menu = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Settings…", action: #selector(showSettings), keyEquivalent: ",").target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Where is My Mouse?", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        menu.addItem(appItem)
        let editItem = NSMenuItem()
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = edit; menu.addItem(editItem)
        NSApp.mainMenu = menu
    }
    private func updateMenu() {
        guard statusItem != nil else { return }
        let menu = NSMenu()
        menu.autoenablesItems = false
        let title = menu.addItem(withTitle: "Where is My Mouse?", action: nil, keyEquivalent: "")
        title.isEnabled = false
        let state = menu.addItem(withTitle: "\(model.status) · \(model.displays.monitors.count) displays", action: nil, keyEquivalent: "")
        state.isEnabled = false
        menu.addItem(.separator())
        let locate = add(menu, "Locate pointer", #selector(locatePointer), key: "l")
        locate.keyEquivalentModifierMask = [.control, .option, .command]
        locate.isEnabled = !model.settings.paused
        let shake = add(menu, "Shake to locate", #selector(toggleLocate))
        shake.state = model.locateReady ? .on : model.settings.locateEnabled ? .mixed : .off
        shake.toolTip = "A dash means permission setup is pending. Click again to cancel."
        let crossing = add(menu, "Help crossing displays", #selector(toggleCrossing))
        crossing.state = model.crossingReady ? .on : model.settings.crossingEnabled ? .mixed : .off
        crossing.toolTip = shake.toolTip
        menu.addItem(.separator())
        let guides = add(menu, "Alignment guides", #selector(toggleGuides), key: "a")
        guides.keyEquivalentModifierMask = [.control, .option, .command]
        guides.state = model.settings.guidesVisible ? .on : .off
        add(menu, model.settings.paused ? "Resume helpers" : "Pause helpers", #selector(togglePause))
        menu.addItem(.separator())
        let login = add(menu, "Launch at login", #selector(toggleLogin))
        login.state = model.loginNeedsApproval ? .mixed : model.loginEnabled ? .on : .off
        add(menu, "Settings…", #selector(showSettings), key: ",")
        // A standard terminate: action gains an automatic icon on Tahoe,
        // indenting this section alone. Keep the status menu uniformly text-only.
        add(menu, "Quit Where is My Mouse?", #selector(quitHelper), key: "q")
        statusItem.menu = menu
        statusItem.button?.appearsDisabled = model.settings.paused
    }
    @discardableResult private func add(_ menu: NSMenu, _ title: String, _ action: Selector, key: String = "") -> NSMenuItem {
        let item = menu.addItem(withTitle: title, action: action, keyEquivalent: key)
        item.target = self
        item.indentationLevel = 0
        return item
    }
    @objc private func locatePointer() { model.locate() }
    @objc private func toggleLocate() { model.setLocateEnabled(!model.settings.locateEnabled) }
    @objc private func toggleCrossing() { model.setCrossingEnabled(!model.settings.crossingEnabled) }
    @objc private func quitHelper() { NSApp.terminate(nil) }
    @objc private func toggleGuides() { model.toggleGuides() }
    @objc private func togglePause() { model.settings.paused.toggle() }
    @objc private func toggleLogin() { model.setLogin(!(model.loginEnabled || model.loginNeedsApproval)) }
    @objc func showSettings() {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 940, height: 710),
                                  styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
            window.title = "Where is My Mouse?"
            window.titlebarAppearsTransparent = true
            window.backgroundColor = NSColor(srgbRed: 0.97, green: 0.975, blue: 0.96, alpha: 1)
            window.minSize = NSSize(width: 900, height: 710)
            window.isReleasedWhenClosed = false
            window.isRestorable = false
            window.contentView = NSHostingView(rootView: SettingsView(model: model))
            window.center()
            self.window = window
        }
        model.refreshPermissions()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Development/install verification reads the actual running app's state.
    /// This does not change permissions, login preferences, or screen contents.
    private func writeRuntimeReport(to path: String) {
        model.refreshPermissions()
        let login: String
        switch SMAppService.mainApp.status {
        case .enabled: login = "enabled"
        case .requiresApproval: login = "requiresApproval"
        case .notRegistered: login = "notRegistered"
        case .notFound: login = "notFound"
        @unknown default: login = "unknown"
        }
        let report: [String: Any] = [
            "bundlePath": Bundle.main.bundlePath,
            "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
            "processID": ProcessInfo.processInfo.processIdentifier,
            "noDockIcon": NSApp.activationPolicy() == .accessory,
            "statusItemVisible": statusItem?.isVisible ?? false,
            "settingsVisible": window?.isVisible ?? false,
            "loginStatus": login,
            "inputMonitoring": model.inputAllowed,
            "accessibility": model.accessibilityAllowed,
            "mouseMonitoringActive": model.monitoring,
            "locateRequested": model.settings.locateEnabled,
            "crossingRequested": model.settings.crossingEnabled,
            "locateReady": model.locateReady,
            "crossingReady": model.crossingReady,
            "guideCount": model.settings.guideCount,
            "guideThickness": model.settings.guideThickness,
            "guideSpacing": model.settings.guideSpacing,
            "appDragFileURLValid": AppBundleDragSource.validateFileURLPayload(),
            "notice": model.notice ?? ""
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch { fputs("Runtime report failed: \(error)\n", stderr) }
    }

    /// Local development smoke test: exercise each native view and overlay,
    /// export only this app's views (no screen capture permission), then exit.
    private func runSmokeTest(directory: String) {
        let url = URL(fileURLWithPath: directory, isDirectory: true)
        do { try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
        catch { fputs("Smoke test output: \(error)\n", stderr); NSApp.terminate(nil); return }
        guard !model.settings.locateEnabled, !model.settings.crossingEnabled,
              let menu = statusItem.menu,
              menu.items.allSatisfy({ $0.indentationLevel == 0 }),
              menu.items.first(where: { $0.title == "Shake to locate" })?.state == .off,
              menu.items.first(where: { $0.title == "Help crossing displays" })?.state == .off,
              menu.items.last?.action == #selector(quitHelper) else {
            fputs("SMOKE FAIL: fresh feature defaults or status menu configuration.\n", stderr)
            model.stop(); exit(EXIT_FAILURE)
        }
        func capture(_ index: Int) {
            if index >= SettingsPage.allCases.count {
                guard AppBundleDragSource.validateFileURLPayload() else {
                    fputs("SMOKE FAIL: drag payload is not the running app's file URL.\n", stderr)
                    model.stop(); exit(EXIT_FAILURE)
                }
                // Exercise our own helper UI without opening privacy settings
                // or attempting to grant a permission during verification.
                model.permissionSetup.show(.inputMonitoring)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    do {
                        try model.permissionSetup.exportSnapshot(to: url.appendingPathComponent("5-Permission helper.png"))
                        model.permissionSetup.close()
                        model.settings.guidesVisible = true
                        model.overlays.settingsChanged()
                        try model.overlays.exportGuideSnapshots(to: url)
                    } catch {
                        fputs("SMOKE FAIL: \(error)\n", stderr)
                        model.stop(); exit(EXIT_FAILURE)
                    }
                    model.locate()
                    model.previewPointer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) { [self] in
                        model.settings.guidesVisible = false
                        model.overlays.settingsChanged()
                        print("SMOKE PASS: 5 settings views, floating permission helper, real app file-URL drag payload, colored guides, locator, pointer overlay, cleanup. Displays: \(model.displays.monitors.count). Input: \(model.inputAllowed). Accessibility: \(model.accessibilityAllowed).")
                        NSApp.terminate(nil)
                    }
                }
                return
            }
            model.selectedPage = SettingsPage.allCases[index]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                if let view = window?.contentView, let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) {
                    view.cacheDisplay(in: view.bounds, to: rep)
                    if let data = rep.representation(using: .png, properties: [:]) {
                        do { try data.write(to: url.appendingPathComponent("\(index)-\(model.selectedPage.rawValue).png")) }
                        catch { fputs("Snapshot write failed: \(error)\n", stderr) }
                    }
                }
                capture(index + 1)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { capture(0) }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
