import Foundation
import ApplicationServices
import AppKit

enum WindowDiscoveryService {
    static func discoverTerminalWindows() -> [TerminalWindow] {
        let knownBundleIDs = TerminalApp.allBundleIDs
        let runningApps = NSWorkspace.shared.runningApplications

        var windows: [TerminalWindow] = []

        for app in runningApps {
            guard let bundleID = app.bundleIdentifier,
                  knownBundleIDs.contains(bundleID) else { continue }

            let pid = app.processIdentifier
            let appName = app.localizedName ?? bundleID
            let axApp = AXUIElementCreateApplication(pid)
            let axWindows = axApp.getWindows()

            for axWindow in axWindows {
                guard axWindow.isStandardWindow(),
                      let position = axWindow.getPosition(),
                      let size = axWindow.getSize() else { continue }

                // Try to get window ID from CGWindowList
                let windowID = Self.windowID(for: axWindow, pid: pid)

                let title = axWindow.getStringValue(kAXTitleAttribute as String) ?? ""

                let termWindow = TerminalWindow(
                    id: windowID,
                    axElement: axWindow,
                    ownerPID: pid,
                    ownerName: appName,
                    title: title,
                    position: position,
                    size: size
                )
                windows.append(termWindow)
            }
        }

        return windows
    }

    private static func windowID(for axWindow: AXUIElement, pid: pid_t) -> CGWindowID {
        // Use CGWindowList to match windows by PID and position
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let infoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return CGWindowID(arc4random())
        }

        let axPos = axWindow.getPosition() ?? .zero
        let axSize = axWindow.getSize() ?? .zero

        for info in infoList {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t,
                  ownerPID == pid,
                  let bounds = info[kCGWindowBounds as String] as? [String: CGFloat],
                  let windowNumber = info[kCGWindowNumber as String] as? CGWindowID else { continue }

            let x = bounds["X"] ?? 0
            let y = bounds["Y"] ?? 0
            let w = bounds["Width"] ?? 0
            let h = bounds["Height"] ?? 0

            if abs(x - axPos.x) < 2 && abs(y - axPos.y) < 2 &&
               abs(w - axSize.width) < 2 && abs(h - axSize.height) < 2 {
                return windowNumber
            }
        }

        return CGWindowID(arc4random())
    }
}
