import AppKit

final class EffectHostView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    // y=0 at bottom — matches CALayer coordinate space
    override var isFlipped: Bool { false }

    override func makeBackingLayer() -> CALayer {
        let layer = CALayer()
        layer.backgroundColor = CGColor.clear
        return layer
    }

    override var wantsUpdateLayer: Bool { true }
}
