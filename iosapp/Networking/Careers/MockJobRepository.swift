import Foundation

final class MockJobRepository: JobRepositoryProtocol {
    private let bundle: Bundle
    private let decoder: JSONDecoder
    private let cachePolicy: JobCachePolicy
    private let resourceName: String

    private var cachedJobsValue: [JobOffer] = []
    private var lastFetchDate: Date?

    private(set) var lastFetchFromCache: Bool = false

    init(
        bundle: Bundle = .main,
        decoder: JSONDecoder = JSONDecoder(),
        cachePolicy: JobCachePolicy = .default,
        resourceName: String = "jobs_mock"
    ) {
        self.bundle = bundle
        self.decoder = decoder
        self.cachePolicy = cachePolicy
        self.resourceName = resourceName
        decoder.dateDecodingStrategy = .iso8601
    }

    var hasCachedData: Bool {
        !cachedJobsValue.isEmpty
    }

    func isCacheValid() -> Bool {
        guard let lastFetchDate else { return false }
        return Date().timeIntervalSince(lastFetchDate) < cachePolicy.ttl
    }

    func cachedJobs() -> [JobOffer] {
        cachedJobsValue
    }

    func invalidateCache() {
        cachedJobsValue = []
        lastFetchDate = nil
        lastFetchFromCache = false
    }

    func fetchJobs(forceRefresh: Bool) async throws -> [JobOffer] {
        if !forceRefresh, isCacheValid(), hasCachedData {
            lastFetchFromCache = true
            return cachedJobsValue
        }

        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw JobRepositoryError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try decoder.decode([JobOffer].self, from: data)
            cachedJobsValue = payload.filter { $0.isActive }
            lastFetchDate = Date()
            lastFetchFromCache = false
            return cachedJobsValue
        } catch let error as JobRepositoryError {
            throw error
        } catch let error as DecodingError {
            _ = error
            throw JobRepositoryError.decodingFailure
        } catch {
            throw JobRepositoryError.unknown
        }
    }
}
