import Foundation

final class HomeMockService: HomeRepository {
    enum Response {
        case loaded(HomePayload)
        case empty
        case error(HomeError)
    }

    private let response: Response
    private let delay: Duration

    private(set) var hasCachedData: Bool
    private(set) var lastFetchFromCache: Bool
    private var cachedPayloadValue: HomePayload?

    init(response: Response, delay: Duration = .milliseconds(150), hasCachedData: Bool = false) {
        self.response = response
        self.delay = delay
        self.hasCachedData = hasCachedData
        self.lastFetchFromCache = hasCachedData
        if hasCachedData {
            cachedPayloadValue = HomePayload.sample
        }
    }

    func isCacheValid() -> Bool {
        hasCachedData
    }

    func cachedPayload() -> HomePayload {
        cachedPayloadValue ?? HomePayload.sample
    }

    func invalidateCache() {
        hasCachedData = false
        cachedPayloadValue = nil
        lastFetchFromCache = false
    }

    func fetchHome(forceRefresh: Bool) async throws -> HomePayload {
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        lastFetchFromCache = false
        switch response {
        case .loaded(let payload):
            cachedPayloadValue = payload
            hasCachedData = true
            return payload
        case .empty:
            let payload = HomePayload.empty
            cachedPayloadValue = payload
            hasCachedData = true
            return payload
        case .error(let error):
            throw error
        }
    }
}
