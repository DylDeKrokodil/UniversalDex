//
//  ShinyHunt.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct ShinyHunt: Identifiable, Codable, Hashable {
    var id = UUID()
    var pokemonID: Int?
    var pokemonName: String
    var game: ShinyGame
    var method: ShinyMethod
    var oddsDenominator: Int
    var encounters: Int
    var isCaught = false
    var createdAt = Date()
    var caughtAt: Date?

    var oddsText: String {
        "1/\(oddsDenominator.formatted())"
    }

    var formattedPokemonNumber: String? {
        guard let pokemonID else {
            return nil
        }

        return String(format: "%03d", pokemonID)
    }

    var artworkURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonID).png")
    }

    var shinySpriteURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/\(pokemonID).png")
    }

    var animatedShinySpriteURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/shiny/\(pokemonID).gif")
    }

    var latestCryURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/\(pokemonID).ogg")
    }

    var encounterProgress: Double {
        guard oddsDenominator > 0 else {
            return 0
        }

        return min(Double(encounters) / Double(oddsDenominator), 1)
    }

    var cumulativeProbabilityText: String {
        guard oddsDenominator > 0, encounters > 0 else {
            return "0%"
        }

        let missChance = pow(1 - (1 / Double(oddsDenominator)), Double(encounters))
        let cumulativeProbability = 1 - missChance

        return cumulativeProbability.formatted(.percent.precision(.fractionLength(1)))
    }
}
