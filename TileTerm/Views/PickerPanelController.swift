import AppKit
import SwiftUI

@Observable
@MainActor
final class PickerPanelController {
    private var panel: PickerPanel?
    private var escapeMonitor: Any?
    private(set) var isVisible = false

    private let viewModel = LayoutPickerViewModel()

    func toggle() {
        if isVisible {
            dismiss()
        } else {
            show()
        }
    }

    func show() {
        guard !isVisible else { return }

        // Refresh window list
        viewModel.refresh()

        let pickerView = LayoutPickerView(
            viewModel: viewModel,
            onSelect: { [weak self] layout in
                self?.viewModel.apply(layout)
                self?.dismiss()
            },
            onDismiss: { [weak self] in
                self?.dismiss()
            }
        )

        let hostingView = NSHostingView(rootView: pickerView)
        hostingView.setFrameSize(hostingView.fittingSize)

        let panel = PickerPanel(
            contentRect: NSRect(origin: .zero, size: hostingView.fittingSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        // Add a visual effect background
        let visualEffect = NSVisualEffectView(frame: NSRect(origin: .zero, size: hostingView.fittingSize))
        visualEffect.material = .hudWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 12
        visualEffect.layer?.masksToBounds = true
        visualEffect.addSubview(hostingView)
        hostingView.frame = visualEffect.bounds
        hostingView.autoresizingMask = [.width, .height]

        panel.contentView = visualEffect

        // Center on the current screen
        let screen = ScreenService.currentScreen
        let screenFrame = screen.visibleFrame
        let panelSize = hostingView.fittingSize
        let origin = NSPoint(
            x: screenFrame.midX - panelSize.width / 2,
            y: screenFrame.midY - panelSize.height / 2
        )
        panel.setFrameOrigin(origin)

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
        isVisible = true

        // Monitor Escape key
        escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.dismiss()
                return nil
            }
            return event
        }
    }

    func dismiss() {
        guard isVisible else { return }
        panel?.orderOut(nil)
        panel = nil
        isVisible = false

        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
        }
    }
}
