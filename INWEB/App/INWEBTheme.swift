import SwiftUI

/// Brand palette — mirrors `values/colors.xml` in the Android app so both
/// platforms stay visually identical. Keeping the constants here rather
/// than in an asset catalogue means they compile-check against typos.
enum INWEBTheme {

    // Backgrounds
    static let background = Color(hex: 0x0B1410)   // deep forest
    static let surface    = Color(hex: 0x132821)   // card
    static let surface2   = Color(hex: 0x1A3529)   // elevated card

    // Text
    static let textPrimary   = Color(hex: 0xF5F7FA)
    static let textSecondary = Color(hex: 0x9AB5AA)

    // Accents (Islamic care / trust palette)
    static let accent     = Color(hex: 0x14B8A6)   // teal 500
    static let accentDark = Color(hex: 0x0F766E)   // teal 700

    // Semantic
    static let ok      = Color(hex: 0x10B981)      // emerald
    static let warn    = Color(hex: 0xF59E0B)
    static let danger  = Color(hex: 0xEF4444)

    // Radii + spacing constants for consistency across screens.
    static let cardCorner: CGFloat = 14
    static let bigCorner:  CGFloat = 20
    static let hPad:       CGFloat = 16
}

extension Color {
    /// Convenience constructor: `Color(hex: 0x14B8A6)`. Alpha defaults to 1.
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >>  8) & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

/// A repeatable card container — every screen leans on this to keep the
/// look consistent with the Android Material 3 cards.
struct INWEBCard<Content: View>: View {
    private let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) { self.content = content }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(INWEBTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: INWEBTheme.cardCorner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: INWEBTheme.cardCorner)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

/// Small letter-spaced ALL CAPS label used above every section — same
/// pattern as `values/themes.xml → INWEB.SectionLabel` on Android.
struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.caption).kerning(1.5)
            .foregroundColor(INWEBTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 6)
    }
}

/// A monospace status pill (green/red/amber) — used on the dashboard.
struct StatusPill: View {
    enum State { case running, stopped, warn }
    let state: State
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
    private var color: Color {
        switch state {
        case .running: return INWEBTheme.ok
        case .stopped: return INWEBTheme.danger
        case .warn:    return INWEBTheme.warn
        }
    }
}
