import SwiftUI

/// Home tab — mirrors the Android home dashboard: prayer strip → server
/// status → CPU/RAM/Storage stats → quick actions.
///
/// Everything is `.task {}` driven — a single async loop polls every
/// 3 seconds while this tab is visible; SwiftUI cancels it automatically
/// when the user switches tabs (thanks to `.task {}` lifecycle).
struct DashboardView: View {

    @EnvironmentObject private var session: Session
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    PrayerStripView()
                    ServerStatusCard(status: vm.status,
                                     onStart: { vm.control(service: "nginx", op: .start) },
                                     onStop:  { vm.control(service: "nginx", op: .stop) })
                    statsGrid
                    quickActions
                    liveLogsPreview
                }
                .padding(.horizontal, INWEBTheme.hPad)
                .padding(.top, 8).padding(.bottom, 20)
            }
            .background(INWEBTheme.background)
            .navigationTitle("INWEB")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let err = vm.error { errorPill(err) }
                }
            }
            .task { await vm.startPolling(api: session.api) }
        }
    }

    // MARK: - Sub-views

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ], spacing: 12) {
            StatCard(label: "CPU",
                     value: "\(max(0, vm.status?.device.cpu ?? 0))%",
                     progress: Double(max(0, vm.status?.device.cpu ?? 0)) / 100)
            StatCard(label: "RAM",
                     value: fmtRam,
                     progress: ramPercent)
            StatCard(label: "Local IP",
                     value: vm.status?.device.localIp ?? "—",
                     footnote: vm.status?.device.ssid)
            StatCard(label: "Storage",
                     value: fmtStorage,
                     progress: storagePercent)
        }
    }

    private var quickActions: some View {
        INWEBCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionLabel("Quick actions")
                HStack {
                    Button("Start MariaDB") { vm.control(service: "mysql", op: .start) }
                        .buttonStyle(SecondaryButtonStyle())
                    Button("Stop MariaDB")  { vm.control(service: "mysql", op: .stop) }
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
    }

    @ViewBuilder private var liveLogsPreview: some View {
        if let preview = vm.recentLog, !preview.isEmpty {
            INWEBCard {
                VStack(alignment: .leading, spacing: 6) {
                    SectionLabel("Recent activity")
                    Text(preview)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(INWEBTheme.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }

    private func errorPill(_ msg: String) -> some View {
        Text(msg).font(.caption).foregroundColor(.white)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(INWEBTheme.danger).clipShape(Capsule())
    }

    // MARK: - Formatters
    private var fmtRam: String {
        guard let d = vm.status?.device else { return "—" }
        return "\(fmtBytes(d.ramUsed)) / \(fmtBytes(d.ramTotal))"
    }
    private var fmtStorage: String {
        guard let d = vm.status?.device else { return "—" }
        return "\(fmtBytes(d.storageFree)) free"
    }
    private var ramPercent: Double {
        guard let d = vm.status?.device, d.ramTotal > 0 else { return 0 }
        return Double(d.ramUsed) / Double(d.ramTotal)
    }
    private var storagePercent: Double {
        guard let d = vm.status?.device, d.storageTotal > 0 else { return 0 }
        let used = d.storageTotal - d.storageFree
        return Double(used) / Double(d.storageTotal)
    }
    private func fmtBytes(_ n: Int64) -> String {
        let units = ["B","KB","MB","GB","TB"]
        var v = Double(n); var i = 0
        while v >= 1024 && i < units.count - 1 { v /= 1024; i += 1 }
        return v >= 100 ? String(format: "%.0f %@", v, units[i])
                        : String(format: "%.1f %@", v, units[i])
    }
}
