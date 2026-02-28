import SwiftUI

struct LayoutThumbnailView: View {
    let layout: TileLayout
    let windowCount: Int
    let isSelected: Bool

    var body: some View {
        let size = TileTermTheme.thumbnailSize
        let inset = TileTermTheme.thumbnailInset
        let innerRect = CGRect(
            x: inset, y: inset,
            width: size - 2 * inset,
            height: size - 2 * inset
        )
        let frames = layout.frames(for: windowCount, in: innerRect)

        ZStack {
            RoundedRectangle(cornerRadius: TileTermTheme.thumbnailCornerRadius)
                .fill(isSelected ? TileTermTheme.selectedFill : TileTermTheme.thumbnailBackground)
                .stroke(isSelected ? TileTermTheme.selectedStroke : Color.clear, lineWidth: 2)

            Canvas { context, _ in
                for frame in frames {
                    let path = RoundedRectangle(cornerRadius: TileTermTheme.windowCornerRadius)
                        .path(in: frame)
                    context.fill(path, with: .color(TileTermTheme.windowFill))
                    context.stroke(path, with: .color(TileTermTheme.windowStroke), lineWidth: 1)
                }
            }
        }
        .frame(width: size, height: size)
    }
}
