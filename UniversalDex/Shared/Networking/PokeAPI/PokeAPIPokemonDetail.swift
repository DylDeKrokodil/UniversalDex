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
    let moves: [PokemonMove]
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
        case moves
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

struct PokeAPIPokemonSpecies: Codable {
    let id: Int
    let name: String
    let evolutionChain: PokeAPIResource
    let flavorTextEntries: [PokemonFlavorTextEntry]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case evolutionChain = "evolution_chain"
        case flavorTextEntries = "flavor_text_entries"
    }
}

struct PokemonFlavorTextEntry: Codable, Hashable {
    let flavorText: String
    let language: PokeAPINamedResource
    let version: PokeAPINamedResource

    var cleanedFlavorText: String {
        flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000C}", with: " ")
            .split(separator: " ")
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
        case language
        case version
    }
}

struct PokemonMove: Codable, Hashable {
    let move: PokeAPINamedResource
    let versionGroupDetails: [PokemonMoveVersionGroupDetail]

    enum CodingKeys: String, CodingKey {
        case move
        case versionGroupDetails = "version_group_details"
    }
}

struct PokemonMoveVersionGroupDetail: Codable, Hashable {
    let levelLearnedAt: Int
    let moveLearnMethod: PokeAPINamedResource
    let versionGroup: PokeAPINamedResource

    enum CodingKeys: String, CodingKey {
        case levelLearnedAt = "level_learned_at"
        case moveLearnMethod = "move_learn_method"
        case versionGroup = "version_group"
    }
}

struct PokeAPIEvolutionChain: Codable {
    let id: Int
    let chain: PokemonEvolutionChainLink
}

struct PokemonEvolutionChainLink: Codable {
    let species: PokeAPINamedResource
    let evolutionDetails: [PokemonEvolutionDetail]
    let evolvesTo: [PokemonEvolutionChainLink]

    enum CodingKeys: String, CodingKey {
        case species
        case evolutionDetails = "evolution_details"
        case evolvesTo = "evolves_to"
    }
}

struct PokemonEvolutionDetail: Codable {
    let minLevel: Int?
    let item: PokeAPINamedResource?
    let trigger: PokeAPINamedResource?

    enum CodingKeys: String, CodingKey {
        case minLevel = "min_level"
        case item
        case trigger
    }
}

struct PokemonEncounter: Codable, Hashable {
    let locationArea: PokeAPINamedResource
    let versionDetails: [PokemonEncounterVersionDetail]

    enum CodingKeys: String, CodingKey {
        case locationArea = "location_area"
        case versionDetails = "version_details"
    }
}

struct PokemonEncounterVersionDetail: Codable, Hashable {
    let maxChance: Int
    let version: PokeAPINamedResource
    let encounterDetails: [PokemonEncounterDetail]

    enum CodingKeys: String, CodingKey {
        case maxChance = "max_chance"
        case version
        case encounterDetails = "encounter_details"
    }
}

struct PokemonEncounterDetail: Codable, Hashable {
    let chance: Int
    let method: PokeAPINamedResource
    let minLevel: Int
    let maxLevel: Int

    enum CodingKeys: String, CodingKey {
        case chance
        case method
        case minLevel = "min_level"
        case maxLevel = "max_level"
    }
}
