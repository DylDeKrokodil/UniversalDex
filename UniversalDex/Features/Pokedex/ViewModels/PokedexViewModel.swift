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

    private let apiClient: PokeAPIClient
    private let pageSize = 30
    private var offset = 0
    private var totalCount: Int?

    var hasLoadedPokemon: Bool {
        !pokemon.isEmpty
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

    func reloadPokemon() async {
        pokemon = []
        offset = 0
        totalCount = nil
        errorMessage = nil

        await loadNextPage()
    }

    private func loadNextPage() async {
        guard !isLoadingPage, canLoadMore else {
            return
        }

        isLoadingPage = true
        defer { isLoadingPage = false }

        do {
            let response = try await apiClient.fetchPokemonPage(limit: pageSize, offset: offset)
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
