import Foundation
import os

@MainActor
final class HomeViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded(HomePayload)
        case empty
        case error(HomeError)
        case offline
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var isRefreshing = false
    @Published private(set) var showOfflineBanner = false
    @Published var shouldPresentAuth = false
    @Published private(set) var welcomeMessage: String = "Bonjour"
    @Published private(set) var showWaveIcon: Bool = false

    private let repository: HomeRepository
    private let networkMonitor: NetworkMonitor
    private let analytics: AnalyticsService
    private let metricsReporter: HomeMetricsReporting
    private let logger = Logger(subsystem: "com.app.home", category: "HomeViewModel")

    private var isFirstAppear = true
    private var lastForegroundRefresh: Date?
    private var lastCtaTap: Date?
    private var hasTrackedOpen = false

    init(
        repository: HomeRepository,
        networkMonitor: NetworkMonitor = .shared,
        analytics: AnalyticsService = DefaultAnalyticsService.shared,
        metricsReporter: HomeMetricsReporting = HomeMetricsReporter.shared
    ) {
        self.repository = repository
        self.networkMonitor = networkMonitor
        self.analytics = analytics
        self.metricsReporter = metricsReporter
        updateWelcomeMessage()
    }

    func onAppear() async {
        if !hasTrackedOpen {
            analytics.track(event: "home_opened", properties: ["first_launch": isFirstAppear])
            isFirstAppear = false
            hasTrackedOpen = true
        }
        updateWelcomeMessage()
        if lastForegroundRefresh == nil {
            lastForegroundRefresh = Date()
        }
        await loadIfNeeded()
    }

    func onForeground() {
        let now = Date()
        if let lastForegroundRefresh,
           now.timeIntervalSince(lastForegroundRefresh) < 600 {
            return
        }
        lastForegroundRefresh = now
        Task { await load(forceRefresh: true, silent: true) }
    }

    func refresh() async {
        analytics.track(event: "home_refresh_triggered", properties: [:])
        repository.invalidateCache()
        await load(forceRefresh: true)
    }

    func retry() async {
        await load(forceRefresh: true)
    }

    func handleCtaTap(section: HomeSection, position: Int) -> Bool {
        guard shouldHandleTap() else { return false }
        analytics.track(
            event: "home_cta_tapped",
            properties: ["cta_name": section.ctaName, "position": position]
        )
        return true
    }

    private enum LoadResult: String {
        case success
        case empty
        case error
        case offline
    }

    private func loadIfNeeded(forceRefreshIfStale: Bool = false, silent: Bool = false) async {
        if !forceRefreshIfStale, repository.isCacheValid(), repository.hasCachedData {
            let start = Date()
            let metricsToken = metricsReporter.beginLoad()
            defer {
                metricsReporter.recordLoad(duration: Date().timeIntervalSince(start))
                metricsReporter.endLoad(metricsToken)
            }
            let result = applyPayload(repository.cachedPayload())
            logLoaded(start: start, fromCache: true, result: result)
            return
        }

        await load(forceRefresh: forceRefreshIfStale, silent: silent)
    }

    private func load(forceRefresh: Bool, silent: Bool = false) async {
        let start = Date()
        let metricsToken = metricsReporter.beginLoad()
        defer {
            isRefreshing = false
            metricsReporter.recordLoad(duration: Date().timeIntervalSince(start))
            metricsReporter.endLoad(metricsToken)
        }
        if !silent {
            state = .loading
        }
        isRefreshing = true
        showOfflineBanner = false

        if !networkMonitor.isConnected {
            if repository.hasCachedData {
                let result = applyPayload(repository.cachedPayload())
                showOfflineBanner = true
                logLoaded(start: start, fromCache: true, result: result)
            } else {
                state = .offline
                analytics.track(event: "home_offline_shown", properties: [:])
                logLoaded(start: start, fromCache: false, result: .offline)
            }
            return
        }

        do {
            let result = try await repository.fetchHome(forceRefresh: forceRefresh)
            let loadResult = applyPayload(result)
            logLoaded(start: start, fromCache: repository.lastFetchFromCache, result: loadResult)
        } catch let error as HomeError {
            handleError(error)
            logLoaded(start: start, fromCache: false, result: .error)
        } catch {
            logger.error("Unknown error \(error.localizedDescription, privacy: .public)")
            handleError(.unknown)
            logLoaded(start: start, fromCache: false, result: .error)
        }
    }

    @discardableResult
    private func applyPayload(_ payload: HomePayload) -> LoadResult {
        if payload.sections.isEmpty {
            state = .empty
            return .empty
        } else {
            state = .loaded(payload)
            return .success
        }
    }

    private func handleError(_ error: HomeError) {
        state = .error(error)
        analytics.track(event: "home_error_shown", properties: ["error_type": error.analyticsValue])
        if case .unauthorized = error {
            shouldPresentAuth = true
        }
    }

    private func updateWelcomeMessage() {
        if let firstName = UserDefaults.standard.string(forKey: "user_first_name"),
           !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            welcomeMessage = "Bonjour \(firstName)"
            showWaveIcon = false
        } else {
            welcomeMessage = "Bonjour"
            showWaveIcon = true
        }
    }

    private func logLoaded(start: Date, fromCache: Bool, result: LoadResult) {
        let elapsed = Int(Date().timeIntervalSince(start) * 1000)
        analytics.track(
            event: "home_loaded",
            properties: [
                "load_time_ms": elapsed,
                "from_cache": fromCache,
                "result": result.rawValue
            ]
        )
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

extension HomeViewModel {
    static func previewLoading() -> HomeViewModel {
        let viewModel = HomeViewModel(
            repository: HomeMockService(response: .loaded(.sample), delay: .seconds(1)),
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .loading
        return viewModel
    }

    static func previewLoaded() -> HomeViewModel {
        let viewModel = HomeViewModel(
            repository: HomeMockService(response: .loaded(.sample)),
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .loaded(.sample)
        return viewModel
    }

    static func previewEmpty() -> HomeViewModel {
        let viewModel = HomeViewModel(
            repository: HomeMockService(response: .empty),
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .empty
        return viewModel
    }

    static func previewError() -> HomeViewModel {
        let viewModel = HomeViewModel(
            repository: HomeMockService(response: .error(.unknown)),
            networkMonitor: NetworkMonitor(isConnected: true, monitor: nil)
        )
        viewModel.state = .error(.unknown)
        return viewModel
    }

    static func previewOffline() -> HomeViewModel {
        let viewModel = HomeViewModel(
            repository: HomeMockService(response: .loaded(.sample), hasCachedData: false),
            networkMonitor: NetworkMonitor(isConnected: false, monitor: nil)
        )
        viewModel.state = .offline
        return viewModel
    }
}
