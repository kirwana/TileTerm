import Foundation
import ApplicationServices

extension AXUIElement {
    func getValue<T>(_ attribute: String) -> T? {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, attribute as CFString, &value)
        guard result == .success else { return nil }
        return value as? T
    }

    func getPosition() -> CGPoint? {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, kAXPositionAttribute as String as CFString, &value)
        guard result == .success else { return nil }
        var point = CGPoint.zero
        if AXValueGetValue(value as! AXValue, .cgPoint, &point) {
            return point
        }
        return nil
    }

    func getSize() -> CGSize? {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, kAXSizeAttribute as String as CFString, &value)
        guard result == .success else { return nil }
        var size = CGSize.zero
        if AXValueGetValue(value as! AXValue, .cgSize, &size) {
            return size
        }
        return nil
    }

    func setPosition(_ point: CGPoint) {
        var mutablePoint = point
        guard let value = AXValueCreate(.cgPoint, &mutablePoint) else { return }
        AXUIElementSetAttributeValue(self, kAXPositionAttribute as CFString, value)
    }

    func setSize(_ size: CGSize) {
        var mutableSize = size
        guard let value = AXValueCreate(.cgSize, &mutableSize) else { return }
        AXUIElementSetAttributeValue(self, kAXSizeAttribute as CFString, value)
    }

    func getWindows() -> [AXUIElement] {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, kAXWindowsAttribute as String as CFString, &value)
        guard result == .success, let windows = value as? [AXUIElement] else { return [] }
        return windows
    }

    func getStringValue(_ attribute: String) -> String? {
        getValue(attribute) as String?
    }

    func getRole() -> String? {
        getStringValue(kAXRoleAttribute as String)
    }

    func getSubrole() -> String? {
        getStringValue(kAXSubroleAttribute as String)
    }

    func isStandardWindow() -> Bool {
        getSubrole() == kAXStandardWindowSubrole as String
    }
}
