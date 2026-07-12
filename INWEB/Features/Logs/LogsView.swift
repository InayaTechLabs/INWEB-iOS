import SwiftUI

/// Live log tail — refreshes every 2 s while visible.
/// Matrix-style green-on-black to match the Android look.
struct LogsView: View {

    @EnvironmentObject private var session: Session
    @State private var selectedFile = "access"
    @State private var content = ""
    @State private var task: Task<Void, Never>?

    private let files = ["access", "error", "php-fpm.error"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filePicker
                console
            }
            .background(INWEBTheme.background)
            .navigationTitle("Logs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Copy") { UIPasteboard.general.string = content }
                        .disabled(content.isEmpty)
                }
            }
        }
        .onAppear    { startPolling() }
        .onDisappear { task?.cancel() }
        .onChange(of: selectedFile) { _ in content = ""; startPolling() }
    }

    private var filePicker: some View {
        Picker("", selection: $selectedFile) {
            ForEach(files, id: \.self) { Text($0 + ".log").tag($0) }
        }
        .pickerStyle(.segmented)
        .padding(INWEBTheme.hPad)
    }

    private var console: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(content.isEmpty ? "(no output yet)" : content)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(Color(hex: 0xB6F0B6))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .id("bottom")
            }
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: INWEBTheme.cardCorner))
            .padding(INWEBTheme.hPad)
            .padding(.bottom, INWEBTheme.hPad)
            .onChange(of: content) { _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    private func startPolling() {
        task?.cancel()
        task = Task {
            while !Task.isCancelled {
                if let logs = try? await session.api.logs(file: selectedFile) {
                    await MainActor.run { content = logs.content }
                }
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
}
