import Foundation
import CoreGraphics
import MouseCore

final class MouseCoreTests {
    let large = Display(id: 1, bounds: CGRect(x: 0, y: 0, width: 2560, height: 1440))
    let small = Display(id: 2, bounds: CGRect(x: 2560, y: 200, width: 1920, height: 1080))

    func testRingCoversEveryCornerIncludingNegativeCoordinates() {
        let screens = [large, Display(id: 2, bounds: CGRect(x: -1920, y: -400, width: 1920, height: 1080))]
        let p = CGPoint(x: 2300, y: 1100)
        XCTAssertEqual(DisplayGeometry.farthestRadius(from: p, displays: screens), hypot(4220, 1500), accuracy: 0.001)
        XCTAssertEqual(DisplayGeometry.farthestRadius(from: p, displays: []), 0)
    }
    func testBlockedRightEdgeMapsProportionallyIntoNeighbor() throws {
        let result = try XCTUnwrap(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2559, y: 1400), delta: CGPoint(x: 4, y: 0), displays: [large, small]))
        XCTAssertEqual(result.targetID, 2)
        XCTAssertEqual(result.destination.x, 2566)
        XCTAssertEqual(result.destination.y, 1250, accuracy: 0.01)
    }
    func testOrdinaryCrossingAndOuterEdgeRemainUntouched() {
        XCTAssertNil(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2559, y: 700), delta: CGPoint(x: 4, y: 0), displays: [large, small]))
        XCTAssertNil(DisplayGeometry.blockedCrossing(at: CGPoint(x: 0, y: 700), delta: CGPoint(x: -4, y: 0), displays: [large, small]))
        XCTAssertNil(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2559, y: 1400), delta: CGPoint(x: -4, y: 0), displays: [large, small]))
    }
    func testThirdMonitorCoveringEdgePreventsWarpToWrongNeighbor() {
        let third = Display(id: 3, bounds: CGRect(x: 2560, y: 1280, width: 1024, height: 768))
        XCTAssertNil(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2559, y: 1400), delta: CGPoint(x: 5, y: 0), displays: [large, small, third]))
    }
    func testLeftAndVerticalLayoutsWithNegativeOrigins() throws {
        let left = Display(id: 3, bounds: CGRect(x: -1000, y: 200, width: 1000, height: 1000))
        let upper = Display(id: 4, bounds: CGRect(x: 200, y: -900, width: 1600, height: 900))
        let lower = Display(id: 5, bounds: CGRect(x: 200, y: 1440, width: 1600, height: 900))
        let a = try XCTUnwrap(DisplayGeometry.blockedCrossing(at: CGPoint(x: 0, y: 50), delta: CGPoint(x: -5, y: 0), displays: [large, left]))
        XCTAssertEqual(a.destination.x, -6)
        XCTAssertTrue(left.bounds.contains(a.destination))
        let b = try XCTUnwrap(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2400, y: 0), delta: CGPoint(x: 0, y: -5), displays: [large, upper]))
        XCTAssertEqual(b.destination.y, -6)
        XCTAssertTrue(upper.bounds.contains(b.destination))
        let c = try XCTUnwrap(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2400, y: 1439), delta: CGPoint(x: 0, y: 5), displays: [large, lower]))
        XCTAssertEqual(c.destination.y, 1446)
        XCTAssertTrue(lower.bounds.contains(c.destination))
    }
    func testUnrelatedAndMirroredDisplaysNeverBecomeNeighbors() {
        let gap = Display(id: 3, bounds: CGRect(x: 4000, y: 0, width: 1200, height: 800))
        let mirrored = Display(id: 4, bounds: large.bounds)
        XCTAssertNil(DisplayGeometry.blockedCrossing(at: CGPoint(x: 2559, y: 1400), delta: CGPoint(x: 6, y: 0), displays: [large, gap, mirrored]))
    }
    func testEdgeRequiresSustainedPressureAndHasCooldown() {
        var detector = StuckEdgeDetector()
        let p = CGPoint(x: 2559, y: 1400)
        var crossings = 0
        for index in 0..<30 {
            let sample = MotionSample(position: p, delta: CGPoint(x: 5, y: 0), time: Double(index) * 0.01)
            if detector.consume(sample, displays: [large, small]) != nil {
                XCTAssertGreaterThanOrEqual(index, 9)
                crossings += 1
            }
        }
        XCTAssertEqual(crossings, 1)
    }
    func testPausingOrChangingDirectionClearsPressure() {
        var detector = StuckEdgeDetector()
        let p = CGPoint(x: 2559, y: 1400)
        for i in 0..<4 { XCTAssertNil(detector.consume(.init(position: p, delta: CGPoint(x: 5, y: 0), time: Double(i) * 0.02), displays: [large, small])) }
        XCTAssertNil(detector.consume(.init(position: p, delta: CGPoint(x: 10, y: 0), time: 1), displays: [large, small]))
        XCTAssertNil(detector.consume(.init(position: p, delta: CGPoint(x: -10, y: 0), time: 1.01), displays: [large, small]))
    }
    func testShakeDetectsHighFrequencySmallReports() {
        var detector = ShakeDetector()
        var x = 500.0
        var triggers = 0
        for i in 0..<80 {
            let dx = (i / 10) % 2 == 0 ? 3.0 : -3.0
            x += dx
            if detector.consume(.init(position: CGPoint(x: x, y: 300), delta: CGPoint(x: dx, y: 0), time: Double(i) * 0.005)) { triggers += 1 }
        }
        XCTAssertEqual(triggers, 1)
    }
    func testStraightMovementAndTinyJitterAreNotShakes() {
        for jitter in [false, true] {
            var detector = ShakeDetector()
            var x = 500.0
            for i in 0..<80 {
                let dx = jitter ? (i % 2 == 0 ? 1.0 : -1.0) : 8.0
                x += dx
                XCTAssertFalse(detector.consume(.init(position: CGPoint(x: x, y: 300), delta: CGPoint(x: dx, y: 0), time: Double(i) * 0.005)))
            }
        }
    }
    func testVerticalShakingAndWindowExpiry() {
        var detector = ShakeDetector()
        var triggered = false
        var y = 300.0
        for i in 0..<16 {
            let dy = (i / 4) % 2 == 0 ? 15.0 : -15.0
            y += dy
            triggered = detector.consume(.init(position: CGPoint(x: 300, y: y), delta: CGPoint(x: 0, y: dy), time: Double(i) * 0.025)) || triggered
        }
        XCTAssertTrue(triggered)
        detector.reset()
        for i in 0..<8 {
            XCTAssertFalse(detector.consume(.init(position: CGPoint(x: 0, y: 0), delta: CGPoint(x: i % 2 == 0 ? 80 : -80, y: 0), time: 5 + Double(i))))
        }
    }
    func testGuidesUseSharedCoordinatesAndOffset() {
        XCTAssertEqual(DisplayGeometry.guidePositions(anchor: large.bounds, count: 3, offset: 20), [380, 740, 1100])
        XCTAssertEqual(DisplayGeometry.guidePositions(anchor: large.bounds, count: 0, offset: 0), [])
    }
    func testPhysicalGuidesRespectDifferentPixelDensities() {
        let a = DisplayGeometry.physicalGuidePositions(height: 1440, millimeters: 360, count: 3, spacing: 40, offset: 0)
        let b = DisplayGeometry.physicalGuidePositions(height: 1080, millimeters: 300, count: 3, spacing: 40, offset: 0)
        XCTAssertEqual(a, [560, 720, 880])
        XCTAssertEqual(b, [396, 540, 684])
        XCTAssertEqual((a[1] - a[0]) / (1440.0 / 360), 40)
        XCTAssertEqual((b[1] - b[0]) / (1080.0 / 300), 40)
        let unknown = DisplayGeometry.physicalGuidePositions(height: 1000, millimeters: 0, count: 3, spacing: 40, offset: 10)
        XCTAssertTrue(unknown.allSatisfy(\.isFinite))
        XCTAssertEqual(unknown[1], 500 + 10 * 96 / 25.4, accuracy: 0.001)
    }
}
