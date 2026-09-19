import AppKit

enum GuideAppearance {
    static let counts = [3, 5, 7, 9, 11]
    static let defaultCount = 9
    static let defaultSpacing = 30.0
    static let defaultThickness = 4.0

    // One color per numbered line, shared by every display and the preview.
    // Numbers remain available so matching never relies on color alone.
    private static let colors: [NSColor] = [
        NSColor(srgbRed: 1, green: 0.28, blue: 0.28, alpha: 1),
        NSColor(srgbRed: 1, green: 0.61, blue: 0.21, alpha: 1),
        NSColor(srgbRed: 1, green: 0.88, blue: 0.20, alpha: 1),
        NSColor(srgbRed: 0.68, green: 0.94, blue: 0.23, alpha: 1),
        NSColor(srgbRed: 0.20, green: 0.89, blue: 0.52, alpha: 1),
        NSColor(srgbRed: 0.15, green: 0.86, blue: 0.94, alpha: 1),
        NSColor(srgbRed: 0.28, green: 0.60, blue: 1, alpha: 1),
        NSColor(srgbRed: 0.56, green: 0.46, blue: 1, alpha: 1),
        NSColor(srgbRed: 1, green: 0.39, blue: 0.80, alpha: 1),
        NSColor(srgbRed: 0.75, green: 0.54, blue: 1, alpha: 1),
        NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
    ]

    static func color(for index: Int) -> NSColor { colors[max(0, index) % colors.count] }

    static func drawLine(in context: CGContext, y: CGFloat, width: CGFloat, index: Int, thickness: CGFloat) {
        context.saveGState()
        // A dark border keeps light-colored lines visible on a white desktop.
        context.setStrokeColor(NSColor.black.withAlphaComponent(0.85).cgColor)
        context.setLineWidth(thickness + 3)
        context.move(to: CGPoint(x: 0, y: y)); context.addLine(to: CGPoint(x: width, y: y)); context.strokePath()
        context.setStrokeColor(color(for: index).cgColor)
        context.setLineWidth(thickness)
        context.move(to: CGPoint(x: 0, y: y)); context.addLine(to: CGPoint(x: width, y: y)); context.strokePath()
        context.setLineWidth(1.5)
        let tickHeight = thickness / 2 + 4
        for x in stride(from: CGFloat(20), to: width, by: 40) {
            context.move(to: CGPoint(x: x, y: y - tickHeight))
            context.addLine(to: CGPoint(x: x, y: y + tickHeight))
        }
        context.strokePath()
        context.restoreGState()
    }
}
