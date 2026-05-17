import Foundation
import CoreGraphics

struct TimedPoint {
    let point: CGPoint
    let timestamp: TimeInterval
}

final class ShakeDetector {
    // MARK: - Configuration constants
    static let windowDuration: TimeInterval  = 0.5   // seconds of history to examine
    static let requiredReversals              = 3     // min direction reversals
    static let minDistance: CGFloat           = 30.0  // pt per reversal
    static let cooldownDuration: TimeInterval = 0.6   // seconds before shakeEnded fires
    private static let bufferCapacity         = 20

    // MARK: - Callbacks
    var onShakeDetected: (() -> Void)?
    var onShakeEnded: (() -> Void)?

    // MARK: - State
    private(set) var isShaking = false
    private var buffer: [TimedPoint] = []
    private var pendingEnd: DispatchWorkItem?

    func update(point: CGPoint, timestamp: TimeInterval) {
        buffer.append(TimedPoint(point: point, timestamp: timestamp))
        if buffer.count > Self.bufferCapacity { buffer.removeFirst() }

        guard detectShake(at: timestamp) else { return }

        pendingEnd?.cancel()
        if !isShaking {
            isShaking = true
            onShakeDetected?()
        }
        schedulePendingEnd()
    }

    private func detectShake(at now: TimeInterval) -> Bool {
        let recent = buffer.filter { now - $0.timestamp <= Self.windowDuration }
        guard recent.count >= 4 else { return false }

        var reversals = 0
        var prevSign: Int? = nil

        for i in 1..<recent.count {
            let dx = recent[i].point.x - recent[i-1].point.x
            guard abs(dx) >= Self.minDistance else { continue }
            let sign = dx > 0 ? 1 : -1
            if let prev = prevSign, prev != sign { reversals += 1 }
            prevSign = sign
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
