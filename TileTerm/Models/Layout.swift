import Foundation

enum TileLayout: String, CaseIterable, Identifiable, Sendable {
    // 1 window
    case maximize

    // 2 windows
    case sideBySide
    case topBottom
    case masterSide

    // 3 windows
    case twoTopOneBottom
    case oneTopTwoBottom
    case masterTwoStacked

    // 4 windows
    case grid2x2
    case masterThreeStacked

    // 5+ windows
    case autoGrid
    case masterNStacked

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .maximize: "Maximize"
        case .sideBySide: "Side by Side"
        case .topBottom: "Top / Bottom"
        case .masterSide: "Master + Side"
        case .twoTopOneBottom: "2 Top + 1 Bottom"
        case .oneTopTwoBottom: "1 Top + 2 Bottom"
        case .masterTwoStacked: "Master + 2 Stack"
        case .grid2x2: "2x2 Grid"
        case .masterThreeStacked: "Master + 3 Stack"
        case .autoGrid: "Auto Grid"
        case .masterNStacked: "Master + Stack"
        }
    }

    static func available(for windowCount: Int) -> [TileLayout] {
        switch windowCount {
        case 0: return []
        case 1: return [.maximize]
        case 2: return [.sideBySide, .topBottom, .masterSide]
        case 3: return [.twoTopOneBottom, .oneTopTwoBottom, .masterTwoStacked]
        case 4: return [.grid2x2, .masterThreeStacked]
        default: return [.autoGrid, .masterNStacked]
        }
    }

    func frames(for windowCount: Int, in rect: CGRect) -> [CGRect] {
        let gap = TileTermTheme.gap
        switch self {
        case .maximize:
            return [rect]

        case .sideBySide:
            let w = (rect.width - gap) / 2
            return [
                CGRect(x: rect.minX, y: rect.minY, width: w, height: rect.height),
                CGRect(x: rect.minX + w + gap, y: rect.minY, width: w, height: rect.height),
            ]

        case .topBottom:
            let h = (rect.height - gap) / 2
            return [
                CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: h),
                CGRect(x: rect.minX, y: rect.minY + h + gap, width: rect.width, height: h),
            ]

        case .masterSide:
            let masterW = rect.width * 0.65
            let sideW = rect.width - masterW - gap
            return [
                CGRect(x: rect.minX, y: rect.minY, width: masterW, height: rect.height),
                CGRect(x: rect.minX + masterW + gap, y: rect.minY, width: sideW, height: rect.height),
            ]

        case .twoTopOneBottom:
            let h = (rect.height - gap) / 2
            let w = (rect.width - gap) / 2
            return [
                CGRect(x: rect.minX, y: rect.minY, width: w, height: h),
                CGRect(x: rect.minX + w + gap, y: rect.minY, width: w, height: h),
                CGRect(x: rect.minX, y: rect.minY + h + gap, width: rect.width, height: h),
            ]

        case .oneTopTwoBottom:
            let h = (rect.height - gap) / 2
            let w = (rect.width - gap) / 2
            return [
                CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: h),
                CGRect(x: rect.minX, y: rect.minY + h + gap, width: w, height: h),
                CGRect(x: rect.minX + w + gap, y: rect.minY + h + gap, width: w, height: h),
            ]

        case .masterTwoStacked:
            let masterW = rect.width * 0.65
            let sideW = rect.width - masterW - gap
            let sideH = (rect.height - gap) / 2
            return [
                CGRect(x: rect.minX, y: rect.minY, width: masterW, height: rect.height),
                CGRect(x: rect.minX + masterW + gap, y: rect.minY, width: sideW, height: sideH),
                CGRect(x: rect.minX + masterW + gap, y: rect.minY + sideH + gap, width: sideW, height: sideH),
            ]

        case .grid2x2:
            let w = (rect.width - gap) / 2
            let h = (rect.height - gap) / 2
            return [
                CGRect(x: rect.minX, y: rect.minY, width: w, height: h),
                CGRect(x: rect.minX + w + gap, y: rect.minY, width: w, height: h),
                CGRect(x: rect.minX, y: rect.minY + h + gap, width: w, height: h),
                CGRect(x: rect.minX + w + gap, y: rect.minY + h + gap, width: w, height: h),
            ]

        case .masterThreeStacked:
            let masterW = rect.width * 0.65
            let sideW = rect.width - masterW - gap
            let sideH = (rect.height - 2 * gap) / 3
            return [
                CGRect(x: rect.minX, y: rect.minY, width: masterW, height: rect.height),
                CGRect(x: rect.minX + masterW + gap, y: rect.minY, width: sideW, height: sideH),
                CGRect(x: rect.minX + masterW + gap, y: rect.minY + sideH + gap, width: sideW, height: sideH),
                CGRect(x: rect.minX + masterW + gap, y: rect.minY + 2 * (sideH + gap), width: sideW, height: sideH),
            ]

        case .autoGrid:
            return Self.autoGridFrames(count: windowCount, in: rect, gap: gap)

        case .masterNStacked:
            return Self.masterNStackedFrames(count: windowCount, in: rect, gap: gap)
        }
    }

    private static func autoGridFrames(count: Int, in rect: CGRect, gap: CGFloat) -> [CGRect] {
        guard count > 0 else { return [] }

        let cols = Int(ceil(sqrt(Double(count))))
        let rows = Int(ceil(Double(count) / Double(cols)))

        let cellW = (rect.width - gap * CGFloat(cols - 1)) / CGFloat(cols)
        let cellH = (rect.height - gap * CGFloat(rows - 1)) / CGFloat(rows)

        var frames: [CGRect] = []
        for i in 0..<count {
            let col = i % cols
            let row = i / cols
            frames.append(CGRect(
                x: rect.minX + CGFloat(col) * (cellW + gap),
                y: rect.minY + CGFloat(row) * (cellH + gap),
                width: cellW,
                height: cellH
            ))
        }
        return frames
    }

    private static func masterNStackedFrames(count: Int, in rect: CGRect, gap: CGFloat) -> [CGRect] {
        guard count > 0 else { return [] }
        if count == 1 { return [rect] }

        let masterW = rect.width * 0.65
        let sideW = rect.width - masterW - gap
        let sideCount = count - 1
        let sideH = (rect.height - gap * CGFloat(sideCount - 1)) / CGFloat(sideCount)

        var frames: [CGRect] = [
            CGRect(x: rect.minX, y: rect.minY, width: masterW, height: rect.height)
        ]

        for i in 0..<sideCount {
            frames.append(CGRect(
                x: rect.minX + masterW + gap,
                y: rect.minY + CGFloat(i) * (sideH + gap),
                width: sideW,
                height: sideH
            ))
        }
        return frames
    }
}
