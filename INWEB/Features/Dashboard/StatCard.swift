import SwiftUI

/// Compact 2×2-grid stat card used on the Home dashboard.
///
///   - `label`      — top-line all-caps identifier
///   - `value`      — big monospaced value
///   - `footnote`   — optional muted sub-text (SSID, etc.)
///   - `progress`   — optional 0…1 bar drawn along the bottom
struct StatCard: View {

    let label: String
    let value: String
    var footnote: String? = nil
    var progress: Double? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2).kerning(1.2)
                .foregroundColor(INWEBTheme.textSecondary)

            Text(value)
                .font(.system(.title3, design: .monospaced).bold())
                .foregroundColor(INWEBTheme.textPrimary)
                .lineLimit(1).minimumScaleFactor(0.7)

            if let footnote = footnote, !footnote.isEmpty {
                Text(footnote)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(INWEBTheme.textSecondary)
                    .lineLimit(1)
            }

            if let p = progress {
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.06))
                        Capsule().fill(INWEBTheme.accent)
                            .frame(width: g.size.width * CGFloat(max(0, min(p, 1))))
                    }
                }
                .frame(height: 4)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .background(INWEBTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: INWEBTheme.cardCorner, style: .continuous))
    }
}
