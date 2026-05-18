import AppKit
import QuartzCore

final class ShakeEffectRenderer {
    private let innerRing: CAShapeLayer  // diameter 56pt, opacity 1.0
    private let outerRing: CAShapeLayer  // diameter 80pt, opacity 0.6

    init(layer: CALayer) {
        innerRing = Self.makeRing(diameter: 56)
        outerRing = Self.makeRing(diameter: 80)
        layer.addSublayer(outerRing)
        layer.addSublayer(innerRing)
        innerRing.opacity = 0
        outerRing.opacity = 0
    }

    private static func makeRing(diameter: CGFloat) -> CAShapeLayer {
        let s = CAShapeLayer()
        s.path = CGPath(
            ellipseIn: CGRect(x: -diameter/2, y: -diameter/2,
                              width: diameter, height: diameter),
            transform: nil)
        s.fillColor   = nil
        s.strokeColor = CGColor(red: 0.941, green: 0.647, blue: 0.0, alpha: 1.0)  // #f0a500
        s.lineWidth   = 2
        return s
    }

    // MARK: - Public API

    func moveTo(_ point: CGPoint) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        innerRing.position = point
        outerRing.position = point
        CATransaction.commit()
    }

    func startShake() {
        let targets: [(CAShapeLayer, Float)] = [(innerRing, 1.0), (outerRing, 0.6)]
        for (ring, targetOpacity) in targets {
            ring.removeAllAnimations()
            ring.opacity = targetOpacity

            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.fromValue      = 0.9
            pulse.toValue        = 1.25
            pulse.duration       = 0.9
            pulse.autoreverses   = true
            pulse.repeatCount    = .infinity
            pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            ring.add(pulse, forKey: "pulse")
        }
    }

    func stopShake() {
        for ring in [innerRing, outerRing] {
            ring.removeAnimation(forKey: "pulse")
            let currentOpacity = ring.presentation()?.opacity ?? ring.opacity
            ring.opacity = 0

            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue             = currentOpacity
            fade.toValue               = Float(0)
            fade.duration              = 1.0
            fade.fillMode              = .forwards
            fade.isRemovedOnCompletion = false
            ring.add(fade, forKey: "fadeOut")
        }
    }
}
