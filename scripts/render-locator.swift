import AppKit

// Build with LocatorAppearance.swift to inspect the production renderer without
// launching the app, capturing the desktop, or requiring an unlocked Mac.
@main struct RenderLocator {
    static func main() throws {
        let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        for (filename, background) in [("locator-light.png", NSColor.white),
                                       ("locator-dark.png", NSColor(white: 0.08, alpha: 1)),
                                       ("locator-transparent.png", NSColor.clear)] {
            guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 400, pixelsHigh: 400,
                                            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                            isPlanar: false, colorSpaceName: .deviceRGB,
                                            bytesPerRow: 0, bitsPerPixel: 0),
                  let context = NSGraphicsContext(bitmapImageRep: rep)?.cgContext else {
                throw CocoaError(.coderInvalidValue)
            }
            context.setFillColor(background.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 400))
            LocatorAppearance.draw(in: context, center: CGPoint(x: 200, y: 200), radius: 150)
            guard let png = rep.representation(using: .png, properties: [:]) else {
                throw CocoaError(.coderInvalidValue)
            }
            try png.write(to: output.appendingPathComponent(filename))
        }
        print("Rendered production locator on light, dark, and transparent backgrounds.")
    }
}
