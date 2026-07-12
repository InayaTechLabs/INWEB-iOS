import SwiftUI

/// Full-screen gate that captures `host` + `bearer token`, verifies the
/// connection with a `/ping` call, and only then hands off to the
/// Dashboard tabs.
///
/// On success the `Session` object saves the credentials (token → Keychain,
/// host → UserDefaults) and the parent `RootView` swaps in the tabs.
struct LoginView: View {

    @EnvironmentObject private var session: Session
    @State private var host  = ""
    @State private var token = ""
    @State private var isTesting = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            INWEBTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 60)
                    logo
                    formCard
                    if let msg = errorMessage { errorBanner(msg) }
                    footerHelp
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, INWEBTheme.hPad)
            }
        }
    }

    // MARK: - Sub-views

    private var logo: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(INWEBTheme.accentDark)
                Text("IN").font(.system(size: 44, weight: .heavy)).foregroundColor(.white)
            }
            .frame(width: 96, height: 96)
            .shadow(color: INWEBTheme.accent.opacity(0.4), radius: 30)

            Text("INWEB").font(.title.bold()).foregroundColor(INWEBTheme.textPrimary)
            Text("Connect to your Android server")
                .font(.footnote).foregroundColor(INWEBTheme.textSecondary)
        }
    }

    private var formCard: some View {
        INWEBCard {
            VStack(spacing: 14) {
                labeledField("Server URL", value: $host,
                             placeholder: "http://192.168.1.42:8181",
                             keyboard: .URL)
                labeledField("Bearer token", value: $token,
                             placeholder: "Paste from Android app",
                             secure: true, keyboard: .asciiCapable)

                Button(action: connect) {
                    HStack {
                        if isTesting { ProgressView().tint(.white).scaleEffect(0.8) }
                        Text(isTesting ? "Connecting…" : "Connect")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(INWEBTheme.accent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(host.isEmpty || token.isEmpty || isTesting)
                .opacity((host.isEmpty || token.isEmpty) ? 0.5 : 1)
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message).font(.footnote)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(INWEBTheme.danger.opacity(0.15))
        .foregroundColor(INWEBTheme.danger)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var footerHelp: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HOW TO FIND YOUR TOKEN").font(.caption).kerning(1.2)
                .foregroundColor(INWEBTheme.textSecondary)
            Text("On your Android device:  INWEB → Settings → Web Dashboard\n"
                 + "Toggle it ON, then tap the Token row.")
                .font(.footnote)
                .foregroundColor(INWEBTheme.textSecondary)
                .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(INWEBTheme.surface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: INWEBTheme.cardCorner))
    }

    // MARK: - Actions

    private func labeledField(_ label: String,
                              value: Binding<String>,
                              placeholder: String,
                              secure: Bool = false,
                              keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption).kerning(1)
                .foregroundColor(INWEBTheme.textSecondary)
            Group {
                if secure {
                    SecureField(placeholder, text: value)
                } else {
                    TextField(placeholder, text: value)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .font(.system(.body, design: .monospaced))
            .keyboardType(keyboard)
            .padding(10)
            .background(INWEBTheme.background)
            .foregroundColor(INWEBTheme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func connect() {
        errorMessage = nil
        isTesting = true

        // Try `session.api.ping()` with the *proposed* credentials — do that
        // by mutating the session first, then reverting on failure.
        let previousHost  = session.host
        let previousToken = session.token
        session.login(host: host, token: token)

        Task {
            do {
                _ = try await session.api.ping()
                await MainActor.run { isTesting = false }
                // Success — Session already updated, RootView will swap.
            } catch {
                await MainActor.run {
                    isTesting = false
                    errorMessage = (error as? INWEBApi.APIError)?.errorDescription
                        ?? error.localizedDescription
                    // Roll back
                    if !previousHost.isEmpty {
                        session.login(host: previousHost, token: previousToken)
                    } else {
                        session.logout()
                    }
                }
            }
        }
    }
}
