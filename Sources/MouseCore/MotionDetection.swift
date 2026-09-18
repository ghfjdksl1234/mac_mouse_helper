import Foundation
import CoreGraphics

public struct MotionSample {
    public let position: CGPoint
    public let delta: CGPoint
    public let time: TimeInterval
    public init(position: CGPoint, delta: CGPoint, time: TimeInterval) {
        self.position = position; self.delta = delta; self.time = time
    }
}

/// Detects deliberate back-and-forth motion. Runs, rather than individual device
/// reports, make recognition independent of 125 Hz vs. 1,000 Hz mouse sampling.
public struct ShakeDetector {
    private var samples: [MotionSample] = []
    private var lastTrigger: TimeInterval = -.infinity
    public init() {}
    public mutating func reset() { samples.removeAll() }

    public mutating func consume(_ sample: MotionSample, sensitivity: Double = 0.5) -> Bool {
        guard sample.time - lastTrigger >= 1.25 else { return false }
        samples.append(sample)
        samples.removeAll { sample.time - $0.time > 0.65 }
        // Bound work even for very high-polling-rate mice.
        if samples.count > 700 { samples.removeFirst(samples.count - 700) }
        let sensitivity = min(1, max(0, sensitivity))
        let requiredTravel = 260 - 150 * sensitivity
        let minimumRun = CGFloat(14 - 7 * sensitivity)
        for horizontal in [true, false] {
            var runs: [CGFloat] = []
            var total: CGFloat = 0
            for s in samples {
                let d = horizontal ? s.delta.x : s.delta.y
                guard abs(d) > 0.01 else { continue }
                total += abs(d)
                if let last = runs.last, (last > 0) == (d > 0) { runs[runs.count - 1] += d }
                else { runs.append(d) }
            }
            let deliberateRuns = runs.filter { abs($0) >= minimumRun }
            var reversals = 0
            for pair in zip(deliberateRuns, deliberateRuns.dropFirst()) {
                if (pair.0 > 0) != (pair.1 > 0) { reversals += 1 }
            }
            guard total >= requiredTravel, reversals >= 3, let first = samples.first else { continue }
            let elapsed = sample.time - first.time
            let displacement = hypot(sample.position.x - first.position.x, sample.position.y - first.position.y)
            if elapsed >= 0.08 && displacement < total * 0.55 {
                lastTrigger = sample.time
                reset()
                return true
            }
        }
        return false
    }
}

public struct StuckEdgeDetector {
    private var previous: MotionSample?
    private var candidate: Crossing?
    private var started: TimeInterval = 0
    private var pressure: CGFloat = 0
    private var reports = 0
    private var cooldownUntil: TimeInterval = 0
    public init() {}
    public mutating func reset() {
        previous = nil; candidate = nil; pressure = 0; reports = 0
    }
    public mutating func didWarp(at time: TimeInterval) {
        reset()
        cooldownUntil = time + 0.55
    }

    public mutating func consume(_ sample: MotionSample, displays: [Display],
                                 resistance: Double = 0.5) -> Crossing? {
        defer { previous = sample }
        guard sample.time >= cooldownUntil,
              let crossing = DisplayGeometry.blockedCrossing(at: sample.position, delta: sample.delta, displays: displays),
              let previous, sample.time - previous.time < 0.18 else {
            candidate = nil; pressure = 0; reports = 0
            return nil
        }
        let actual = CGPoint(x: sample.position.x - previous.position.x, y: sample.position.y - previous.position.y)
        // Arriving at the edge isn't enough: physical motion must continue while
        // the pointer is stationary on the outward axis (it may still slide).
        guard abs(crossing.edge.outwardComponent(actual)) <= 0.75 else {
            candidate = nil; pressure = 0; reports = 0
            return nil
        }
        if candidate?.sourceID != crossing.sourceID || candidate?.targetID != crossing.targetID || candidate?.edge != crossing.edge {
            candidate = crossing; started = sample.time; pressure = 0; reports = 0
        }
        pressure += crossing.edge.outwardComponent(sample.delta)
        reports += 1
        let resistance = min(1, max(0, resistance))
        if pressure >= 10 + 30 * resistance && reports >= 3 && sample.time - started >= 0.035 + 0.09 * resistance {
            didWarp(at: sample.time)
            return crossing
        }
        return nil
    }
}
