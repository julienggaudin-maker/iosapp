import XCTest
@testable import iosapp

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testLoadSuccessUpdatesState() async {
        let repository = HomeMockService(response: .loaded(.sample))
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: AnalyticsService.shared,
            metricsReporter: HomeMetricsReporter.shared
        )

        await viewModel.refresh()

        guard case .loaded(let payload) = viewModel.state else {
            return XCTFail("Expected loaded state")
        }
        XCTAssertEqual(payload.sections.count, 2)
    }

    func testLoadErrorUpdatesState() async {
        let repository = HomeMockService(response: .error(.unknown))
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: AnalyticsService.shared,
            metricsReporter: HomeMetricsReporter.shared
        )

        await viewModel.refresh()

        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }
    }

    func testLoadOfflineWithoutCacheShowsOfflineState() async {
        let repository = HomeMockService(response: .loaded(.sample), hasCachedData: false)
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: false, monitor: nil),
            analytics: AnalyticsService.shared,
            metricsReporter: HomeMetricsReporter.shared
        )

        await viewModel.refresh()

        guard case .offline = viewModel.state else {
            return XCTFail("Expected offline state")
        }
    }

    func testEmptyStateWhenNoContent() async {
        let repository = HomeMockService(response: .empty)
        let viewModel = HomeViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: AnalyticsService.shared,
            metricsReporter: HomeMetricsReporter.shared
        )

        await viewModel.refresh()

        guard case .empty = viewModel.state else {
            return XCTFail("Expected empty state")
        }
    }
}
