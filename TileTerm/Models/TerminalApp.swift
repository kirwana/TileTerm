import Foundation

struct TerminalApp: Identifiable, Hashable, Codable, Sendable {
    let bundleID: String
    let name: String

    var id: String { bundleID }

    static let builtIn: [TerminalApp] = [
        TerminalApp(bundleID: "com.apple.Terminal", name: "Terminal"),
        TerminalApp(bundleID: "com.googlecode.iterm2", name: "iTerm2"),
        TerminalApp(bundleID: "com.mitchellh.ghostty", name: "Ghostty"),
        TerminalApp(bundleID: "dev.warp.Warp-Stable", name: "Warp"),
        TerminalApp(bundleID: "co.zeit.hyper", name: "Hyper"),
        TerminalApp(bundleID: "com.github.wez.wezterm", name: "WezTerm"),
        TerminalApp(bundleID: "net.kovidgoyal.kitty", name: "kitty"),
        TerminalApp(bundleID: "io.alacritty", name: "Alacritty"),
    ]

    static let customDefaultsKey = "customTerminalApps"

    static func loadCustom() -> [TerminalApp] {
        guard let data = UserDefaults.standard.data(forKey: customDefaultsKey),
              let apps = try? JSONDecoder().decode([TerminalApp].self, from: data) else {
            return []
        }
        return apps
    }

    static func saveCustom(_ apps: [TerminalApp]) {
        if let data = try? JSONEncoder().encode(apps) {
            UserDefaults.standard.set(data, forKey: customDefaultsKey)
        }
    }

    static var allKnown: [TerminalApp] {
        builtIn + loadCustom()
    }

    static var allBundleIDs: Set<String> {
        Set(allKnown.map(\.bundleID))
    }
}
