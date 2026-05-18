import AppKit

final class OverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: CGRect(origin: .zero, size: screen.frame.size),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        setFrameOrigin(screen.frame.origin)
        level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue - 1)
        ignoresMouseEvents     = true
        backgroundColor        = .clear
        isOpaque               = false
        hasShadow              = false
        isReleasedWhenClosed   = false
        collectionBehavior     = [.canJoinAllSpaces, .stationary, .ignoresCycle]
    }
}
