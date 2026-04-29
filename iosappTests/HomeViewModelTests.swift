import XCTest
@testable import iosapp

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadSuccessUpdatesState() async {
        let repository = HomeMockService(response: .loaded(.sample))
        let analytics = AnalyticsSpy()
        let metrics = HomeMetricsSpy()
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: analytics,
            metricsReporter: metrics
        )

        await viewModel.refresh()

        guard case .loaded(let payload) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }
        XCTAssertEqual(payload.sections.count, 2)
        XCTAssertTrue(analytics.events.contains { $0.name == "home_loaded" })
    }

    func testLoadErrorUpdatesState() async {
        let repository = HomeMockService(response: .error(.unknown))
        let analytics = AnalyticsSpy()
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: analytics,
            metricsReporter: HomeMetricsSpy()
        )

        await viewModel.refresh()

        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }
        XCTAssertTrue(analytics.events.contains { $0.name == "home_error_shown" })
    }

    func testRetryAfterErrorLoadsContent() async {
        let repository = SequentialMockRepository(
            responses: [.error(.unknown), .loaded(.sample)]
        )
        let analytics = AnalyticsSpy()
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: analytics,
            metricsReporter: HomeMetricsSpy()
        )

        await viewModel.refresh()
        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }

        await viewModel.retry()

        guard case .loaded = viewModel.state else {
            return XCTFail("Expected loaded state after retry")
        }
    }

    func testLoadOfflineWithoutCacheShowsOfflineState() async {
        let repository = HomeMockService(response: .loaded(.sample), hasCachedData: false)
        let analytics = AnalyticsSpy()
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: false, monitor: nil),
            analytics: analytics,
            metricsReporter: HomeMetricsSpy()
        )

        await viewModel.refresh()

        guard case .offline = viewModel.state else {
            return XCTFail("Expected offline state")
        }
        XCTAssertTrue(analytics.events.contains { $0.name == "home_offline_shown" })
    }

    func testEmptyStateWhenNoContent() async {
        let repository = HomeMockService(response: .empty)
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: AnalyticsSpy(),
            metricsReporter: HomeMetricsSpy()
        )

        await viewModel.refresh()

        guard case .empty = viewModel.state else {
            return XCTFail("Expected empty state")
        }
    }

    func testHomeOpenedTrackedOnceAcrossAppearCalls() async {
        let repository = HomeMockService(response: .loaded(.sample))
        let analytics = AnalyticsSpy()
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: analytics,
            metricsReporter: HomeMetricsSpy()
        )

        await viewModel.onAppear()
        await viewModel.onAppear()

        XCTAssertEqual(analytics.events.filter { $0.name == "home_opened" }.count, 1)
    }
}

private final class AnalyticsSpy: AnalyticsService {
    struct Event {
        let name: String
        let properties: [String: Any]
    }

    private(set) var events: [Event] = []

    func track(event: String, properties: [String: Any]) {
        events.append(Event(name: event, properties: properties))
    }
}

private final class HomeMetricsSpy: HomeMetricsReporting {
    private(set) var durations: [TimeInterval] = []

    func recordLoad(duration: TimeInterval) {
        durations.append(duration)
    }

    func beginLoad() -> HomeMetricsToken? {
        HomeMetricsToken(signpostID: .exclusive)
    }

    func endLoad(_ token: HomeMetricsToken?) {}
}

private final class SequentialMockRepository: HomeRepository {
    private var responses: [HomeMockService.Response]
    private var cachedPayloadValue: HomePayload?

    init(responses: [HomeMockService.Response]) {
        self.responses = responses
    }

    var hasCachedData: Bool {
        cachedPayloadValue != nil
    }

    private(set) var lastFetchFromCache: Bool = false

    func isCacheValid() -> Bool {
        hasCachedData
    }

    func cachedPayload() -> HomePayload {
        cachedPayloadValue ?? .empty
    }

    func invalidateCache() {
        cachedPayloadValue = nil
        lastFetchFromCache = false
    }

    func fetchHome(forceRefresh: Bool) async throws -> HomePayload {
        let next = responses.isEmpty ? .loaded(.sample) : responses.removeFirst()
        switch next {
        case .loaded(let payload):
            cachedPayloadValue = payload
            lastFetchFromCache = false
            return payload
        case .empty:
            let payload = HomePayload.empty
            cachedPayloadValue = payload
            lastFetchFromCache = false
            return payload
        case .error(let error):
            lastFetchFromCache = false
            throw error
        }
    }
}
