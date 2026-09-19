import Foundation

// Small assertion runner so contributors with just Command Line Tools can run
// the full suite. Tests return a nonzero status on any assertion or thrown error.
private var failures = 0
private var assertions = 0
private struct MissingValue: Error {}

func XCTAssertTrue(_ value: @autoclosure () -> Bool, file: StaticString = #filePath, line: UInt = #line) {
    assertions += 1
    if !value() { failures += 1; print("FAIL \(file):\(line): expected true") }
}
func XCTAssertFalse(_ value: @autoclosure () -> Bool, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(!value(), file: file, line: line)
}
func XCTAssertNil<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(value == nil, file: file, line: line)
}
func XCTAssertEqual<T: Equatable>(_ actual: T, _ expected: T, file: StaticString = #filePath, line: UInt = #line) {
    assertions += 1
    if actual != expected { failures += 1; print("FAIL \(file):\(line): \(actual) != \(expected)") }
}
func XCTAssertEqual<T: BinaryFloatingPoint>(_ actual: T, _ expected: T, accuracy: T, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(abs(actual - expected) <= accuracy, file: file, line: line)
}
func XCTAssertGreaterThanOrEqual<T: Comparable>(_ actual: T, _ minimum: T, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(actual >= minimum, file: file, line: line)
}
func XCTUnwrap<T>(_ value: T?, file: StaticString = #filePath, line: UInt = #line) throws -> T {
    assertions += 1
    guard let value else { failures += 1; print("FAIL \(file):\(line): unexpectedly nil"); throw MissingValue() }
    return value
}

@main struct TestRunner {
    static func main() {
        let suite = MouseCoreTests()
        let tests: [(String, () throws -> Void)] = [
            ("Ring covers every display corner", suite.testRingCoversEveryCornerIncludingNegativeCoordinates),
            ("Blocked edge maps proportionally", suite.testBlockedRightEdgeMapsProportionallyIntoNeighbor),
            ("Normal crossings and outer edges", suite.testOrdinaryCrossingAndOuterEdgeRemainUntouched),
            ("Third monitor covering an edge", suite.testThirdMonitorCoveringEdgePreventsWarpToWrongNeighbor),
            ("All directions and negative origins", suite.testLeftAndVerticalLayoutsWithNegativeOrigins),
            ("Mirrored and unrelated displays", suite.testUnrelatedAndMirroredDisplaysNeverBecomeNeighbors),
            ("Sustained pressure and cooldown", suite.testEdgeRequiresSustainedPressureAndHasCooldown),
            ("Pressure resets", suite.testPausingOrChangingDirectionClearsPressure),
            ("High-frequency shake reports", suite.testShakeDetectsHighFrequencySmallReports),
            ("Straight movement and jitter", suite.testStraightMovementAndTinyJitterAreNotShakes),
            ("Vertical shake and sample expiry", suite.testVerticalShakingAndWindowExpiry),
            ("Shared coordinate guides", suite.testGuidesUseSharedCoordinatesAndOffset),
            ("Physical spacing on unlike displays", suite.testPhysicalGuidesRespectDifferentPixelDensities)
        ]
        for (name, test) in tests {
            let before = failures
            do { try test() } catch {
                if failures == before { failures += 1 }
                print("ERROR \(name): \(error)")
            }
            print("\(failures == before ? "PASS" : "FAIL") \(name)")
        }
        print("\(tests.count) tests, \(assertions) assertions, \(failures) failures")
        exit(failures == 0 ? EXIT_SUCCESS : EXIT_FAILURE)
    }
}
