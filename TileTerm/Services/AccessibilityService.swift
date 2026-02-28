import Foundation
import ApplicationServices

enum AccessibilityService {
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    static func promptIfNeeded() {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    static func moveWindow(_ window: TerminalWindow, to frame: CGRect) {
        window.axElement.setPosition(frame.origin)
        window.axElement.setSize(frame.size)
        // Set size again in case the position change constrained it
        window.axElement.setSize(frame.size)
    }

    static func raiseWindow(_ window: TerminalWindow) {
        AXUIElementPerformAction(window.axElement, kAXRaiseAction as CFString)
    }
}
