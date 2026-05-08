//
//  ShinyPokemonPickerViewModel.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 08/05/2026.
//

import Combine
import Foundation

@MainActor
final class ShinyPokemonPickerViewModel: ObservableObject {
    @Published private(set) var pokemon: [PokemonListItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""

    private let apiClient: PokeAPIClient

    func filteredPokemon(for game: ShinyGame) -> [PokemonListItem] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let regionalPokemon = pokemon.filter { game.containsRegionalPokemon($0) }

        guard !trimmedSearch.isEmpty else {
            return Array(regionalPokemon.prefix(30))
        }

        return regionalPokemon
            .filter { pokemon in
                pokemon.displayName.localizedCaseInsensitiveContains(trimmedSearch)
                    || pokemon.formattedNumber.contains(trimmedSearch)
            }
            .prefix(30)
            .map { $0 }
    }

    init(apiClient: PokeAPIClient? = nil) {
        self.apiClient = apiClient ?? PokeAPIClient()
    }

    func loadPokemonIfNeeded() async {
        guard pokemon.isEmpty, !isLoading else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await apiClient.fetchPokemonPage(limit: 1302, offset: 0)
            pokemon = response.results.compactMap(PokemonListItem.init)
            errorMessage = nil
        } catch {
            errorMessage = "Pokemon could not be loaded. Check your connection and try again."
            AppDebugLog.log("Shiny Pokemon picker load failed: \(error.localizedDescription)")
        }
    }
}
