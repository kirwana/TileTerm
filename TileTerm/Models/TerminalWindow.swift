import Foundation
@preconcurrency import ApplicationServices

struct TerminalWindow: Identifiable, @unchecked Sendable {
    let id: CGWindowID
    let axElement: AXUIElement
    let ownerPID: pid_t
    let ownerName: String
    let title: String
    var position: CGPoint
    var size: CGSize

    var frame: CGRect {
        CGRect(origin: position, size: size)
    }
}
