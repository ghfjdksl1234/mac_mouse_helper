import AppKit
import SwiftUI

enum PrivacyPermission: String {
    case inputMonitoring = "Input Monitoring"
    case accessibility = "Accessibility"
    var paneID: String { self == .inputMonitoring ? "Privacy_ListenEvent" : "Privacy_Accessibility" }
    func openSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(paneID)") {
            NSWorkspace.shared.open(url)
        }
    }
}

/// Export a real file URL for the running .app bundle, just like dragging it
/// from Finder. Never export the executable inside Contents/MacOS or a guessed
/// installation path, and never offer a move operation on the app bundle.
enum AppBundleDragSource {
    static var appURL: URL { Bundle.main.bundleURL.standardizedFileURL }
    static var pasteboardWriter: NSPasteboardWriting { appURL as NSURL }

    static func validateFileURLPayload() -> Bool {
        let board = NSPasteboard(name: .init("com.inbedsoft.WhereIsMyMouse.drag-check.\(UUID().uuidString)"))
        defer { board.releaseGlobally() }
        guard board.writeObjects([pasteboardWriter]), let text = board.string(forType: .fileURL),
              let url = URL(string: text) else { return false }
        return url.standardizedFileURL == appURL && url.pathExtension == "app" && FileManager.default.fileExists(atPath: url.path)
    }
}

final class PermissionSetupController {
    private var panel: NSPanel?

    func show(_ permission: PrivacyPermission) {
        if panel == nil {
            let panel = NSPanel(contentRect: CGRect(x: 0, y: 0, width: 390, height: 500),
                                styleMask: [.titled, .closable, .utilityWindow, .nonactivatingPanel], backing: .buffered, defer: false)
            panel.title = "Add Where is My Mouse?"
            panel.level = .floating
            panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false
            panel.isRestorable = false
            panel.isMovableByWindowBackground = true
            panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
            if let frame = NSScreen.main?.visibleFrame {
                panel.setFrameOrigin(CGPoint(x: frame.minX + 24, y: frame.midY - 250))
            }
            self.panel = panel
        }
        panel?.contentView = NSHostingView(rootView: PermissionSetupView(permission: permission))
        panel?.orderFrontRegardless()
    }

    func close() { panel?.close() }

    func exportSnapshot(to url: URL) throws {
        guard let view = panel?.contentView, let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            throw CocoaError(.coderInvalidValue)
        }
        view.cacheDisplay(in: view.bounds, to: rep)
        guard let data = rep.representation(using: .png, properties: [:]) else { throw CocoaError(.coderInvalidValue) }
        try data.write(to: url)
    }
}

private struct PermissionSetupView: View {
    let permission: PrivacyPermission
    @State private var copied = false
    private let green = Color(red: 0.12, green: 0.44, blue: 0.34)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(permission.rawValue.uppercased(), systemImage: "hand.raised")
                .font(.system(size: 10, weight: .semibold)).tracking(1).foregroundStyle(green)
            Text("Drag the app.\nSkip the file hunt.")
                .font(.system(size: 25, weight: .semibold, design: .rounded))
            Text("Drop this app into the \(permission.rawValue) list in System Settings, then turn its switch on.")
                .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            AppBundleDragTile().frame(height: 82)
                .accessibilityLabel("Drag Where is My Mouse app into \(permission.rawValue)")
            HStack(spacing: 10) {
                Button("Open \(permission.rawValue)") { permission.openSettings() }.buttonStyle(.borderedProminent)
                Button("Show in Finder") { NSWorkspace.shared.activateFileViewerSelecting([AppBundleDragSource.appURL]) }.buttonStyle(.bordered)
            }.controlSize(.small)
            Divider()
            Text("If the list won’t accept a drop, click +, press ⇧⌘G, and paste the app path below.")
                .font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            HStack {
                Button(copied ? "Path copied" : "Copy app path") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(AppBundleDragSource.appURL.path, forType: .string)
                    copied = true
                }.buttonStyle(.bordered).controlSize(.small)
                Spacer()
                Text("This helper stays on top.").font(.system(size: 10)).foregroundStyle(.secondary)
            }
            Text("If macOS asks you to quit and reopen, do so to finish enabling access.")
                .font(.system(size: 10)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }.padding(22).frame(width: 390, height: 500, alignment: .topLeading)
            .background(Color(red: 0.97, green: 0.975, blue: 0.96))
            .tint(green).preferredColorScheme(.light)
    }
}

private struct AppBundleDragTile: NSViewRepresentable {
    func makeNSView(context: Context) -> AppBundleDragView { AppBundleDragView() }
    func updateNSView(_ view: AppBundleDragView, context: Context) {}
}

private final class AppBundleDragView: NSView, NSDraggingSource {
    override var isFlipped: Bool { true }
    override var mouseDownCanMoveWindow: Bool { false }
    private var mouseDownPoint: CGPoint?
    private let appIcon = NSWorkspace.shared.icon(forFile: AppBundleDragSource.appURL.path)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setAccessibilityElement(true)
        setAccessibilityRole(.image)
        setAccessibilityLabel("Where is My Mouse application, draggable file")
        setAccessibilityHelp("Drag into the System Settings permission list. Use Show in Finder or Copy app path for a keyboard alternative.")
        toolTip = AppBundleDragSource.appURL.path
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func shouldDelayWindowOrdering(for event: NSEvent) -> Bool { true }
    override func resetCursorRects() { addCursorRect(bounds, cursor: .openHand) }

    override func draw(_ dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 1, dy: 1)
        NSColor.white.setFill()
        let border = NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12)
        border.fill()
        NSColor(srgbRed: 0.12, green: 0.44, blue: 0.34, alpha: 0.55).setStroke()
        border.lineWidth = 1.5
        border.setLineDash([5, 4], count: 2, phase: 0)
        border.stroke()
        appIcon.draw(in: CGRect(x: 12, y: 13, width: 56, height: 56), from: .zero,
                     operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
        NSAttributedString(string: "Where is My Mouse.app", attributes: [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: NSColor.labelColor
        ]).draw(at: CGPoint(x: 80, y: 24))
        NSAttributedString(string: "Drag this icon into the list ↗", attributes: [
            .font: NSFont.systemFont(ofSize: 11), .foregroundColor: NSColor.secondaryLabelColor
        ]).draw(at: CGPoint(x: 80, y: 45))
    }

    override func mouseDown(with event: NSEvent) { mouseDownPoint = convert(event.locationInWindow, from: nil) }
    override func mouseUp(with event: NSEvent) { mouseDownPoint = nil }
    override func mouseDragged(with event: NSEvent) {
        guard let start = mouseDownPoint else { return }
        let point = convert(event.locationInWindow, from: nil)
        guard hypot(point.x - start.x, point.y - start.y) >= 4 else { return }
        mouseDownPoint = nil
        let item = NSDraggingItem(pasteboardWriter: AppBundleDragSource.pasteboardWriter)
        item.setDraggingFrame(CGRect(x: point.x - 28, y: point.y - 28, width: 56, height: 56), contents: appIcon)
        let session = beginDraggingSession(with: [item], event: event, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = true
    }
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation { .copy }
    func ignoreModifierKeys(for session: NSDraggingSession) -> Bool { true }
}
