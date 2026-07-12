import SwiftUI

/// Big centred "OPERATIONAL / OFFLINE" card on the home dashboard, with
/// a start/stop button underneath.
struct ServerStatusCard: View {

    let status: StatusResponse?
    let onStart: () -> Void
    let onStop:  () -> Void

    private var running: Bool {
        // Server "running" == we got a status back and Nginx is up.
        // The status endpoint just tells us what's *enabled*; the presence
        // of a response itself signals reachability. For a richer signal
        // we'd need to expose per-service state (Android already does — a
        // future ApiRouter endpoint could surface it).
        status != nil
    }

    var body: some View {
        INWEBCard {
            VStack(spacing: 12) {
                Text("SERVER STATUS")
                    .font(.caption2).kerning(1.5)
                    .foregroundColor(INWEBTheme.textSecondary)

                HStack(spacing: 8) {
                    Circle().fill(running ? INWEBTheme.ok : INWEBTheme.danger)
                        .frame(width: 12, height: 12)
                    Text(running ? "OPERATIONAL" : "OFFLINE")
                        .font(.title2.bold()).kerning(0.5)
                        .foregroundColor(running ? INWEBTheme.ok : INWEBTheme.danger)
                }

                if let engine = status?.services.engine, let port = status?.services.httpPort {
                    Text("\(engine.uppercased())  ·  localhost:\(port)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(INWEBTheme.textSecondary)
                }

                Divider().background(Color.white.opacity(0.1)).padding(.vertical, 4)

                HStack {
                    Text("Server control").foregroundColor(INWEBTheme.textPrimary)
                    Spacer()
                    Button(action: running ? onStop : onStart) {
                        Text(running ? "STOP" : "START").kerning(0.8).font(.footnote.bold())
                            .padding(.horizontal, 20).padding(.vertical, 10)
                            .background(running ? INWEBTheme.danger : INWEBTheme.ok)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}

/// Reusable secondary-button style used across the app.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 14).padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(INWEBTheme.surface2)
            .foregroundColor(INWEBTheme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
