import Foundation
import AppKit

enum TilingEngine {
    static func tile(windows: [TerminalWindow], layout: TileLayout, on screen: NSScreen? = nil) {
        guard !windows.isEmpty else { return }

        let targetScreen = screen ?? ScreenService.currentScreen
        let rect = ScreenService.visibleFrameInAXCoordinates(for: targetScreen)
        let frames = layout.frames(for: windows.count, in: rect)

        for (index, window) in windows.enumerated() {
            guard index < frames.count else { break }
            AccessibilityService.moveWindow(window, to: frames[index])
        }

        // Raise all windows (last-to-first so the first window ends up on top)
        for window in windows.reversed() {
            AccessibilityService.raiseWindow(window)
        }

        // Activate the owning apps so all tiled windows are visible
        let pids = Set(windows.map(\.ownerPID))
        for pid in pids {
            if let app = NSRunningApplication(processIdentifier: pid) {
                app.activate()
            }
        }
    }
}
