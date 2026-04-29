import Foundation

struct JobCachePolicy: Equatable {
    let ttl: TimeInterval

    static let `default` = JobCachePolicy(ttl: 10 * 60)
}

enum JobRepositoryError: Error, Equatable {
    case fileNotFound
    case decodingFailure
    case networkFailure
    case unknown

    var userMessage: String {
        switch self {
        case .fileNotFound:
            return "Offres indisponibles pour le moment."
        case .decodingFailure:
            return "Nous rencontrons un probleme de donnees."
        case .networkFailure:
            return "Impossible de joindre le serveur."
        case .unknown:
            return "Une erreur est survenue."
        }
    }
}

protocol JobRepositoryProtocol {
    var hasCachedData: Bool { get }
    var lastFetchFromCache: Bool { get }

    func isCacheValid() -> Bool
    func cachedJobs() -> [JobOffer]
    func invalidateCache()
    func fetchJobs(forceRefresh: Bool) async throws -> [JobOffer]
}
