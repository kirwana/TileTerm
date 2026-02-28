import SwiftUI

struct MenuBarView: View {
    let pickerController: PickerPanelController

    var body: some View {
        Button("Tile Windows") {
            pickerController.toggle()
        }
        .keyboardShortcut("t", modifiers: [.control, .option])

        Divider()

        Button("Settings...") {
            SettingsWindowController.shared.show()
        }

        Divider()

        Button("Quit TileTerm") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show() {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.setFrameSize(hostingView.fittingSize)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: hostingView.fittingSize),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "TileTerm Settings"
        window.contentView = hostingView
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }
}
