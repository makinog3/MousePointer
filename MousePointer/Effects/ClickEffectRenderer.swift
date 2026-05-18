import AppKit
import QuartzCore

final class ClickEffectRenderer: NSObject, CAAnimationDelegate {
    private weak var rootLayer: CALayer?

    init(layer: CALayer) {
        self.rootLayer = layer
    }

    func fire(at point: CGPoint) {
        let ring = makeRingLayer(at: point)
        let group = makeRippleAnimation(for: ring)
        rootLayer?.addSublayer(ring)
        ring.add(group, forKey: "ripple")
    }

    // MARK: - CAAnimationDelegate

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        (anim.value(forKey: "layer") as? CALayer)?.removeFromSuperlayer()
    }

    // MARK: - Private helpers

    private func makeRingLayer(at point: CGPoint) -> CAShapeLayer {
        let d: CGFloat = 44
        let ring = CAShapeLayer()
        ring.path        = CGPath(ellipseIn: CGRect(x: -d/2, y: -d/2, width: d, height: d),
                                 transform: nil)
        ring.fillColor   = nil
        ring.strokeColor = CGColor(red: 0, green: 0.812, blue: 1.0, alpha: 0.9)  // #00cfff
        ring.lineWidth   = 2
        ring.position    = point
        return ring
    }

    private func makeRippleAnimation(for ring: CAShapeLayer) -> CAAnimationGroup {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.4
        scale.toValue   = 2.0

        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0.9
        opacity.toValue   = 0.0

        let group = CAAnimationGroup()
        group.animations            = [scale, opacity]
        group.duration              = 0.4
        group.timingFunction        = CAMediaTimingFunction(name: .easeOut)
        group.fillMode              = .forwards
        group.isRemovedOnCompletion = false
        group.delegate              = self
        group.setValue(ring, forKey: "layer")
        return group
    }
}
