import Foundation
import AppKit

enum ScreenService {
    /// Returns the screen where the mouse cursor currently is.
    static var currentScreen: NSScreen {
        let mouseLocation = NSEvent.mouseLocation
        for screen in NSScreen.screens {
            if screen.frame.contains(mouseLocation) {
                return screen
            }
        }
        return NSScreen.main ?? NSScreen.screens[0]
    }

    /// Returns the visible frame in AX coordinates (top-left origin).
    /// NSScreen uses bottom-left origin; AX API uses top-left origin.
    static func visibleFrameInAXCoordinates(for screen: NSScreen) -> CGRect {
        let visibleFrame = screen.visibleFrame

        // Find the primary screen (with the menu bar) for coordinate conversion
        guard let primaryScreen = NSScreen.screens.first else {
            return visibleFrame
        }

        let primaryHeight = primaryScreen.frame.height

        // Convert from bottom-left (NS) to top-left (AX) coordinates
        let axY = primaryHeight - visibleFrame.maxY
        return CGRect(
            x: visibleFrame.origin.x,
            y: axY,
            width: visibleFrame.width,
            height: visibleFrame.height
        )
    }
}
