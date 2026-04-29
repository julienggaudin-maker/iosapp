import Foundation

final class RemoteJobRepository: JobRepositoryProtocol {
    var hasCachedData: Bool { false }
    var lastFetchFromCache: Bool { false }

    func isCacheValid() -> Bool { false }
    func cachedJobs() -> [JobOffer] { [] }
    func invalidateCache() {}

    func fetchJobs(forceRefresh: Bool) async throws -> [JobOffer] {
        throw JobRepositoryError.networkFailure
    }
}
