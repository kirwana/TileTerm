import Foundation
import ApplicationServices
import AppKit

enum WindowDiscoveryService {
    static func discoverTerminalWindows() -> [TerminalWindow] {
        let knownBundleIDs = TerminalApp.allBundleIDs
        let runningApps = NSWorkspace.shared.runningApplications

        // Build a map of PID -> bundleID for terminal apps
        var terminalPIDs: [pid_t: (bundleID: String, name: String)] = [:]
        for app in runningApps {
            guard let bundleID = app.bundleIdentifier,
                  knownBundleIDs.contains(bundleID) else { continue }
            let name = app.localizedName ?? bundleID
            terminalPIDs[app.processIdentifier] = (bundleID, name)
        }

        guard !terminalPIDs.isEmpty else { return [] }

        // If we have accessibility access, use AX API for full control
        if AXIsProcessTrusted() {
            return discoverViaAccessibility(terminalPIDs: terminalPIDs)
        }

        // Fallback: use CGWindowList (can detect windows but can't move them)
        return discoverViaCGWindowList(terminalPIDs: terminalPIDs)
    }

    private static func discoverViaAccessibility(terminalPIDs: [pid_t: (bundleID: String, name: String)]) -> [TerminalWindow] {
        var windows: [TerminalWindow] = []

        for (pid, info) in terminalPIDs {
            let axApp = AXUIElementCreateApplication(pid)
            let axWindows = axApp.getWindows()

            for axWindow in axWindows {
                guard let position = axWindow.getPosition(),
                      let size = axWindow.getSize(),
                      size.width > 0, size.height > 0 else { continue }

                // Accept standard windows, or any window with a valid size
                // (some terminals don't set subrole properly)
                let subrole = axWindow.getSubrole()
                let isStandard = subrole == kAXStandardWindowSubrole as String
                let hasRole = axWindow.getRole() == kAXWindowRole as String
                guard isStandard || hasRole else { continue }

                let windowID = Self.windowID(for: axWindow, pid: pid)
                let title = axWindow.getStringValue(kAXTitleAttribute as String) ?? ""

                windows.append(TerminalWindow(
                    id: windowID,
                    axElement: axWindow,
                    ownerPID: pid,
                    ownerName: info.name,
                    title: title,
                    position: position,
                    size: size
                ))
            }
        }

        return windows
    }

    private static func discoverViaCGWindowList(terminalPIDs: [pid_t: (bundleID: String, name: String)]) -> [TerminalWindow] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let infoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        var windows: [TerminalWindow] = []

        for info in infoList {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? Int32,
                  let appInfo = terminalPIDs[ownerPID],
                  let windowNumber = info[kCGWindowNumber as String] as? CGWindowID,
                  let boundsDict = CGRect(dictionaryRepresentation: info[kCGWindowBounds as String] as! CFDictionary),
                  let layer = info[kCGWindowLayer as String] as? Int,
                  layer == 0, // Normal window layer
                  boundsDict.width > 50, boundsDict.height > 50 else { continue }

            // Create AX element for this window's app so we can move it later
            let axApp = AXUIElementCreateApplication(ownerPID)
            let axWindows = axApp.getWindows()

            // Try to match by position
            var matchedAX: AXUIElement?
            for axWin in axWindows {
                if let pos = axWin.getPosition(),
                   abs(pos.x - boundsDict.origin.x) < 5 &&
                   abs(pos.y - boundsDict.origin.y) < 5 {
                    matchedAX = axWin
                    break
                }
            }

            // If we can't get AX element, we can still show the window in the picker
            // but won't be able to move it
            let axElement = matchedAX ?? axApp
            let title = info[kCGWindowName as String] as? String ?? ""

            windows.append(TerminalWindow(
                id: windowNumber,
                axElement: axElement,
                ownerPID: ownerPID,
                ownerName: appInfo.name,
                title: title,
                position: boundsDict.origin,
                size: boundsDict.size
            ))
        }

        return windows
    }

    private static func windowID(for axWindow: AXUIElement, pid: pid_t) -> CGWindowID {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let infoList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return CGWindowID(arc4random())
        }

        let axPos = axWindow.getPosition() ?? .zero
        let axSize = axWindow.getSize() ?? .zero

        for info in infoList {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t,
                  ownerPID == pid,
                  let boundsDict = CGRect(dictionaryRepresentation: info[kCGWindowBounds as String] as! CFDictionary),
                  let windowNumber = info[kCGWindowNumber as String] as? CGWindowID else { continue }

            if abs(boundsDict.origin.x - axPos.x) < 2 &&
               abs(boundsDict.origin.y - axPos.y) < 2 &&
               abs(boundsDict.width - axSize.width) < 2 &&
               abs(boundsDict.height - axSize.height) < 2 {
                return windowNumber
            }
        }

        return CGWindowID(arc4random())
    }
}
