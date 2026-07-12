import SwiftUI

/// Virtual-host manager tab. Loads `/vhosts`, presents each as a card,
/// and offers add / edit / delete via a modal editor.
struct SitesView: View {

    @EnvironmentObject private var session: Session
    @State private var sites: [Vhost] = []
    @State private var editing: Vhost?
    @State private var showingNew = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                INWEBTheme.background.ignoresSafeArea()
                content
            }
            .navigationTitle("Sites")
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
                VHostEditor(existing: nil) { payload in
                    Task { await save(payload) }
                }
            }
            .sheet(item: $editing) { vh in
                VHostEditor(existing: vh) { payload in
                    Task { await save(payload) }
                }
            }
        }
    }

    // MARK: - Content

    @ViewBuilder private var content: some View {
        if sites.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(sites) { vh in
                        siteRow(vh)
                    }
                }
                .padding(INWEBTheme.hPad)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("🌐").font(.system(size: 56))
            Text("No sites configured yet").font(.headline)
            Text("Add a virtual host to serve multiple domains from one INWEB.")
                .font(.footnote)
                .foregroundColor(INWEBTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("+ Add first site") { showingNew = true }
                .buttonStyle(.borderedProminent).tint(INWEBTheme.accent)
                .padding(.top, 4)
        }
    }

    private func siteRow(_ vh: Vhost) -> some View {
        INWEBCard {
            HStack(spacing: 12) {
                Circle().fill(vh.enabled ? INWEBTheme.ok : INWEBTheme.danger)
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(vh.serverName)
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(INWEBTheme.textPrimary)
                        Text(vh.phpMode.lowercased())
                            .font(.caption2)
                            .padding(.horizontal, 6).padding(.vertical, 1)
                            .background(INWEBTheme.accent.opacity(0.2))
                            .foregroundColor(INWEBTheme.accent)
                            .clipShape(Capsule())
                    }
                    Text(vh.documentRoot)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(INWEBTheme.textSecondary)
                        .lineLimit(1).truncationMode(.middle)
                }

                Spacer()

                Menu {
                    Button("Edit") { editing = vh }
                    Button("Delete", role: .destructive) {
                        Task { await delete(vh) }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(INWEBTheme.textSecondary)
                }
            }
        }
    }

    // MARK: - Actions

    private func load() async {
        do   { sites = try await session.api.vhosts().vhosts }
        catch let err { error = (err as? INWEBApi.APIError)?.errorDescription ?? err.localizedDescription }
    }

    private func save(_ payload: VHostPayload) async {
        do { try await session.api.upsertVhost(payload); await load() }
        catch let err { error = (err as? INWEBApi.APIError)?.errorDescription ?? err.localizedDescription }
    }

    private func delete(_ vh: Vhost) async {
        do { try await session.api.deleteVhost(id: vh.id); await load() }
        catch let err { error = (err as? INWEBApi.APIError)?.errorDescription ?? err.localizedDescription }
    }
}
