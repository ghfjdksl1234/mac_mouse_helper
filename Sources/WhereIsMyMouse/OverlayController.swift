import AppKit
import MouseCore

final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

/// One click-through panel per display avoids a huge backing surface, supports
/// mixed Retina scales, and lets the same world-space circle span every screen.
final class OverlayController {
    private let displays: DisplayManager
    private let settings: Settings
    private var panels: [OverlayPanel] = []
    private var timer: Timer?
    private var ringStart: TimeInterval?
    private var initialRadius: CGFloat = 0
    private var pointerStart: TimeInterval?
    private var pointer: CGPoint = .zero
    private var suspended = false
    private let duration = LocatorAppearance.duration

    init(displays: DisplayManager, settings: Settings) {
        self.displays = displays; self.settings = settings
    }
    func rebuild() {
        panels.forEach { $0.orderOut(nil); $0.close() }
        panels = displays.monitors.map { monitor in
            let panel = OverlayPanel(contentRect: monitor.screen.frame,
                                     styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            panel.isReleasedWhenClosed = false
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            panel.hidesOnDeactivate = false
            panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            let view = OverlayView(frame: CGRect(origin: .zero, size: monitor.screen.frame.size))
            view.monitor = monitor
            panel.contentView = view
            return panel
        }
        render()
    }

    func locate() {
        guard !suspended else { return }
        let now = ProcessInfo.processInfo.systemUptime
        // Let the original 1.5-second sweep reach the pointer even if the user
        // keeps shaking long enough to pass the detector's trigger cooldown.
        if let start = ringStart, now - start < duration { return }
        pointer = CGEvent(source: nil)?.location ?? .zero
        initialRadius = DisplayGeometry.farthestRadius(from: pointer, displays: displays.displays)
        ringStart = now
        startTimer()
    }
    func enlarge(at position: CGPoint) {
        guard !suspended else { return }
        pointer = position
        pointerStart = ProcessInfo.processInfo.systemUptime
        startTimer()
    }
    func settingsChanged() { render() }
    func exportGuideSnapshots(to directory: URL) throws {
        for (index, panel) in panels.enumerated() {
            guard let view = panel.contentView, let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
                throw CocoaError(.coderInvalidValue)
            }
            view.cacheDisplay(in: view.bounds, to: rep)
            guard let data = rep.representation(using: .png, properties: [:]) else { throw CocoaError(.coderInvalidValue) }
            try data.write(to: directory.appendingPathComponent("guides-display-\(index + 1).png"))
        }
    }
    func suspend() {
        suspended = true
        clearAnimations()
        panels.forEach { $0.orderOut(nil) }
    }
    func resume() { suspended = false; render() }
    func clearAnimations() {
        ringStart = nil; pointerStart = nil
        timer?.invalidate(); timer = nil
        render()
    }
    func stop() {
        suspended = true
        clearAnimations()
        panels.forEach { $0.orderOut(nil); $0.close() }
        panels.removeAll()
    }
    private func startTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in self?.render() }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }
        render()
    }
    private func render() {
        guard !suspended else { return }
        let now = ProcessInfo.processInfo.systemUptime
        pointer = CGEvent(source: nil)?.location ?? pointer
        if let start = ringStart, now - start > duration { ringStart = nil }
        if let start = pointerStart, now - start > settings.highlightDuration { pointerStart = nil }
        let ringProgress = ringStart.map { min(1, (now - $0) / duration) }
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let radius = ringProgress.map { progress -> CGFloat in
            if reduceMotion { return 42 }
            return initialRadius * (1 - progress)
        }
        let pointerProgress = pointerStart.map { min(1, (now - $0) / settings.highlightDuration) }
        for panel in panels {
            guard let view = panel.contentView as? OverlayView else { continue }
            view.pointer = pointer
            view.radius = radius
            // Keep the moving band fully opaque, as in the original. The
            // stationary Reduce Motion alternative retains its gentle fade.
            view.ringOpacity = ringProgress.map { reduceMotion ? CGFloat(min(1, (1 - $0) * 7)) : 1 } ?? 0
            view.pointerScale = pointerProgress.map { p in
                let settle = max(0, (p - 0.65) / 0.35)
                return settings.pointerScale + (1 - settings.pointerScale) * settle
            }
            view.pointerOpacity = pointerProgress.map { CGFloat(min(1, (1 - $0) * 8)) } ?? 0
            view.guideMode = settings.guideMode
            view.guideLabels = settings.guideLabels
            view.guideCount = settings.guideCount
            view.guideThickness = settings.guideThickness
            view.guideSpacing = settings.guideSpacing
            view.guideOffset = settings.guideOffset
            view.anchor = displays.displays.first?.bounds ?? .zero
            view.guidesVisible = settings.guidesVisible && !settings.paused
            if radius != nil || pointerProgress != nil || view.guidesVisible {
                if !panel.isVisible { panel.orderFrontRegardless() }
                view.needsDisplay = true
            } else { panel.orderOut(nil) }
        }
        if ringStart == nil && pointerStart == nil { timer?.invalidate(); timer = nil }
    }
}

final class OverlayView: NSView {
    override var isFlipped: Bool { true }
    var monitor: Monitor!
    var pointer = CGPoint.zero
    var radius: CGFloat?
    var ringOpacity: CGFloat = 0
    var pointerScale: Double?
    var pointerOpacity: CGFloat = 0
    var guidesVisible = false
    var guideMode: GuideMode = .physical
    var guideLabels = true
    var guideCount = GuideAppearance.defaultCount
    var guideThickness = GuideAppearance.defaultThickness
    var guideSpacing = GuideAppearance.defaultSpacing
    var guideOffset = 0.0
    var anchor = CGRect.zero

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.clear(bounds)
        let localPointer = CGPoint(x: pointer.x - monitor.display.bounds.minX,
                                   y: pointer.y - monitor.display.bounds.minY)
        if guidesVisible { drawGuides(context) }
        if let radius {
            LocatorAppearance.draw(in: context, center: localPointer, radius: radius, opacity: ringOpacity)
        }
        if let scale = pointerScale {
            // A temporary enlarged arrow with exactly the system pointer's hot
            // spot. Public overlays work while another app is active and never
            // change global accessibility preferences or hide the real cursor.
            context.saveGState()
            context.setAlpha(pointerOpacity)
            context.translateBy(x: localPointer.x, y: localPointer.y)
            context.scaleBy(x: scale, y: scale)
            let path = CGMutablePath()
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 1, y: 22))
            path.addLine(to: CGPoint(x: 6.5, y: 17))
            path.addLine(to: CGPoint(x: 11, y: 26))
            path.addLine(to: CGPoint(x: 15, y: 24))
            path.addLine(to: CGPoint(x: 10.5, y: 15))
            path.addLine(to: CGPoint(x: 18, y: 14))
            path.closeSubpath()
            context.setShadow(offset: CGSize(width: 0, height: 1), blur: 4, color: NSColor.black.withAlphaComponent(0.5).cgColor)
            context.addPath(path)
            context.setFillColor(NSColor.black.cgColor)
            context.setStrokeColor(NSColor.white.cgColor)
            context.setLineWidth(1.2)
            context.setLineJoin(.round)
            context.drawPath(using: .fillStroke)
            context.restoreGState()
        }
    }

    private func drawGuides(_ context: CGContext) {
        let ys: [CGFloat]
        if guideMode == .physical {
            // Display EDID supplies millimeters. Virtual displays use 96 dpi,
            // clearly identified in the settings instead of claiming calibration.
            ys = DisplayGeometry.physicalGuidePositions(height: bounds.height, millimeters: monitor.physicalHeight,
                                                        count: guideCount, spacing: guideSpacing, offset: guideOffset)
        } else {
            ys = DisplayGeometry.guidePositions(anchor: anchor, count: guideCount, offset: guideOffset)
                .map { $0 - monitor.display.bounds.minY }
        }
        for (index, y) in ys.enumerated() where y >= 0 && y <= bounds.height {
            GuideAppearance.drawLine(in: context, y: y, width: bounds.width, index: index, thickness: guideThickness)
            if guideLabels { badge("\(index + 1)", at: CGPoint(x: 24, y: y - 13), color: GuideAppearance.color(for: index)) }
        }
        if guideLabels {
            let calibration = guideMode == .physical && !monitor.hasPhysicalSize ? " · estimated spacing" : ""
            badge("\(monitor.number)  \(monitor.name)\(calibration)  ·  ⌃⌥⌘A to hide", at: CGPoint(x: 24, y: 40))
        }
    }
    private func badge(_ text: String, at point: CGPoint, color: NSColor = .white) {
        let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .semibold), .foregroundColor: color]
        let string = NSAttributedString(string: text, attributes: attributes)
        let rect = CGRect(origin: point, size: CGSize(width: string.size().width + 18, height: 26))
        NSColor(srgbRed: 0.06, green: 0.12, blue: 0.11, alpha: 0.94).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 7, yRadius: 7).fill()
        string.draw(at: CGPoint(x: point.x + 9, y: point.y + 5))
    }
}
