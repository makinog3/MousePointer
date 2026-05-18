import AppKit

final class OverlayWindowController {
    // Keyed by ObjectIdentifier(screen) — stable within a buildWindows() call
    private var windows:        [ObjectIdentifier: OverlayWindow]        = [:]
    private var shakeRenderers: [ObjectIdentifier: ShakeEffectRenderer]  = [:]
    private var clickRenderers: [ObjectIdentifier: ClickEffectRenderer]  = [:]

    func setup() {
        buildWindows()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    // MARK: - Public event API

    func updateCursorPosition(_ quartzPoint: CGPoint) {
        guard let (screen, local) = resolve(quartzPoint) else { return }
        shakeRenderers[ObjectIdentifier(screen)]?.moveTo(local)
    }

    func triggerClick(at quartzPoint: CGPoint) {
        guard let (screen, local) = resolve(quartzPoint) else { return }
        clickRenderers[ObjectIdentifier(screen)]?.fire(at: local)
    }

    func startShake() { shakeRenderers.values.forEach { $0.startShake() } }
    func stopShake()  { shakeRenderers.values.forEach { $0.stopShake()  } }

    // MARK: - Private

    private func buildWindows() {
        windows.values.forEach { $0.close() }
        windows.removeAll()
        shakeRenderers.removeAll()
        clickRenderers.removeAll()

        for screen in NSScreen.screens {
            let id = ObjectIdentifier(screen)
            let window = OverlayWindow(screen: screen)
            let hostView = EffectHostView(
                frame: CGRect(origin: .zero, size: screen.frame.size))
            window.contentView  = hostView
            window.orderFrontRegardless()
            windows[id] = window

            guard let root = hostView.layer else { continue }
            shakeRenderers[id] = ShakeEffectRenderer(layer: root)
            clickRenderers[id] = ClickEffectRenderer(layer: root)
        }
    }

    @objc private func screensChanged() { buildWindows() }

    // MARK: - Coordinate helpers
    //
    // CGEventTap returns Quartz coordinates: origin at top-left of primary screen,
    // y increases downward.
    // AppKit / CALayer use: origin at bottom-left, y increases upward.
    // Conversion: appkitY = primaryScreenHeight - quartzY

    private func quartzToAppKit(_ p: CGPoint) -> CGPoint {
        // Primary screen is the one whose AppKit frame origin is (0,0)
        let primary = NSScreen.screens.first { $0.frame.origin == .zero }
                      ?? NSScreen.screens[0]
        return CGPoint(x: p.x, y: primary.frame.height - p.y)
    }

    private func resolve(_ quartzPoint: CGPoint) -> (NSScreen, CGPoint)? {
        guard let fallback = NSScreen.screens.first else { return nil }
        let ap = quartzToAppKit(quartzPoint)
        let screen = NSScreen.screens.first { $0.frame.contains(ap) } ?? fallback
        let local  = CGPoint(x: ap.x - screen.frame.origin.x,
                             y: ap.y - screen.frame.origin.y)
        return (screen, local)
    }
}
