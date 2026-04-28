import Foundation
import os

final class HomeAPIService: HomeRepository {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.app.home", category: "api")
    private let cachePolicy: HomeCachePolicy

    private static let defaultBaseURLString = "https://example.com"

    private let cacheURL: URL

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        cachePolicy: HomeCachePolicy = .default
    ) {
        self.session = session
        self.decoder = decoder
        self.cachePolicy = cachePolicy
        let baseURL = Self.resolveBaseURL()
        self.cacheURL = Self.homeEndpoint(from: baseURL)
    }

    private static func resolveBaseURL(
        infoDictionary: [String: Any] = Bundle.main.infoDictionary ?? [:]
    ) -> URL {
        let rawValue = infoDictionary["HOME_API_BASE_URL"] as? String
        let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString: String
        if let trimmed, !trimmed.isEmpty {
            urlString = trimmed
        } else {
            urlString = defaultBaseURLString
        }
        let baseURL = URL(string: urlString) ?? URL(string: defaultBaseURLString)
        return baseURL ?? URL(fileURLWithPath: "/")
    }

    private static func homeEndpoint(from baseURL: URL) -> URL {
        if baseURL.lastPathComponent.lowercased() == "home" {
            return baseURL
        }
        return baseURL.appendingPathComponent("home")
    }

    var hasCachedData: Bool {
        guard let cachedResponse = cachedResponse() else { return false }
        return !cachedResponse.data.isEmpty
    }

    private(set) var lastFetchFromCache: Bool = false

    func isCacheValid() -> Bool {
        guard let cachedResponse = cachedResponse(),
              let response = cachedResponse.response as? HTTPURLResponse,
              let fetchedAt = response.value(forHTTPHeaderField: "X-Cache-Fetched-At"),
              let fetchedInterval = TimeInterval(fetchedAt) else {
            return false
        }
        let elapsed = Date().timeIntervalSince1970 - fetchedInterval
        return elapsed < cachePolicy.ttl
    }

    func cachedPayload() -> HomePayload {
        guard let cachedResponse = cachedResponse() else { return .empty }
        do {
            lastFetchFromCache = true
            return try decoder.decode(HomePayload.self, from: cachedResponse.data)
        } catch {
            logger.error("Cached payload decoding failed: \(error.localizedDescription)")
            return .empty
        }
    }

    func invalidateCache() {
        URLCache.shared.removeCachedResponse(for: URLRequest(url: cacheURL))
    }

    func fetchHome(forceRefresh: Bool) async throws -> HomePayload {
        var request = URLRequest(url: cacheURL)
        request.httpMethod = "GET"
        request.cachePolicy = forceRefresh ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HomeError.unknown
        }

        if httpResponse.statusCode == 401 {
            logger.error("Unauthorized response: 401")
            throw HomeError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.error("HTTP error status: \(httpResponse.statusCode)")
            throw HomeError.networkFailure(HomeAPIServiceError.httpStatus(code: httpResponse.statusCode))
        }

        do {
            let payload = try decoder.decode(HomePayload.self, from: data)
            cachePayload(payload, url: cacheURL)
            lastFetchFromCache = false
            return payload
        } catch {
            logger.error("Decoding failure: \(error.localizedDescription)")
            throw HomeError.decodingFailure
        }
    }

    private func cachePayload(_ payload: HomePayload, url: URL) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Cache-Control": "max-age=900",
                "X-Cache-Fetched-At": "\(Date().timeIntervalSince1970)"
            ]
        )
        if let response {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
        }
    }

    private func cachedResponse() -> CachedURLResponse? {
        URLCache.shared.cachedResponse(for: URLRequest(url: cacheURL))
    }
}

enum HomeAPIServiceError: Error {
    case httpStatus(code: Int)
}
