import Foundation
import Combine

/// Owns the polling loop for the Home tab. Kept `@MainActor` so published
/// state can be updated from the async loop without extra hops.
@MainActor
final class DashboardViewModel: ObservableObject {

    @Published private(set) var status:    StatusResponse?
    @Published private(set) var recentLog: String?
    @Published private(set) var error:     String?

    // Retained after `startPolling` so `control()` can send commands too.
    private weak var api: INWEBApi?

    /// Starts the 3-second refresh loop. SwiftUI cancels the enclosing
    /// `.task { }` when the view leaves the screen, which naturally
    /// tears down this loop.
    func startPolling(api: INWEBApi) async {
        self.api = api
        while !Task.isCancelled {
            do {
                let s   = try await api.status()
                let log = try? await api.logs(file: "access", bytes: 512)
                self.status = s
                self.recentLog = log?.content
                self.error = nil
            } catch {
                self.error = (error as? INWEBApi.APIError)?.errorDescription
                    ?? error.localizedDescription
            }
            try? await Task.sleep(nanoseconds: 3_000_000_000)
        }
    }

    /// Fire-and-forget service toggle triggered from the UI.
    func control(service: String, op: INWEBApi.ServiceOp) {
        guard let api = api else { return }
        Task {
            do { try await api.serviceControl(service: service, op: op) }
            catch {
                self.error = (error as? INWEBApi.APIError)?.errorDescription
                    ?? error.localizedDescription
            }
        }
    }
}
