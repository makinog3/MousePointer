import AppKit

final class EffectHostView: NSView {
    // AppKit default: y=0 at bottom — matches CALayer coordinate space
    override var isFlipped: Bool { false }

    override func makeBackingLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = CGColor.clear
        return layer
    }

    override var wantsUpdateLayer: Bool { true }
}
