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
