import SwiftUI

struct LayoutPickerView: View {
    let viewModel: LayoutPickerViewModel
    let onSelect: (TileLayout) -> Void
    let onDismiss: () -> Void

    @State private var hoveredLayout: TileLayout?

    var body: some View {
        VStack(spacing: TileTermTheme.gridSpacing) {
            // Header
            HStack {
                Text("Tile \(viewModel.windows.count) window\(viewModel.windows.count == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundStyle(TileTermTheme.labelPrimary)
                Spacer()
                Text("Esc to cancel")
                    .font(.caption)
                    .foregroundStyle(TileTermTheme.labelSecondary)
            }

            if viewModel.availableLayouts.isEmpty {
                Text("No terminal windows found")
                    .font(.subheadline)
                    .foregroundStyle(TileTermTheme.labelSecondary)
                    .padding(.vertical, 20)
            } else {
                // Layout grid
                let columns = Array(repeating: GridItem(.fixed(TileTermTheme.thumbnailSize), spacing: TileTermTheme.gridSpacing), count: min(viewModel.availableLayouts.count, 4))

                LazyVGrid(columns: columns, spacing: TileTermTheme.gridSpacing) {
                    ForEach(viewModel.availableLayouts) { layout in
                        VStack(spacing: 4) {
                            LayoutThumbnailView(
                                layout: layout,
                                windowCount: viewModel.windows.count,
                                isSelected: hoveredLayout == layout
                            )
                            .onHover { isHovered in
                                hoveredLayout = isHovered ? layout : nil
                            }
                            .onTapGesture {
                                onSelect(layout)
                            }

                            Text(layout.displayName)
                                .font(.caption2)
                                .foregroundStyle(TileTermTheme.labelSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(TileTermTheme.panelPadding)
        .frame(minWidth: 200)
    }
}
