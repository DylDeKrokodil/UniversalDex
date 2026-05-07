//
//  PokedexViewModel.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation
import Combine

@MainActor
final class PokedexViewModel: ObservableObject {
    @Published private(set) var pokemon: [PokemonListItem] = []
    @Published private(set) var isLoadingPage = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedGeneration = PokedexGeneration.all
    @Published var sortOption = PokedexSortOption.numberAscending

    private let apiClient: PokeAPIClient
    private let pageSize = 30
    private var offset = 0
    private var totalCount: Int?

    var hasLoadedPokemon: Bool {
        !pokemon.isEmpty
    }

    var filteredPokemon: [PokemonListItem] {
        let searchedPokemon = pokemon.filter { pokemon in
            let matchesSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || pokemon.displayName.localizedCaseInsensitiveContains(searchText)
                || pokemon.formattedNumber.contains(searchText)

            return matchesSearch && selectedGeneration.contains(pokemon)
        }

        return sortOption.sort(searchedPokemon)
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedGeneration != .all
            || sortOption != .numberAscending
    }

    var canLoadMore: Bool {
        guard let totalCount else {
            return true
        }

        return pokemon.count < totalCount
    }

    init(apiClient: PokeAPIClient? = nil) {
        self.apiClient = apiClient ?? PokeAPIClient()
    }

    func loadInitialPokemonIfNeeded() async {
        guard pokemon.isEmpty else {
            return
        }

        await loadNextPage()
    }

    func loadMoreIfNeeded(currentItem: PokemonListItem) async {
        guard canLoadMore,
              !hasActiveFilters,
              !isLoadingPage,
              shouldLoadMore(after: currentItem) else {
            return
        }

        await loadNextPage()
    }

    func retry() async {
        errorMessage = nil
        await loadNextPage()
    }

    private func loadNextPage(cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad) async {
        guard !isLoadingPage, canLoadMore else {
            return
        }

        isLoadingPage = true
        defer { isLoadingPage = false }

        do {
            let response = try await apiClient.fetchPokemonPage(
                limit: pageSize,
                offset: offset,
                cachePolicy: cachePolicy
            )
            let newPokemon = response.results.compactMap(PokemonListItem.init)

            totalCount = response.count
            offset += response.results.count
            pokemon.append(contentsOf: newPokemon)
            errorMessage = nil
        } catch {
            errorMessage = "Could not load Pokemon. Check your connection and try again."
        }
    }

    private func shouldLoadMore(after item: PokemonListItem) -> Bool {
        guard let index = pokemon.firstIndex(of: item) else {
            return false
        }

        let thresholdIndex = pokemon.index(
            pokemon.endIndex,
            offsetBy: -6,
            limitedBy: pokemon.startIndex
        ) ?? pokemon.startIndex

        return index >= thresholdIndex
    }
}
