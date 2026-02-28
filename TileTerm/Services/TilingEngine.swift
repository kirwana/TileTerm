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

        // Raise the first window to front
        if let first = windows.first {
            AccessibilityService.raiseWindow(first)
        }
    }
}
