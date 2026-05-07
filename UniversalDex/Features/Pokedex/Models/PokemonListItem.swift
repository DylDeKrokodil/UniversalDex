//
//  PokemonListItem.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokemonListItem: Identifiable, Hashable {
    let id: Int
    let name: String

    var displayName: String {
        name
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    var formattedNumber: String {
        "#\(String(format: "%04d", id))"
    }

    var artworkURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }
}

extension PokemonListItem {
    init?(resource: PokeAPINamedResource) {
        guard let id = resource.url.pokemonID else {
            return nil
        }

        self.id = id
        self.name = resource.name
    }
}

private extension URL {
    var pokemonID: Int? {
        pathComponents
            .reversed()
            .first { Int($0) != nil }
            .flatMap(Int.init)
    }
}
