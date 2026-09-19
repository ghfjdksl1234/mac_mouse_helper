import AppKit
import MouseCore

struct Monitor: Identifiable {
    let id: CGDirectDisplayID
    let name: String
    let screen: NSScreen
    let display: Display
    let physicalHeight: Double
    let number: Int
    var hasPhysicalSize: Bool { physicalHeight > 0 }
}

final class DisplayManager: ObservableObject {
    @Published private(set) var monitors: [Monitor] = []
    var displays: [Display] { monitors.map(\.display) }
    var onChange: (() -> Void)?
    private var observer: NSObjectProtocol?

    init() {
        refresh()
        observer = NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification,
                                                          object: nil, queue: .main) { [weak self] _ in
            self?.refresh()
            self?.onChange?()
        }
    }
    deinit { if let observer { NotificationCenter.default.removeObserver(observer) } }
    func refresh() {
        monitors = NSScreen.screens.enumerated().compactMap { index, screen in
            guard let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? UInt32 else { return nil }
            return Monitor(id: id, name: screen.localizedName, screen: screen,
                           display: Display(id: id, bounds: CGDisplayBounds(id)),
                           physicalHeight: CGDisplayScreenSize(id).height, number: index + 1)
        }
    }
}
