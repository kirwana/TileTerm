import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var customApps: [TerminalApp] = TerminalApp.loadCustom()
    @State private var newBundleID = ""
    @State private var newName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TileTerm Settings")
                .font(.title2)
                .fontWeight(.semibold)

            GroupBox("Hotkey") {
                HStack {
                    Text("Tile Windows")
                    Spacer()
                    Text("Ctrl + Opt + T")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(8)
            }

            GroupBox("Built-in Terminals") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(TerminalApp.builtIn) { app in
                        HStack {
                            Text(app.name)
                            Spacer()
                            Text(app.bundleID)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(8)
            }

            GroupBox("Custom Terminals") {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(customApps) { app in
                        HStack {
                            Text(app.name)
                            Spacer()
                            Text(app.bundleID)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Button(role: .destructive) {
                                customApps.removeAll { $0.id == app.id }
                                TerminalApp.saveCustom(customApps)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }

                    Divider()

                    HStack {
                        TextField("Name", text: $newName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        TextField("Bundle ID", text: $newBundleID)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            guard !newBundleID.isEmpty, !newName.isEmpty else { return }
                            let app = TerminalApp(bundleID: newBundleID, name: newName)
                            customApps.append(app)
                            TerminalApp.saveCustom(customApps)
                            newBundleID = ""
                            newName = ""
                        }
                        .disabled(newBundleID.isEmpty || newName.isEmpty)
                    }
                }
                .padding(8)
            }

            GroupBox("Accessibility") {
                HStack {
                    Text(AccessibilityService.isTrusted ? "Access granted" : "Access required")
                    Spacer()
                    if !AccessibilityService.isTrusted {
                        Button("Grant Access") {
                            AccessibilityService.promptIfNeeded()
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding(8)
            }

            Spacer()

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 480, height: 520)
    }
}
