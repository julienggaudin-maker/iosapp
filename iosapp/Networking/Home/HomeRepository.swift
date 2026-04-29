import Foundation

struct HomeSection: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let ctaTitle: String
    let ctaName: String
    let iconName: String
    let accentColorName: String
}

struct HomePayload: Codable, Equatable {
    let greeting: String?
    let heroImageURL: String?
    let sections: [HomeSection]
}

struct HomeCachePolicy: Equatable {
    let ttl: TimeInterval

    static let `default` = HomeCachePolicy(ttl: 15 * 60)
}

enum HomeError: Error, Equatable {
    case networkFailure(Error)
    case decodingFailure
    case unauthorized
    case offline
    case unknown

    static func == (lhs: HomeError, rhs: HomeError) -> Bool {
        switch (lhs, rhs) {
        case (.networkFailure, .networkFailure),
             (.decodingFailure, .decodingFailure),
             (.unauthorized, .unauthorized),
             (.offline, .offline),
             (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

    var analyticsValue: String {
        switch self {
        case .networkFailure:
            return "network_failure"
        case .decodingFailure:
            return "decoding_failure"
        case .unauthorized:
            return "unauthorized"
        case .offline:
            return "offline"
        case .unknown:
            return "unknown"
        }
    }

    var userMessage: String {
        switch self {
        case .networkFailure:
            return "Impossible de joindre le serveur."
        case .decodingFailure:
            return "Nous rencontrons un probleme de donnees."
        case .unauthorized:
            return "Votre session a expire."
        case .offline:
            return "Pas de connexion."
        case .unknown:
            return "Une erreur est survenue."
        }
    }
}

protocol HomeRepository {
    var hasCachedData: Bool { get }
    var lastFetchFromCache: Bool { get }

    func isCacheValid() -> Bool
    func cachedPayload() -> HomePayload
    func invalidateCache()
    func fetchHome(forceRefresh: Bool) async throws -> HomePayload
}

extension HomePayload {
    static let empty = HomePayload(greeting: nil, heroImageURL: nil, sections: [])

    static let sample = HomePayload(
        greeting: nil,
        heroImageURL: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
        sections: HomeSection.sampleSections()
    )
}

extension HomeSection {
    static func sampleSections() -> [HomeSection] {
        [
            HomeSection(
                id: UUID(),
                title: "Vos objectifs",
                subtitle: "Suivez vos progres avec une vue rapide.",
                ctaTitle: "Voir mes objectifs",
                ctaName: "objectives",
                iconName: "flag.fill",
                accentColorName: "indigo"
            ),
            HomeSection(
                id: UUID(),
                title: "Activites recentes",
                subtitle: "Retrouvez les derniers elements consultes.",
                ctaTitle: "Consulter l'historique",
                ctaName: "activity",
                iconName: "clock.fill",
                accentColorName: "teal"
            )
        ]
    }
}
