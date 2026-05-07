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
        let requestLabel = "pokemon list limit=\(limit) offset=\(offset)"

        if cachePolicy == .returnCacheDataElseLoad {
            if let cachedResponse: PokeAPIPaginatedResponse<PokeAPINamedResource> = await responseCache.value(
                forKey: cacheKey,
                maxAge: Self.cacheMaxAge
            ) {
                AppDebugLog.log("PokeAPI cache hit: \(requestLabel)")
                return cachedResponse
            }

            AppDebugLog.log("PokeAPI cache miss: \(requestLabel)")
        } else {
            AppDebugLog.log("PokeAPI cache bypass: \(requestLabel)")
        }

        AppDebugLog.log("PokeAPI request: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokeAPIError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(PokeAPIPaginatedResponse<PokeAPINamedResource>.self, from: data)
        await responseCache.save(decodedResponse, forKey: cacheKey)
        AppDebugLog.log("PokeAPI cached response: \(requestLabel)")

        return decodedResponse
    }

    func fetchPokemonDetail(
        id: Int,
        cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad
    ) async throws -> PokeAPIPokemonDetail {
        let url = baseURL.appending(path: "pokemon/\(id)")
        let cacheKey = "pokeapi:pokemon:detail:id=\(id)"
        let requestLabel = "pokemon detail id=\(id)"

        if cachePolicy == .returnCacheDataElseLoad {
            if let cachedResponse: PokeAPIPokemonDetail = await responseCache.value(
                forKey: cacheKey,
                maxAge: Self.cacheMaxAge
            ) {
                AppDebugLog.log("PokeAPI cache hit: \(requestLabel)")
                return cachedResponse
            }

            AppDebugLog.log("PokeAPI cache miss: \(requestLabel)")
        } else {
            AppDebugLog.log("PokeAPI cache bypass: \(requestLabel)")
        }

        AppDebugLog.log("PokeAPI request: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokeAPIError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(PokeAPIPokemonDetail.self, from: data)
        await responseCache.save(decodedResponse, forKey: cacheKey)
        AppDebugLog.log("PokeAPI cached response: \(requestLabel)")

        return decodedResponse
    }

    func fetchPokemonSpecies(
        id: Int,
        cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad
    ) async throws -> PokeAPIPokemonSpecies {
        let url = baseURL.appending(path: "pokemon-species/\(id)")
        let cacheKey = "pokeapi:pokemon:species:id=\(id)"
        let requestLabel = "pokemon species id=\(id)"

        if cachePolicy == .returnCacheDataElseLoad {
            if let cachedResponse: PokeAPIPokemonSpecies = await responseCache.value(
                forKey: cacheKey,
                maxAge: Self.cacheMaxAge
            ) {
                AppDebugLog.log("PokeAPI cache hit: \(requestLabel)")
                return cachedResponse
            }

            AppDebugLog.log("PokeAPI cache miss: \(requestLabel)")
        } else {
            AppDebugLog.log("PokeAPI cache bypass: \(requestLabel)")
        }

        AppDebugLog.log("PokeAPI request: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokeAPIError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(PokeAPIPokemonSpecies.self, from: data)
        await responseCache.save(decodedResponse, forKey: cacheKey)
        AppDebugLog.log("PokeAPI cached response: \(requestLabel)")

        return decodedResponse
    }

    func fetchEvolutionChain(
        url: URL,
        cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad
    ) async throws -> PokeAPIEvolutionChain {
        try await fetchCachedResource(
            url: url,
            cacheKey: "pokeapi:evolution-chain:url=\(url.absoluteString)",
            requestLabel: "evolution chain \(url.lastPathComponent)",
            cachePolicy: cachePolicy
        )
    }

    func fetchPokemonEncounters(
        id: Int,
        cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad
    ) async throws -> [PokemonEncounter] {
        let url = baseURL.appending(path: "pokemon/\(id)/encounters")

        return try await fetchCachedResource(
            url: url,
            cacheKey: "pokeapi:pokemon:encounters:id=\(id)",
            requestLabel: "pokemon encounters id=\(id)",
            cachePolicy: cachePolicy
        )
    }

    private func fetchCachedResource<Response: Codable>(
        url: URL,
        cacheKey: String,
        requestLabel: String,
        cachePolicy: APIResponseCachePolicy
    ) async throws -> Response {
        if cachePolicy == .returnCacheDataElseLoad {
            if let cachedResponse: Response = await responseCache.value(
                forKey: cacheKey,
                maxAge: Self.cacheMaxAge
            ) {
                AppDebugLog.log("PokeAPI cache hit: \(requestLabel)")
                return cachedResponse
            }

            AppDebugLog.log("PokeAPI cache miss: \(requestLabel)")
        } else {
            AppDebugLog.log("PokeAPI cache bypass: \(requestLabel)")
        }

        AppDebugLog.log("PokeAPI request: \(url.absoluteString)")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokeAPIError.invalidResponse
        }

        let decodedResponse = try JSONDecoder().decode(Response.self, from: data)
        await responseCache.save(decodedResponse, forKey: cacheKey)
        AppDebugLog.log("PokeAPI cached response: \(requestLabel)")

        return decodedResponse
    }
}

enum PokeAPIError: Error {
    case invalidURL
    case invalidResponse
}
