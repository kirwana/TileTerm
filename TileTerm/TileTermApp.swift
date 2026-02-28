import SwiftUI
import Carbon

@main
struct TileTermApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("TileTerm", systemImage: "rectangle.split.2x2") {
            Button("Tile Windows") {
                appDelegate.pickerController.toggle()
            }
            .keyboardShortcut("t", modifiers: [.control, .option])

            Divider()

            Button("Settings...") {
                appDelegate.showSettings()
            }

            Divider()

            Button("Quit TileTerm") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let pickerController = PickerPanelController()
    private var hotKeyRef: EventHotKeyRef?
    private var settingsWindow: NSWindow?

    private static var sharedInstance: AppDelegate?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AccessibilityService.promptIfNeeded()
        AppDelegate.sharedInstance = self
        registerHotKey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }

    private func registerHotKey() {
        // Install Carbon event handler for hot key
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ -> OSStatus in
                Task { @MainActor in
                    AppDelegate.sharedInstance?.pickerController.toggle()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        // Register Ctrl+Opt+T
        // Carbon modifier flags: controlKey = 0x1000, optionKey = 0x0800
        // Carbon keycode for T = 17
        let hotKeyID = EventHotKeyID(signature: fourCharCode("TILE"), id: 1)
        var ref: EventHotKeyRef?
        let modifiers: UInt32 = UInt32(controlKey | optionKey)

        let status = RegisterEventHotKey(
            17, // T key
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )

        if status == noErr {
            hotKeyRef = ref
        }
    }

    func showSettings() {
        if let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
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

        self.settingsWindow = window
    }
}

private func fourCharCode(_ string: String) -> OSType {
    var result: OSType = 0
    for char in string.utf8.prefix(4) {
        result = (result << 8) | OSType(char)
    }
    return result
}
