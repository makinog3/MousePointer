import XCTest
@testable import MousePointer

final class ShakeDetectorTests: XCTestCase {
    private var detector: ShakeDetector!
    private var detectedCount = 0
    private var endedCount = 0

    override func setUp() {
        super.setUp()
        detector = ShakeDetector()
        detectedCount = 0
        endedCount = 0
        detector.onShakeDetected = { [weak self] in self?.detectedCount += 1 }
        detector.onShakeEnded   = { [weak self] in self?.endedCount   += 1 }
    }

    // Steady rightward movement — no reversals, no shake
    func testNoShakeOnSteadyMovement() {
        for i in 0..<20 {
            detector.update(point: CGPoint(x: Double(i) * 10, y: 0),
                            timestamp: Double(i) * 0.02)
        }
        XCTAssertEqual(detectedCount, 0)
    }

    // 4 reversals of 50pt each within 0.25s → shake fires once
    func testShakeDetectedOnSufficientReversals() {
        let xs: [CGFloat] = [0, 50, 0, 50, 0, 50]
        for (i, x) in xs.enumerated() {
            detector.update(point: CGPoint(x: x, y: 0),
                            timestamp: Double(i) * 0.05)
        }
        XCTAssertEqual(detectedCount, 1)
    }

    // Reversals of 20pt — below 30pt minDistance threshold, no shake
    func testNoShakeBelowMinDistance() {
        let xs: [CGFloat] = [0, 20, 0, 20, 0, 20]
        for (i, x) in xs.enumerated() {
            detector.update(point: CGPoint(x: x, y: 0),
                            timestamp: Double(i) * 0.05)
        }
        XCTAssertEqual(detectedCount, 0)
    }

    // Continuous shaking must fire onShakeDetected exactly once
    func testShakeNotFiredTwiceWhileContinuous() {
        let xs: [CGFloat] = [0, 50, 0, 50, 0, 50, 0, 50, 0, 50]
        for (i, x) in xs.enumerated() {
            detector.update(point: CGPoint(x: x, y: 0),
                            timestamp: Double(i) * 0.05)
        }
        XCTAssertEqual(detectedCount, 1)
    }

    // 3 reversals spread 0.3s apart — window is 0.5s, only 2 points fit → no shake
    func testNoShakeWhenReversalsOutsideWindow() {
        let events: [(CGFloat, TimeInterval)] = [
            (0, 0.0), (50, 0.3), (0, 0.6), (50, 0.9), (0, 1.2)
        ]
        for (x, t) in events {
            detector.update(point: CGPoint(x: x, y: 0), timestamp: t)
        }
        XCTAssertEqual(detectedCount, 0)
    }
}
