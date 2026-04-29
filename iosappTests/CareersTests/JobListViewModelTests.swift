import XCTest
@testable import iosapp

@MainActor
final class JobListViewModelTests: XCTestCase {
    func testFetchSuccessUpdatesState() async {
        let jobs = [
            JobOffer(
                id: UUID(),
                title: "iOS Engineer",
                department: "Engineering",
                location: "Paris",
                shortDescription: "Build.",
                fullDescription: "Build iOS experiences.",
                publishedAt: Date(),
                applyURL: "https://example.com",
                isActive: true
            )
        ]
        let repository = JobRepositoryStub(jobs: jobs)
        let analytics = AnalyticsSpy()
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: analytics
        )

        await viewModel.refresh()

        guard case .success(let loaded) = viewModel.state else {
            return XCTFail("Expected success state")
        }
        XCTAssertEqual(loaded.count, 1)
        XCTAssertFalse(analytics.events.contains { $0.name == "careers_screen_opened" })
    }

    func testFetchErrorUpdatesState() async {
        let repository = JobRepositoryStub(jobs: [], error: .networkFailure)
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: AnalyticsSpy()
        )

        await viewModel.refresh()

        guard case .error = viewModel.state else {
            return XCTFail("Expected error state")
        }
    }

    func testFetchEmptyUpdatesState() async {
        let repository = JobRepositoryStub(jobs: [])
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil),
            analytics: AnalyticsSpy()
        )

        await viewModel.refresh()

        guard case .empty = viewModel.state else {
            return XCTFail("Expected empty state")
        }
    }
}

private final class JobRepositoryStub: JobRepositoryProtocol {
    private let jobs: [JobOffer]
    private let error: JobRepositoryError?

    init(jobs: [JobOffer], error: JobRepositoryError? = nil) {
        self.jobs = jobs
        self.error = error
    }

    var hasCachedData: Bool { false }
    var lastFetchFromCache: Bool { false }

    func isCacheValid() -> Bool { false }
    func cachedJobs() -> [JobOffer] { jobs }
    func invalidateCache() {}

    func fetchJobs(forceRefresh: Bool) async throws -> [JobOffer] {
        if let error {
            throw error
        }
        return jobs
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
