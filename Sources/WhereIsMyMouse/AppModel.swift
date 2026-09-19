import AppKit
import ApplicationServices
import Combine
import MouseCore
import ServiceManagement

enum SettingsPage: String, CaseIterable, Identifiable {
    case overview = "Overview", locate = "Locate pointer", crossing = "Cross displays", alignment = "Align monitors", general = "General"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .overview: return "square.grid.2x2"
        case .locate: return "scope"
        case .crossing: return "arrow.right.to.line"
        case .alignment: return "line.3.horizontal"
        case .general: return "gearshape"
        }
    }
}

final class AppModel: ObservableObject {
    let settings: Settings
    let displays = DisplayManager()
    private let mouse = MouseMonitor()
    private let hotKeys = HotKeys()
    let permissionSetup = PermissionSetupController()
    lazy var overlays = OverlayController(displays: displays, settings: settings)
    @Published var selectedPage: SettingsPage = .overview
    @Published private(set) var inputAllowed = false
    @Published private(set) var accessibilityAllowed = false
    @Published private(set) var monitoring = false
    @Published private(set) var loginEnabled = false
    @Published private(set) var loginNeedsApproval = false
    @Published var notice: String?
    var onStateChange: (() -> Void)?
    private var shake = ShakeDetector()
    private var edge = StuckEdgeDetector()
    private var permissionTimer: Timer?
    private var subscriptions: Set<AnyCancellable> = []
    private var observers: [NSObjectProtocol] = []
    private var sleeping = false
    private var permissionFlow = FeaturePermissionFlow()

    init(settings: Settings = Settings()) { self.settings = settings }

    private var permissions: MousePermissions {
        MousePermissions(inputMonitoring: inputAllowed, accessibility: accessibilityAllowed)
    }
    var locateReady: Bool { settings.locateEnabled && permissions.missing(for: .locate) == nil }
    var crossingReady: Bool { settings.crossingEnabled && permissions.missing(for: .crossing) == nil }

    var status: String {
        if settings.paused { return "Paused" }
        if !settings.locateEnabled && !settings.crossingEnabled { return "Helpers switched off" }
        if !inputAllowed { return "Input Monitoring needed" }
        if settings.crossingEnabled && !accessibilityAllowed { return "Accessibility needed" }
        if !monitoring { return "Setup needed" }
        return "Ready when you are"
    }

    func start() {
        overlays.rebuild()
        displays.onChange = { [weak self] in
            guard let self else { return }
            self.shake.reset(); self.edge.reset()
            self.overlays.rebuild(); self.onStateChange?()
        }
        mouse.onMotion = { [weak self] sample, dragging in self?.handle(sample, dragging: dragging) }
        mouse.onInterrupted = { [weak self] in self?.shake.reset(); self?.edge.reset() }
        settings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async { self?.settingsChanged() }
        }.store(in: &subscriptions)
        hotKeys.onLocate = { [weak self] in self?.locate() }
        hotKeys.onGuides = { [weak self] in self?.toggleGuides() }
        if !hotKeys.register() { notice = "A keyboard shortcut is already in use. You can still use every feature from the menu bar." }
        refreshPermissions()
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.refreshPermissions() }
        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.screensDidSleepNotification, NSWorkspace.sessionDidResignActiveNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                guard let self else { return }
                self.sleeping = true; self.mouse.stop(); self.overlays.suspend()
                self.shake.reset(); self.edge.reset(); self.monitoring = false
            })
        }
        for name in [NSWorkspace.didWakeNotification, NSWorkspace.screensDidWakeNotification, NSWorkspace.sessionDidBecomeActiveNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.sleeping = false; self?.overlays.resume(); self?.refreshPermissions()
            })
        }
    }

    private func settingsChanged() {
        shake.reset(); edge.reset()
        if settings.paused { overlays.clearAnimations() }
        overlays.settingsChanged()
        refreshPermissions()
        objectWillChange.send()
        onStateChange?()
    }

    private func handle(_ sample: MotionSample, dragging: Bool) {
        guard !settings.paused, !sleeping else { return }
        // Do not teleport a drag, selected text, or a resize gesture.
        guard !dragging else { shake.reset(); edge.reset(); return }
        if locateReady && shake.consume(sample, sensitivity: settings.shakeSensitivity) { overlays.locate() }
        if crossingReady,
           let crossing = edge.consume(sample, displays: displays.displays, resistance: settings.edgeResistance) {
            let result = CGWarpMouseCursorPosition(crossing.destination)
            if result == .success {
                shake.reset()
                if settings.enlargeEnabled { overlays.enlarge(at: crossing.destination) }
            } else {
                notice = "macOS could not move the pointer. Check Accessibility access in General."
            }
        }
    }

    func refreshPermissions() {
        let previousStatus = status
        let input = CGPreflightListenEventAccess()
        let access = AXIsProcessTrusted()
        if inputAllowed != input { inputAllowed = input }
        if accessibilityAllowed != access { accessibilityAllowed = access }
        settings.migrateFeaturePermissions(inputMonitoring: input, accessibility: access)
        let needsMotion = locateReady || crossingReady
        if !sleeping && !settings.paused && needsMotion { _ = mouse.start() }
        else { mouse.stop() }
        if monitoring != mouse.isRunning { monitoring = mouse.isRunning; onStateChange?() }
        let loginStatus = SMAppService.mainApp.status
        let enabled = loginStatus == .enabled
        let approval = loginStatus == .requiresApproval
        let loginChanged = loginEnabled != enabled || loginNeedsApproval != approval
        if loginEnabled != enabled { loginEnabled = enabled }
        if loginNeedsApproval != approval { loginNeedsApproval = approval }
        if loginChanged { onStateChange?() }
        if previousStatus != status { onStateChange?() }
        let wasWaiting = permissionFlow.isWaiting
        let next = permissionFlow.permissionsChanged(permissions)
        if let next { presentPermission(next) }
        else if wasWaiting && !permissionFlow.isWaiting { permissionSetup.close() }
    }

    func setLocateEnabled(_ enabled: Bool) { setFeature(.locate, enabled: enabled) }
    func setCrossingEnabled(_ enabled: Bool) { setFeature(.crossing, enabled: enabled) }

    private func setFeature(_ feature: MouseFeature, enabled: Bool) {
        if !enabled { permissionFlow.cancel(feature) }
        // Refresh before changing preferences so the one-time legacy migration
        // cannot erase the user's new opt-in.
        refreshPermissions()
        if feature == .locate { settings.locateEnabled = enabled }
        else { settings.crossingEnabled = enabled }
        if enabled {
            if let permission = permissionFlow.begin(feature, permissions: permissions) {
                selectedPage = .general
                presentPermission(permission)
            }
        } else {
            permissionFlow.cancel(feature)
            if !permissionFlow.isWaiting { permissionSetup.close() }
        }
        onStateChange?()
    }

    private func presentPermission(_ permission: MousePermission) {
        switch permission {
        case .inputMonitoring: requestInput()
        case .accessibility: requestAccessibility()
        }
    }
    func requestInput() {
        _ = CGRequestListenEventAccess()
        showPermissionHelp(.inputMonitoring)
    }
    func requestAccessibility() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
        showPermissionHelp(.accessibility)
    }
    func showPermissionHelp(_ permission: PrivacyPermission) {
        permissionSetup.show(permission)
        permission.openSettings()
    }
    func setLogin(_ enabled: Bool) {
        do {
            let service = SMAppService.mainApp
            // Registration is an OS setting, not a UserDefaults flag. Repeating
            // an already-satisfied request must not throw "already registered".
            if enabled && service.status != .enabled && service.status != .requiresApproval {
                try service.register()
            } else if !enabled && service.status != .notRegistered {
                try service.unregister()
            }
            refreshPermissions()
            if loginNeedsApproval { SMAppService.openSystemSettingsLoginItems() }
        } catch { notice = "Could not change launch at login: \(error.localizedDescription)"; refreshPermissions() }
    }
    func locate() { if !settings.paused { overlays.locate() } }
    func previewPointer() {
        if !settings.paused { overlays.enlarge(at: CGEvent(source: nil)?.location ?? .zero) }
    }
    func toggleGuides() {
        if settings.paused { settings.paused = false }
        settings.guidesVisible.toggle()
    }
    func stop() {
        permissionTimer?.invalidate()
        mouse.stop(); overlays.stop()
        permissionSetup.close()
        for observer in observers { NSWorkspace.shared.notificationCenter.removeObserver(observer) }
        observers.removeAll()
    }
}
