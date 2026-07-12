import SwiftUI

/// Settings tab — mirrors the Android Settings screen but talks to the
/// remote server via PUT /prefs. Every toggle is auto-saved.
struct SettingsView: View {

    @EnvironmentObject private var session: Session
    @State private var prefs: PrefsResponse?

    var body: some View {
        NavigationStack {
            Form {
                if let p = prefs {
                    connectionSection
                    networkSection(p)
                    servicesSection(p)
                    devToolsSection(p)
                    dnsSection(p)
                } else {
                    ProgressView().tint(INWEBTheme.accent).frame(maxWidth: .infinity)
                }
                Section {
                    Button(role: .destructive) { session.logout() } label: {
                        Label("Disconnect from server", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
            .task { await load() }
            .refreshable { await load() }
        }
    }

    // MARK: - Sections

    private var connectionSection: some View {
        Section("Connection") {
            LabeledContent("Host") {
                Text(session.host).font(.system(.footnote, design: .monospaced))
                    .foregroundColor(INWEBTheme.textSecondary)
                    .lineLimit(1).truncationMode(.middle)
            }
        }
    }

    private func networkSection(_ p: PrefsResponse) -> some View {
        Section("Network") {
            toggleRow("Allow LAN access", key: "bindLan", value: p.bindLan)
            portRow("HTTP port",   key: "httpPort",  value: p.httpPort)
            toggleRow("Enable HTTPS", key: "httpsEnabled", value: p.httpsEnabled)
            portRow("HTTPS port",  key: "httpsPort", value: p.httpsPort)
        }
    }

    private func servicesSection(_ p: PrefsResponse) -> some View {
        Section("Database") {
            toggleRow("Enable MariaDB", key: "mysqlEnabled", value: p.mysqlEnabled)
            portRow("MariaDB port",     key: "mysqlPort",   value: p.mysqlPort)
        }
    }

    private func devToolsSection(_ p: PrefsResponse) -> some View {
        Section("Developer tools") {
            toggleRow("Live Reload", key: "liveReloadEnabled", value: p.liveReloadEnabled)
        }
    }

    private func dnsSection(_ p: PrefsResponse) -> some View {
        Section("Custom DNS") {
            toggleRow("LAN DNS server", key: "dnsServerEnabled", value: p.dnsServerEnabled)
            portRow("DNS port",         key: "dnsServerPort",   value: p.dnsServerPort)
        }
    }

    // MARK: - Row helpers

    private func toggleRow(_ title: String, key: String, value: Bool) -> some View {
        Toggle(title, isOn: Binding(
            get: { value },
            set: { newValue in patch([key: newValue]) }
        )).tint(INWEBTheme.accent)
    }

    private func portRow(_ title: String, key: String, value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: Binding(
                get: { value },
                set: { patch([key: $0]) }
            ), format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 80)
            .font(.system(.body, design: .monospaced))
        }
    }

    // MARK: - Actions

    private func load() async { prefs = try? await session.api.prefs() }

    private func patch(_ dict: [String: Any]) {
        Task {
            try? await session.api.updatePrefs(dict)
            await load()
        }
    }
}
