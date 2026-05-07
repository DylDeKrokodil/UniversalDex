//
//  PokedexSortOption.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum PokedexSortOption: String, CaseIterable, Identifiable {
    case numberAscending
    case numberDescending
    case nameAscending
    case nameDescending

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .numberAscending:
            return "001-999"
        case .numberDescending:
            return "999-001"
        case .nameAscending:
            return "A-Z"
        case .nameDescending:
            return "Z-A"
        }
    }

    func sort(_ pokemon: [PokemonListItem]) -> [PokemonListItem] {
        switch self {
        case .numberAscending:
            return pokemon.sorted { $0.id < $1.id }
        case .numberDescending:
            return pokemon.sorted { $0.id > $1.id }
        case .nameAscending:
            return pokemon.sorted { $0.displayName < $1.displayName }
        case .nameDescending:
            return pokemon.sorted { $0.displayName > $1.displayName }
        }
    }
}
