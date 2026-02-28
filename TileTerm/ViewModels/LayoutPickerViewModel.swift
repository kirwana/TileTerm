import Foundation
import SwiftUI

@Observable
final class LayoutPickerViewModel {
    var windows: [TerminalWindow] = []
    var availableLayouts: [TileLayout] = []

    func refresh() {
        windows = WindowDiscoveryService.discoverTerminalWindows()
        availableLayouts = TileLayout.available(for: windows.count)
    }

    func apply(_ layout: TileLayout) {
        TilingEngine.tile(windows: windows, layout: layout)
    }
}
