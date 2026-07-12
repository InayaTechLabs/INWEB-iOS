import SwiftUI

/// INWEB — remote control for the Android-hosted INWEB server.
///
/// This SwiftUI app is a *client* of the REST API exposed by the Android
/// app (see `InwebApiServer.kt`). It never runs a web server itself
/// (Apple's App Store rules forbid that on iOS anyway) — it only reads
/// state and sends control commands.
///
/// The `Session` singleton stores the user's connection (host + bearer
/// token) in the iOS Keychain, so credentials never touch UserDefaults.
@main
struct INWEBApp: App {

    @StateObject private var session = Session()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .preferredColorScheme(.dark)   // INWEB is a dark-first brand
                .tint(INWEBTheme.accent)
        }
    }
}

/// Top-level router: shows the login gate until we have a valid session,
/// then swaps in the tab-based dashboard.
struct RootView: View {
    @EnvironmentObject private var session: Session

    var body: some View {
        Group {
            if session.isConfigured {
                DashboardTabs()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.isConfigured)
    }
}
