import Foundation
import os.log

enum AnalyticsService {
    private static let logger = Logger(subsystem: "com.lumio.app", category: "analytics")

    static func track(event: String) {
        logger.log("Analytics event: \(event, privacy: .public)")
    }
}
