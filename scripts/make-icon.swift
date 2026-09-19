import AppKit

let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                   colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        let ctx = NSGraphicsContext.current!.cgContext
        ctx.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
        let shape = CGPath(roundedRect: CGRect(x: 80, y: 80, width: 864, height: 864), cornerWidth: 195, cornerHeight: 195, transform: nil)
        ctx.addPath(shape); ctx.clip()
        let colors = [NSColor(srgbRed: 0.2, green: 0.56, blue: 0.43, alpha: 1).cgColor,
                      NSColor(srgbRed: 0.06, green: 0.27, blue: 0.22, alpha: 1).cgColor] as CFArray
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 140, y: 940), end: CGPoint(x: 850, y: 80), options: [])
        for (radius, opacity) in [(300.0, 0.25), (211.0, 0.55)] {
            ctx.setStrokeColor(NSColor(srgbRed: 0.73, green: 0.96, blue: 0.80, alpha: opacity).cgColor)
            ctx.setLineWidth(11)
            ctx.strokeEllipse(in: CGRect(x: 476 - radius, y: 550 - radius, width: radius * 2, height: radius * 2))
        }
        ctx.translateBy(x: 425, y: 635)
        ctx.scaleBy(x: 13, y: -13)
        let arrow = CGMutablePath()
        arrow.move(to: .zero)
        for p in [CGPoint(x: 1, y: 22), CGPoint(x: 6.5, y: 17), CGPoint(x: 11, y: 26), CGPoint(x: 15, y: 24), CGPoint(x: 10.5, y: 15), CGPoint(x: 18, y: 14)] { arrow.addLine(to: p) }
        arrow.closeSubpath()
        ctx.setShadow(offset: CGSize(width: 0, height: 1), blur: 3, color: NSColor.black.withAlphaComponent(0.3).cgColor)
        ctx.addPath(arrow)
        ctx.setFillColor(NSColor.white.cgColor)
        ctx.fillPath()
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        try rep.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
    }
}
