import SwiftUI

/// Custom DNS mappings tab. Same pattern as SitesView.
struct HostsView: View {

    @EnvironmentObject private var session: Session
    @State private var entries: [HostEntry] = []
    @State private var showingNew = false

    var body: some View {
        NavigationStack {
            ZStack {
                INWEBTheme.background.ignoresSafeArea()
                if entries.isEmpty {
                    empty
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(entries) { e in row(e) }
                        }
                        .padding(INWEBTheme.hPad)
                    }
                }
            }
            .navigationTitle("Hosts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNew = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .task { await load() }
            .refreshable { await load() }
            .sheet(isPresented: $showingNew) {
                HostEditor { payload in Task { await save(payload) } }
            }
        }
    }

    private var empty: some View {
        VStack(spacing: 12) {
            Text("🏠").font(.system(size: 56))
            Text("No custom hosts yet").font(.headline)
            Text("Add mappings like wordpress.local → 127.0.0.1")
                .font(.footnote).foregroundColor(INWEBTheme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 40)
        }
    }

    private func row(_ e: HostEntry) -> some View {
        INWEBCard {
            HStack(spacing: 12) {
                Circle().fill(e.enabled ? INWEBTheme.ok : INWEBTheme.danger)
                    .frame(width: 10, height: 10)
                VStack(alignment: .leading, spacing: 2) {
                    Text(e.hostname)
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundColor(INWEBTheme.textPrimary)
                    Text("→ \(e.ip)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(INWEBTheme.accent)
                    if !e.note.isEmpty {
                        Text(e.note).font(.caption2).foregroundColor(INWEBTheme.textSecondary)
                    }
                }
                Spacer()
                Button {
                    Task { await delete(e) }
                } label: {
                    Image(systemName: "trash").foregroundColor(INWEBTheme.danger.opacity(0.7))
                }
            }
        }
    }

    // MARK: - Actions

    private func load() async {
        entries = (try? await session.api.hosts().hosts) ?? []
    }
    private func save(_ payload: HostPayload) async {
        _ = try? await session.api.upsertHost(payload); await load()
    }
    private func delete(_ e: HostEntry) async {
        _ = try? await session.api.deleteHost(id: e.id); await load()
    }
}

/// Simple add-only editor. Editing would work identically; kept short.
struct HostEditor: View {
    let onSave: (HostPayload) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var host = ""
    @State private var ip   = "127.0.0.1"
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Hostname") {
                    TextField("wordpress.local", text: $host)
                        .autocapitalization(.none).disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                        .keyboardType(.URL)
                }
                Section("IPv4 address") {
                    TextField("127.0.0.1", text: $ip)
                        .keyboardType(.decimalPad)
                        .font(.system(.body, design: .monospaced))
                    HStack {
                        Button("127.0.0.1") { ip = "127.0.0.1" }
                        Button("🚫 0.0.0.0 (block)") { ip = "0.0.0.0" }
                    }.font(.caption).tint(INWEBTheme.accent)
                }
                Section("Note (optional)") {
                    TextField("What is this for?", text: $note)
                }
            }
            .navigationTitle("New mapping")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(HostPayload(hostname: host, ip: ip, note: note))
                        dismiss()
                    }.disabled(host.isEmpty || ip.isEmpty)
                }
            }
        }
    }
}
