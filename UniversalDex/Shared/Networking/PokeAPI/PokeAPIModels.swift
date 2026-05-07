//
//  PokeAPIModels.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokeAPIPaginatedResponse<Resource: Decodable>: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Resource]
}

struct PokeAPINamedResource: Decodable {
    let name: String
    let url: URL
}
