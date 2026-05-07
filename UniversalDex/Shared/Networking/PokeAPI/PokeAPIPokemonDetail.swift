//
//  PokeAPIPokemonDetail.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct PokeAPIPokemonDetail: Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let types: [PokemonTypeSlot]
    let stats: [PokemonStat]
    let abilities: [PokemonAbilitySlot]
    let gameIndices: [PokemonGameIndex]
    let sprites: PokemonSprites

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case height
        case weight
        case baseExperience = "base_experience"
        case types
        case stats
        case abilities
        case gameIndices = "game_indices"
        case sprites
    }
}

struct PokemonTypeSlot: Codable, Hashable {
    let slot: Int
    let type: PokeAPINamedResource
}

struct PokemonStat: Codable, Hashable {
    let baseStat: Int
    let effort: Int
    let stat: PokeAPINamedResource

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort
        case stat
    }
}

struct PokemonAbilitySlot: Codable, Hashable {
    let ability: PokeAPINamedResource
    let isHidden: Bool
    let slot: Int

    enum CodingKeys: String, CodingKey {
        case ability
        case isHidden = "is_hidden"
        case slot
    }
}

struct PokemonGameIndex: Codable, Hashable, Identifiable {
    let gameIndex: Int
    let version: PokeAPINamedResource

    var id: String {
        version.name
    }

    var displayName: String {
        version.name
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case gameIndex = "game_index"
        case version
    }
}

struct PokemonSprites: Codable {
    let frontDefault: URL?
    let frontShiny: URL?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}
