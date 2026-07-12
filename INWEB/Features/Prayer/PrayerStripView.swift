import SwiftUI

/// Small strip at the top of the dashboard showing the next prayer time
/// and a live countdown. Queries the Android app's `/prayer-times`
/// endpoint (which uses the same astronomical algorithm as the PHP API).
///
/// Coordinates default to Dhaka; a future version can pull from
/// CoreLocation with the user's permission.
struct PrayerStripView: View {

    @EnvironmentObject private var session: Session
    @State private var next: (label: String, when: Date)?
    @State private var timer: Timer?

    // Defaults — Dhaka
    private let lat: Double = 23.8103
    private let lng: Double = 90.4125

    var body: some View {
        INWEBCard {
            HStack(spacing: 14) {
                Text("🕌").font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text("NEXT · \(next?.label ?? "…")")
                        .font(.caption2).kerning(1)
                        .foregroundColor(INWEBTheme.textSecondary)
                    Text(next.map { timeFormatter.string(from: $0.when) } ?? "—")
                        .font(.title3.bold())
                        .foregroundColor(INWEBTheme.accent)
                }
                .fixedSize()
                Spacer()
                Text(countdownText)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(INWEBTheme.textPrimary)
            }
        }
        .task { await refresh() }
        .onAppear { startTicker() }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Helpers

    private var timeFormatter: DateFormatter {
        let f = DateFormatter(); f.dateFormat = "h:mm a"; return f
    }

    private var countdownText: String {
        guard let next = next else { return "…" }
        let diff = next.when.timeIntervalSinceNow
        if diff <= 0 { return "now" }
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        if h == 0 { return "\(m)m" }
        if m == 0 { return "\(h)h" }
        return "\(h)h \(m)m"
    }

    private func refresh() async {
        do {
            let resp = try await session.api.prayerTimes(lat: lat, lng: lng)
            let now = Date().timeIntervalSince1970 * 1000
            let all: [(String, Int64)] = [
                ("Fajr",    resp.timings.fajr),
                ("Sunrise", resp.timings.sunrise),
                ("Dhuhr",   resp.timings.dhuhr),
                ("Asr",     resp.timings.asr),
                ("Maghrib", resp.timings.maghrib),
                ("Isha",    resp.timings.isha),
            ]
            let upcoming = all.first { Double($0.1) > now } ?? ("Fajr", resp.timings.fajr + 86_400_000)
            self.next = (upcoming.0, Date(timeIntervalSince1970: Double(upcoming.1) / 1000))
        } catch { /* silent — strip stays empty */ }
    }

    /// Fires every 30 s so the countdown label stays fresh without spamming.
    private func startTicker() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            // Trigger a re-render by re-assigning the same value.
            if let n = self.next { self.next = n }
        }
    }
}
