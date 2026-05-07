//
//  PokemonGameVersion.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum PokemonGameGeneration: Int, CaseIterable, Identifiable {
    case generationI = 1
    case generationII
    case generationIII
    case generationIV
    case generationV
    case generationVI
    case generationVII
    case generationVIII
    case generationIX

    var id: Int {
        rawValue
    }

    var displayName: String {
        "Generation \(rawValue)"
    }
}

struct PokemonGameVersion: Hashable, Identifiable {
    let id: String
    let displayName: String
    let generation: PokemonGameGeneration
    let sortOrder: Int

    var pokeAPIVersionNames: Set<String> {
        [id]
    }
}

extension PokemonGameVersion {
    static let all: [PokemonGameVersion] = [
        PokemonGameVersion(id: "red", displayName: "Red", generation: .generationI, sortOrder: 1),
        PokemonGameVersion(id: "blue", displayName: "Blue", generation: .generationI, sortOrder: 2),
        PokemonGameVersion(id: "yellow", displayName: "Yellow", generation: .generationI, sortOrder: 3),

        PokemonGameVersion(id: "gold", displayName: "Gold", generation: .generationII, sortOrder: 1),
        PokemonGameVersion(id: "silver", displayName: "Silver", generation: .generationII, sortOrder: 2),
        PokemonGameVersion(id: "crystal", displayName: "Crystal", generation: .generationII, sortOrder: 3),

        PokemonGameVersion(id: "ruby", displayName: "Ruby", generation: .generationIII, sortOrder: 1),
        PokemonGameVersion(id: "sapphire", displayName: "Sapphire", generation: .generationIII, sortOrder: 2),
        PokemonGameVersion(id: "emerald", displayName: "Emerald", generation: .generationIII, sortOrder: 3),
        PokemonGameVersion(id: "firered", displayName: "FireRed", generation: .generationIII, sortOrder: 4),
        PokemonGameVersion(id: "leafgreen", displayName: "LeafGreen", generation: .generationIII, sortOrder: 5),

        PokemonGameVersion(id: "diamond", displayName: "Diamond", generation: .generationIV, sortOrder: 1),
        PokemonGameVersion(id: "pearl", displayName: "Pearl", generation: .generationIV, sortOrder: 2),
        PokemonGameVersion(id: "platinum", displayName: "Platinum", generation: .generationIV, sortOrder: 3),
        PokemonGameVersion(id: "heartgold", displayName: "HeartGold", generation: .generationIV, sortOrder: 4),
        PokemonGameVersion(id: "soulsilver", displayName: "SoulSilver", generation: .generationIV, sortOrder: 5),

        PokemonGameVersion(id: "black", displayName: "Black", generation: .generationV, sortOrder: 1),
        PokemonGameVersion(id: "white", displayName: "White", generation: .generationV, sortOrder: 2),
        PokemonGameVersion(id: "black-2", displayName: "Black 2", generation: .generationV, sortOrder: 3),
        PokemonGameVersion(id: "white-2", displayName: "White 2", generation: .generationV, sortOrder: 4),

        PokemonGameVersion(id: "x", displayName: "X", generation: .generationVI, sortOrder: 1),
        PokemonGameVersion(id: "y", displayName: "Y", generation: .generationVI, sortOrder: 2),
        PokemonGameVersion(id: "omega-ruby", displayName: "Omega Ruby", generation: .generationVI, sortOrder: 3),
        PokemonGameVersion(id: "alpha-sapphire", displayName: "Alpha Sapphire", generation: .generationVI, sortOrder: 4),

        PokemonGameVersion(id: "sun", displayName: "Sun", generation: .generationVII, sortOrder: 1),
        PokemonGameVersion(id: "moon", displayName: "Moon", generation: .generationVII, sortOrder: 2),
        PokemonGameVersion(id: "ultra-sun", displayName: "Ultra Sun", generation: .generationVII, sortOrder: 3),
        PokemonGameVersion(id: "ultra-moon", displayName: "Ultra Moon", generation: .generationVII, sortOrder: 4),
        PokemonGameVersion(id: "lets-go-pikachu", displayName: "Let's Go, Pikachu!", generation: .generationVII, sortOrder: 5),
        PokemonGameVersion(id: "lets-go-eevee", displayName: "Let's Go, Eevee!", generation: .generationVII, sortOrder: 6),

        PokemonGameVersion(id: "sword", displayName: "Sword", generation: .generationVIII, sortOrder: 1),
        PokemonGameVersion(id: "shield", displayName: "Shield", generation: .generationVIII, sortOrder: 2),
        PokemonGameVersion(id: "brilliant-diamond", displayName: "Brilliant Diamond", generation: .generationVIII, sortOrder: 3),
        PokemonGameVersion(id: "shining-pearl", displayName: "Shining Pearl", generation: .generationVIII, sortOrder: 4),
        PokemonGameVersion(id: "legends-arceus", displayName: "Legends: Arceus", generation: .generationVIII, sortOrder: 5),

        PokemonGameVersion(id: "scarlet", displayName: "Scarlet", generation: .generationIX, sortOrder: 1),
        PokemonGameVersion(id: "violet", displayName: "Violet", generation: .generationIX, sortOrder: 2),
        PokemonGameVersion(id: "legends-z-a", displayName: "Legends: Z-A", generation: .generationIX, sortOrder: 3)
    ]

    static func versions(in generation: PokemonGameGeneration) -> [PokemonGameVersion] {
        all
            .filter { $0.generation == generation }
            .sorted { $0.sortOrder < $1.sortOrder }
    }
}
