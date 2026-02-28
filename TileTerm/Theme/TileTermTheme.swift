import SwiftUI

enum TileTermTheme {
    // MARK: - Colors
    static let accent = Color.blue
    static let windowFill = Color.blue.opacity(0.25)
    static let windowStroke = Color.blue.opacity(0.6)
    static let selectedFill = Color.blue.opacity(0.4)
    static let selectedStroke = Color.blue
    static let panelBackground = Color(nsColor: .windowBackgroundColor)
    static let thumbnailBackground = Color(nsColor: .controlBackgroundColor)
    static let labelPrimary = Color(nsColor: .labelColor)
    static let labelSecondary = Color(nsColor: .secondaryLabelColor)

    // MARK: - Spacing
    static let gap: CGFloat = 6
    static let thumbnailSize: CGFloat = 80
    static let gridSpacing: CGFloat = 12
    static let panelPadding: CGFloat = 20

    // MARK: - Thumbnail
    static let thumbnailCornerRadius: CGFloat = 6
    static let windowCornerRadius: CGFloat = 3
    static let thumbnailInset: CGFloat = 6
}
