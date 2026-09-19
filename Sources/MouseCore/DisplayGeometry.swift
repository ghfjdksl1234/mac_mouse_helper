import Foundation
import CoreGraphics

/// All core geometry uses Quartz desktop points: origin at the primary display's
/// upper-left, +y down. Never mix these with backing pixels or AppKit coordinates.
public struct Display: Equatable {
    public let id: UInt32
    public let bounds: CGRect
    public init(id: UInt32, bounds: CGRect) { self.id = id; self.bounds = bounds }
}

public enum Edge: CaseIterable {
    case left, right, top, bottom
    public var isVertical: Bool { self == .left || self == .right }
    public func outwardComponent(_ delta: CGPoint) -> CGFloat {
        switch self {
        case .left: return -delta.x
        case .right: return delta.x
        case .top: return -delta.y
        case .bottom: return delta.y
        }
    }
}

public struct Crossing: Equatable {
    public let sourceID: UInt32
    public let targetID: UInt32
    public let edge: Edge
    public let destination: CGPoint
}

public enum DisplayGeometry {
    public static func farthestRadius(from point: CGPoint, displays: [Display]) -> CGFloat {
        displays.flatMap { display -> [CGPoint] in
            let b = display.bounds
            return [CGPoint(x: b.minX, y: b.minY), CGPoint(x: b.maxX, y: b.minY),
                    CGPoint(x: b.minX, y: b.maxY), CGPoint(x: b.maxX, y: b.maxY)]
        }.map { hypot($0.x - point.x, $0.y - point.y) }.max() ?? 0
    }

    /// Only blocked portions of a shared edge qualify. Regular crossings remain
    /// under macOS control, and an outer edge without a neighbor never teleports.
    public static func blockedCrossing(at point: CGPoint, delta: CGPoint,
                                       displays: [Display]) -> Crossing? {
        guard let source = displays.first(where: { $0.bounds.contains(point) }) else { return nil }
        let s = source.bounds
        let edges = Edge.allCases.filter { edge in
            guard edge.outwardComponent(delta) >= 1 else { return false }
            switch edge {
            case .left: return point.x - s.minX <= 2
            case .right: return s.maxX - point.x <= 2
            case .top: return point.y - s.minY <= 2
            case .bottom: return s.maxY - point.y <= 2
            }
        }.sorted { $0.outwardComponent(delta) > $1.outwardComponent(delta) }

        for edge in edges {
            let neighbors = displays.filter { target in
                guard target.id != source.id else { return false }
                let t = target.bounds
                let gap: CGFloat
                let overlap: CGFloat
                switch edge {
                case .left:
                    gap = s.minX - t.maxX
                    overlap = min(s.maxY, t.maxY) - max(s.minY, t.minY)
                case .right:
                    gap = t.minX - s.maxX
                    overlap = min(s.maxY, t.maxY) - max(s.minY, t.minY)
                case .top:
                    gap = s.minY - t.maxY
                    overlap = min(s.maxX, t.maxX) - max(s.minX, t.minX)
                case .bottom:
                    gap = t.minY - s.maxY
                    overlap = min(s.maxX, t.maxX) - max(s.minX, t.minX)
                }
                return abs(gap) <= 4 && overlap > 1
            }
            // A third monitor may cover this part of the edge: do not override it.
            if neighbors.contains(where: { target in
                edge.isVertical
                    ? point.y >= target.bounds.minY && point.y < target.bounds.maxY
                    : point.x >= target.bounds.minX && point.x < target.bounds.maxX
            }) { continue }
            let coordinate = edge.isVertical ? point.y : point.x
            let target = neighbors.min { a, b in
                func distance(_ d: Display) -> CGFloat {
                    let low = edge.isVertical ? d.bounds.minY : d.bounds.minX
                    let high = edge.isVertical ? d.bounds.maxY : d.bounds.maxX
                    return max(low - coordinate, coordinate - high, 0)
                }
                let da = distance(a), db = distance(b)
                return da == db ? a.id < b.id : da < db
            }
            guard let target else { continue }
            let t = target.bounds
            let fraction = edge.isVertical ? (point.y - s.minY) / s.height : (point.x - s.minX) / s.width
            let inset: CGFloat = 6
            let y = min(t.maxY - inset, max(t.minY + inset, t.minY + fraction * t.height))
            let x = min(t.maxX - inset, max(t.minX + inset, t.minX + fraction * t.width))
            let destination: CGPoint
            switch edge {
            case .left: destination = CGPoint(x: t.maxX - inset, y: y)
            case .right: destination = CGPoint(x: t.minX + inset, y: y)
            case .top: destination = CGPoint(x: x, y: t.maxY - inset)
            case .bottom: destination = CGPoint(x: x, y: t.minY + inset)
            }
            return Crossing(sourceID: source.id, targetID: target.id, edge: edge, destination: destination)
        }
        return nil
    }

    /// Shared desktop y-coordinates produce continuous lines, even on offset
    /// displays. The anchor can be selected when displays have no common height.
    public static func guidePositions(anchor: CGRect, count: Int, offset: CGFloat) -> [CGFloat] {
        guard count > 0 else { return [] }
        return (1...count).map { anchor.minY + anchor.height * CGFloat($0) / CGFloat(count + 1) + offset }
    }

    /// Local y-coordinates at consistent physical intervals on unlike displays.
    /// With no EDID size, 96 dpi is an estimate; the UI must disclose this fallback.
    public static func physicalGuidePositions(height: CGFloat, millimeters: CGFloat,
                                              count: Int, spacing: CGFloat, offset: CGFloat) -> [CGFloat] {
        guard count > 0, height > 0 else { return [] }
        let pointsPerMM = millimeters > 0 ? height / millimeters : 96.0 / 25.4
        return (0..<count).map { height / 2 + (CGFloat($0 - count / 2) * spacing + offset) * pointsPerMM }
    }
}
