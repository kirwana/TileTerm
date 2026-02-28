import SwiftUI

@main
struct TileTermApp: App {
    @State private var hotkeyService = HotkeyService()
    @State private var pickerController = PickerPanelController()

    var body: some Scene {
        MenuBarExtra("TileTerm", systemImage: "rectangle.split.2x2") {
            MenuBarView(pickerController: pickerController)
        }
        .onChange(of: hotkeyService.triggerCount) {
            pickerController.toggle()
        }
    }
}
