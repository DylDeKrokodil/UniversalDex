//
//  PokeAPIClient.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokeAPIClient {
    private let baseURL = URL(string: "https://pokeapi.co/api/v2")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPokemonPage(limit: Int, offset: Int) async throws -> PokeAPIPaginatedResponse<PokeAPINamedResource> {
        var components = URLComponents(url: baseURL.appending(path: "pokemon"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        guard let url = components?.url else {
            throw PokeAPIError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw PokeAPIError.invalidResponse
        }

        return try JSONDecoder().decode(PokeAPIPaginatedResponse<PokeAPINamedResource>.self, from: data)
    }
}

enum PokeAPIError: Error {
    case invalidURL
    case invalidResponse
}
