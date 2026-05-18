import Foundation
import CoreGraphics

struct TimedPoint {
    let point: CGPoint
    let timestamp: TimeInterval
}

final class ShakeDetector {
    static let windowDuration: TimeInterval  = 0.5
    static let requiredReversals             = 3
    static let minDistance: CGFloat          = 30.0
    static let cooldownDuration: TimeInterval = 0.6
    private static let bufferCapacity        = 120

    var onShakeDetected: (() -> Void)?
    var onShakeEnded: (() -> Void)?

    private(set) var isShaking = false
    private var buffer: [TimedPoint] = []
    private var pendingEnd: DispatchWorkItem?

    func update(point: CGPoint, timestamp: TimeInterval) {
        buffer.append(TimedPoint(point: point, timestamp: timestamp))
        if buffer.count > Self.bufferCapacity { buffer.removeFirst() }

        guard detectShake(at: timestamp) else { return }

        if !isShaking {
            isShaking = true
            onShakeDetected?()
        }
        schedulePendingEnd()
    }

    private func detectShake(at now: TimeInterval) -> Bool {
        let recent = buffer.filter { now - $0.timestamp <= Self.windowDuration }
        guard recent.count >= 4 else { return false }

        // Measure per-swing distance (cumulative movement per direction), not
        // per-event delta. At 60 Hz the per-event delta is only a few points
        // even during a fast shake, so individual steps never hit minDistance.
        var reversals = 0
        var swingStartX = recent[0].point.x
        var currentDir  = 0  // 0 = undetermined, +1 = right, -1 = left

        for i in 1..<recent.count {
            let dx = recent[i].point.x - recent[i - 1].point.x
            guard dx != 0 else { continue }
            let dir = dx > 0 ? 1 : -1

            if currentDir == 0 {
                currentDir = dir
            } else if dir != currentDir {
                if abs(recent[i - 1].point.x - swingStartX) >= Self.minDistance {
                    reversals += 1
                    swingStartX = recent[i - 1].point.x
                }
                currentDir = dir
            }
        }

        return reversals >= Self.requiredReversals
    }

    private func schedulePendingEnd() {
        pendingEnd?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.isShaking else { return }
            self.isShaking = false
            self.onShakeEnded?()
        }
        pendingEnd = work
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Self.cooldownDuration, execute: work)
    }
}
