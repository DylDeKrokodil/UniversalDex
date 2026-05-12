//
//  PokeAPIModels.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokeAPIPaginatedResponse<Resource: Codable>: Codable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Resource]
}

struct PokeAPINamedResource: Codable, Hashable {
    let name: String
    let url: URL

    var displayName: String {
        name
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

struct PokeAPIResource: Codable, Hashable {
    let url: URL
}

enum PokeAPISpriteRepository {
    private static let baseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master"

    static func url(path: String) -> URL? {
        let cleanPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(baseURL)/\(cleanPath)")
    }
}
