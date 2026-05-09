//
//  PokedexGeneration.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum PokedexGeneration: String, CaseIterable, Identifiable {
    case all
    case generationOne
    case generationTwo
    case generationThree
    case generationFour
    case generationFive
    case generationSix
    case generationSeven
    case generationEight
    case generationNine

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .generationOne:
            return "Gen 1"
        case .generationTwo:
            return "Gen 2"
        case .generationThree:
            return "Gen 3"
        case .generationFour:
            return "Gen 4"
        case .generationFive:
            return "Gen 5"
        case .generationSix:
            return "Gen 6"
        case .generationSeven:
            return "Gen 7"
        case .generationEight:
            return "Gen 8"
        case .generationNine:
            return "Gen 9"
        }
    }

    func contains(_ pokemon: PokemonListItem) -> Bool {
        guard let idRange else {
            return true
        }

        return idRange.contains(pokemon.displayID)
    }

    private var idRange: ClosedRange<Int>? {
        switch self {
        case .all:
            return nil
        case .generationOne:
            return 1...151
        case .generationTwo:
            return 152...251
        case .generationThree:
            return 252...386
        case .generationFour:
            return 387...493
        case .generationFive:
            return 494...649
        case .generationSix:
            return 650...721
        case .generationSeven:
            return 722...809
        case .generationEight:
            return 810...905
        case .generationNine:
            return 906...1025
        }
    }
}
