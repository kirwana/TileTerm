import AppKit

@Observable
@MainActor
final class HotkeyService {
    private var globalMonitor: Any?
    private(set) var triggerCount = 0

    init() {
        startMonitoring()
        AccessibilityService.promptIfNeeded()
    }

    private func startMonitoring() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                self?.handleKeyEvent(event)
            }
        }
    }

    func stopMonitoring() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        // Ctrl+Opt+T (keyCode 17 = T)
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if event.keyCode == 17 && flags == [.control, .option] {
            triggerCount += 1
        }
    }
}
