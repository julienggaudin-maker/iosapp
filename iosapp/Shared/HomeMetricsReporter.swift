import Foundation
import os
import os.signpost
#if canImport(MetricKit)
import MetricKit
#endif

struct HomeMetricsToken {
    let signpostID: OSSignpostID
}

protocol HomeMetricsReporting {
    func recordLoad(duration: TimeInterval)
    func beginLoad() -> HomeMetricsToken?
    func endLoad(_ token: HomeMetricsToken?)
}

extension HomeMetricsReporting {
    func beginLoad() -> HomeMetricsToken? { nil }
    func endLoad(_ token: HomeMetricsToken?) {}
}

final class HomeMetricsReporter: NSObject, HomeMetricsReporting {
    static let shared = HomeMetricsReporter()

    private let logger = Logger(subsystem: "com.app.home", category: "metrics")
    private let signpostLog = OSLog(subsystem: "com.app.home", category: .pointsOfInterest)

    func start() {
        #if canImport(MetricKit)
        if #available(iOS 13.0, *) {
            MXMetricManager.shared.add(self)
        }
        #endif
    }

    func recordLoad(duration: TimeInterval) {
        logger.debug("Home load duration \(duration, privacy: .public)s")
    }

    func beginLoad() -> HomeMetricsToken? {
        guard signpostLog.isEnabled(type: .signpost) else { return nil }
        let signpostID = OSSignpostID(log: signpostLog)
        os_signpost(.begin, log: signpostLog, name: "home_loaded", signpostID: signpostID)
        return HomeMetricsToken(signpostID: signpostID)
    }

    func endLoad(_ token: HomeMetricsToken?) {
        guard let token else { return }
        os_signpost(.end, log: signpostLog, name: "home_loaded", signpostID: token.signpostID)
    }

}

#if canImport(MetricKit)
@available(iOS 13.0, *)
extension HomeMetricsReporter: MXMetricManagerSubscriber {
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
#endif
