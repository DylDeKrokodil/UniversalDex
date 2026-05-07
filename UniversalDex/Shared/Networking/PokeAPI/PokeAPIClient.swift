//
//  PokeAPIClient.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokeAPIClient {
    private static let cacheMaxAge: TimeInterval = 180 * 24 * 60 * 60

    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private let session: URLSession
    private let responseCache: DiskResponseCache

    init(
        session: URLSession = .shared,
        responseCache: DiskResponseCache? = nil
    ) {
        self.session = session
        self.responseCache = responseCache ?? .shared
    }

    func fetchPokemonPage(
        limit: Int,
        offset: Int,
        cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad
    ) async throws -> PokeAPIPaginatedResponse<PokeAPINamedResource> {
        var components = URLComponents(url: baseURL.appending(path: "pokemon"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        guard let url = components?.url else {
            throw PokeAPIError.invalidURL
        }

        let cacheKey = "pokeapi:pokemon:list:limit=\(limit):offset=\(offset)"

        if cachePolicy == .returnCacheDataElseLoad {
            if let cachedResponse: PokeAPIPaginatedResponse<PokeAPINamedResource> = await responseCache.value(
                forKey: cacheKey,
                maxAge: Self.cacheMaxAge
            ) {
                return cachedResponse
            }
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokeAPIError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(PokeAPIPaginatedResponse<PokeAPINamedResource>.self, from: data)
        await responseCache.save(decodedResponse, forKey: cacheKey)

        return decodedResponse
    }
}

enum PokeAPIError: Error {
    case invalidURL
    case invalidResponse
}
