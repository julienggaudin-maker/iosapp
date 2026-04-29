import Foundation
import Network

@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected: Bool

    private let monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "com.app.home.networkmonitor")

    init(isConnected: Bool = true, monitor: NWPathMonitor? = NWPathMonitor()) {
        self.isConnected = isConnected
        self.monitor = monitor

        monitor?.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor?.start(queue: queue)
    }
}
