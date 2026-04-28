import Foundation
import MetricKit
import os

protocol HomeMetricsReporting {
    func recordLoad(duration: TimeInterval)
}

final class HomeMetricsReporter: NSObject, MXMetricManagerSubscriber, HomeMetricsReporting {
    static let shared = HomeMetricsReporter()

    private let logger = Logger(subsystem: "com.app.home", category: "metrics")

    func start() {
        MXMetricManager.shared.add(self)
    }

    func recordLoad(duration: TimeInterval) {
        logger.debug("Home load duration \(duration, privacy: .public)s")
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        guard let payload = payloads.last else { return }
        if let launch = payload.applicationLaunchMetrics?.histogrammedTimeToFirstDraw {
            let buckets = launch.bucketValues
            if let maxBucket = buckets.keys.max() {
                logger.debug("Home launch metric bucket: \(maxBucket.doubleValue, privacy: .public) seconds")
            }
        }
    }
}
