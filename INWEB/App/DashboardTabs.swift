import SwiftUI

/// Five-tab shell — matches the Android bottom-nav layout so users
/// switching between platforms feel at home.
struct DashboardTabs: View {

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home",     systemImage: "house.fill") }

            SitesView()
                .tabItem { Label("Sites",    systemImage: "globe") }

            LogsView()
                .tabItem { Label("Logs",     systemImage: "doc.text") }

            HostsView()
                .tabItem { Label("Hosts",    systemImage: "network") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(INWEBTheme.accent)
    }
}
