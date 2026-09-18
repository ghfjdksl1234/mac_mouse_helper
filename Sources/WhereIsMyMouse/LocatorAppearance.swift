import AppKit

/// Preserve the original GrandCircleView's appearance: users with low vision
/// found this specific red–yellow–red band helpful. Keep this independent of the
/// app's decorative palette. Source: macgebi/mac_mouse_helper, GrandCircleView.m
/// at a563e689a06d3b6226e63cadc0813b321e9cbd73.
enum LocatorAppearance {
    static let duration: TimeInterval = 1.5
    private static let maximumBandWidth: CGFloat = 60
    private static let gradient = NSGradient(colors: [.red, .yellow, .red])

    static func draw(in context: CGContext, center: CGPoint, radius: CGFloat, opacity: CGFloat = 1) {
        guard radius.isFinite, radius > 0, opacity > 0 else { return }
        let innerRadius = max(radius * 0.9, radius - maximumBandWidth)
        // Use the same AppKit colors and radial-gradient API as the original.
        // No glow, color substitution, or fill inside/outside the band.
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: true)
        context.saveGState()
        context.setAlpha(opacity)
        // Explicitly preserve the transparent center in both AppKit windows
        // and SwiftUI Canvas, whose drawing backend may extend radial fills.
        context.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius,
                                      width: radius * 2, height: radius * 2))
        context.addEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius,
                                      width: innerRadius * 2, height: innerRadius * 2))
        context.clip(using: .evenOdd)
        gradient?.draw(fromCenter: center, radius: radius,
                       toCenter: center, radius: innerRadius, options: [])
        context.restoreGState()
        NSGraphicsContext.restoreGraphicsState()
    }
}
