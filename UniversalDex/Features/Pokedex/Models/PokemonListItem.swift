//
//  PokemonListItem.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokemonListItem: Identifiable, Hashable {
    let id: Int
    let displayID: Int
    let name: String

    init(id: Int, displayID: Int? = nil, name: String) {
        self.id = id
        self.displayID = displayID ?? id
        self.name = name
    }

    var displayName: String {
        name
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    var formattedNumber: String {
        String(format: "%03d", displayID)
    }

    var artworkURLs: [URL] {
        [
            supabaseHomeShinyURL,
            supabaseArtworkURL
        ].compactMap { $0 }
    }

    var artworkNonShinyURLs: [URL] {
        [supabaseArtworkURL].compactMap { $0 }
    }

    var supabaseHomeShinyURL: URL? {
        SupabaseConfiguration.publicStorageURL(bucket: "images", path: "sprites/pokemon/other/home/shiny/\(id).png")
    }

    var supabaseArtworkURL: URL? {
        SupabaseConfiguration.publicStorageURL(bucket: "images", path: "sprites/pokemon/other/official-artwork/shiny/\(id).png")
    }
}

extension PokemonListItem {
    init?(resource: PokeAPINamedResource) {
        guard let id = resource.url.pokemonID else {
            return nil
        }

        self.id = id
        displayID = id
        self.name = resource.name
    }

    static func makeListItems(
        from resources: [PokeAPINamedResource],
        basePokemon existingBasePokemon: [PokemonListItem] = []
    ) -> [PokemonListItem] {
        let basePokemon = resources.compactMap { resource -> PokemonListItem? in
            guard let id = resource.url.pokemonID, id <= 1025 else {
                return nil
            }

            return PokemonListItem(id: id, name: resource.name)
        } + existingBasePokemon.filter { $0.id == $0.displayID && $0.id <= 1025 }
        let baseIDsByName = Dictionary(basePokemon.map { ($0.name, $0.id) }) { firstID, _ in firstID }
        let baseNamesByLength = baseIDsByName.keys.sorted { firstName, secondName in
            firstName.count > secondName.count
        }

        return resources.compactMap { resource in
            guard let id = resource.url.pokemonID else {
                return nil
            }

            let displayID = baseNamesByLength
                .first { resource.name == $0 || resource.name.hasPrefix("\($0)-") }
                .flatMap { baseIDsByName[$0] }
                ?? id

            return PokemonListItem(
                id: id,
                displayID: displayID,
                name: resource.name
            )
        }
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
