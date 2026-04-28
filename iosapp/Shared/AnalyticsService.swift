import Foundation
import os

final class AnalyticsService {
    static let shared = AnalyticsService()

    private let logger = Logger(subsystem: "com.app.home", category: "analytics")

    private init() {}

    func track(event: String, properties: [String: Any] = [:]) {
        if properties.isEmpty {
            logger.info("Analytics event: \(event, privacy: .public)")
        } else {
            logger.info("Analytics event: \(event, privacy: .public) properties: \(String(describing: properties), privacy: .public)")
        }
    }
}
