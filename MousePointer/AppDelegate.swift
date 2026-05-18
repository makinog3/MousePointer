import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: OverlayWindowController?
    private var eventMonitor:     MouseEventMonitor?
    private var shakeDetector:    ShakeDetector?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard AXIsProcessTrusted() else {
            showAccessibilityAlert()
            return
        }
        start()
    }

    private func start() {
        let controller = OverlayWindowController()
        controller.setup()

        let detector = ShakeDetector()
        detector.onShakeDetected = { [weak controller] in
            DispatchQueue.main.async { controller?.startShake() }
        }
        detector.onShakeEnded = { [weak controller] in
            DispatchQueue.main.async { controller?.stopShake() }
        }

        let monitor = MouseEventMonitor()
        monitor.onMouseMoved = { [weak controller, weak detector] point in
            controller?.updateCursorPosition(point)
            detector?.update(point: point,
                             timestamp: ProcessInfo.processInfo.systemUptime)
        }
        monitor.onMouseDown = { [weak controller] point in
            controller?.triggerClick(at: point)
        }
        monitor.start()

        windowController = controller
        shakeDetector    = detector
        eventMonitor     = monitor
    }

    private func showAccessibilityAlert() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText     = "アクセシビリティ権限が必要です"
        alert.informativeText = """
            MousePointer はマウスイベントを監視するために \
            アクセシビリティ権限が必要です。
            システム設定 → プライバシーとセキュリティ → アクセシビリティ \
            で許可してから再起動してください。
            """
        alert.addButton(withTitle: "設定を開く")
        alert.addButton(withTitle: "終了")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(
                URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
        NSApp.terminate(nil)
    }
}
