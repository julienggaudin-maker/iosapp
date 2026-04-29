import Foundation
import os

@MainActor
final class JobListViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case success([JobOffer])
        case empty
        case error(String)
        case offline
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var isRefreshing = false
    @Published private(set) var showOfflineBanner = false

    private let repository: JobRepositoryProtocol
    private let networkMonitor: NetworkMonitor
    private let analytics: AnalyticsService
    private let logger = Logger(subsystem: "com.app.careers", category: "JobListViewModel")

    private var lastCtaTap: Date?
    private var hasTrackedList = false
    private var hasTrackedOpen = false

    init(
        repository: JobRepositoryProtocol,
        networkMonitor: NetworkMonitor = .shared,
        analytics: AnalyticsService = DefaultAnalyticsService.shared
    ) {
        self.repository = repository
        self.networkMonitor = networkMonitor
        self.analytics = analytics
    }

    func onAppear() async {
        if !hasTrackedOpen {
            analytics.track(event: "careers_screen_opened", properties: [:])
            hasTrackedOpen = true
        }
        await loadIfNeeded()
    }

    func refresh() async {
        repository.invalidateCache()
        await load(forceRefresh: true)
    }

    func retry() async {
        await load(forceRefresh: true)
    }

    func trackApplyTap(job: JobOffer) {
        guard shouldHandleTap() else { return }
        analytics.track(
            event: "apply_cta_tapped",
            properties: ["job_id": job.id.uuidString, "department": job.department]
        )
    }

    private func loadIfNeeded() async {
        if repository.isCacheValid(), repository.hasCachedData {
            let cached = repository.cachedJobs()
            let shouldShowOffline = !networkMonitor.isConnected
            applyJobs(cached, fromCache: true, showOfflineBanner: shouldShowOffline)
            return
        }
        await load(forceRefresh: false)
    }

    private func load(forceRefresh: Bool) async {
        isRefreshing = true
        showOfflineBanner = false
        state = .loading

        defer {
            isRefreshing = false
        }

        if !networkMonitor.isConnected {
            if repository.hasCachedData {
                let cached = repository.cachedJobs()
                applyJobs(cached, fromCache: true, showOfflineBanner: true)
            } else {
                state = .offline
            }
            return
        }

        do {
            let jobs = try await repository.fetchJobs(forceRefresh: forceRefresh)
            applyJobs(jobs, fromCache: repository.lastFetchFromCache, showOfflineBanner: false)
        } catch let error as JobRepositoryError {
            handleError(error)
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription, privacy: .public)")
            handleError(.unknown)
        }
    }

    private func applyJobs(_ jobs: [JobOffer], fromCache: Bool, showOfflineBanner: Bool) {
        let activeJobs = jobs.filter { $0.isActive }
        if activeJobs.isEmpty {
            state = .empty
        } else {
            state = .success(activeJobs)
            trackListShown(jobCount: activeJobs.count)
        }
        self.showOfflineBanner = showOfflineBanner
    }

    private func handleError(_ error: JobRepositoryError) {
        state = .error(error.userMessage)
    }

    private func shouldHandleTap() -> Bool {
        let now = Date()
        if let lastCtaTap,
           now.timeIntervalSince(lastCtaTap) < 0.3 {
            return false
        }
        lastCtaTap = now
        return true
    }
}

extension JobListViewModel {
    static func previewLoading() -> JobListViewModel {
        let viewModel = JobListViewModel(
            repository: MockJobRepository(
                bundle: .main,
                decoder: JSONDecoder()
            ),
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .loading
        return viewModel
    }

    static func previewLoaded() -> JobListViewModel {
        let repository = JobRepositoryPreviewStub(jobs: JobOffer.sampleList, hasCache: true)
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .success(JobOffer.sampleList)
        return viewModel
    }

    static func previewEmpty() -> JobListViewModel {
        let repository = JobRepositoryPreviewStub(jobs: [], hasCache: true)
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .empty
        return viewModel
    }

    static func previewError() -> JobListViewModel {
        let repository = JobRepositoryPreviewStub(jobs: [], error: JobRepositoryError.networkFailure)
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .error(JobRepositoryError.networkFailure.userMessage)
        return viewModel
    }

    static func previewOffline() -> JobListViewModel {
        let repository = JobRepositoryPreviewStub(jobs: [], hasCache: false)
        let viewModel = JobListViewModel(
            repository: repository,
            networkMonitor: NetworkMonitor(isConnected: false, monitor: nil)
        )
        viewModel.state = .offline
        return viewModel
    }
}

private final class JobRepositoryPreviewStub: JobRepositoryProtocol {
    private let jobs: [JobOffer]
    private let error: JobRepositoryError?
    private let hasCache: Bool

    init(jobs: [JobOffer], error: JobRepositoryError? = nil, hasCache: Bool = false) {
        self.jobs = jobs
        self.error = error
        self.hasCache = hasCache
    }

    var hasCachedData: Bool { hasCache }
    var lastFetchFromCache: Bool { hasCache }

    func isCacheValid() -> Bool { hasCache }
    func cachedJobs() -> [JobOffer] { jobs }
    func invalidateCache() {}

    func fetchJobs(forceRefresh: Bool) async throws -> [JobOffer] {
        if let error {
            throw error
        }
        return jobs
    }
}
