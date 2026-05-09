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
    @Published private(set) var isHydratingAllPokemon = false
    @Published private(set) var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedGeneration = PokedexGeneration.all
    @Published var sortOption = PokedexSortOption.numberAscending

    private let apiClient: PokeAPIClient
    private let pageSize = 120
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

        return offset < totalCount
    }

    init(apiClient: PokeAPIClient? = nil) {
        self.apiClient = apiClient ?? PokeAPIClient()
    }

    func loadInitialPokemonIfNeeded() async {
        guard pokemon.isEmpty else {
            return
        }

        AppDebugLog.log("Pokedex initial load started")
        _ = await loadNextPage()
        startHydratingAllPokemon()
    }

    func loadMoreIfNeeded(currentItem: PokemonListItem) async {
        guard canLoadMore,
              !hasActiveFilters,
              !isHydratingAllPokemon,
              !isLoadingPage,
              shouldLoadMore(after: currentItem) else {
            return
        }

        _ = await loadNextPage()
    }

    func retry() async {
        errorMessage = nil
        _ = await loadNextPage()
        startHydratingAllPokemon()
    }

    private func startHydratingAllPokemon() {
        guard canLoadMore, !isHydratingAllPokemon else {
            return
        }

        Task {
            await hydrateRemainingPokemon()
        }
    }

    private func hydrateRemainingPokemon() async {
        guard canLoadMore, !isHydratingAllPokemon else {
            return
        }

        isHydratingAllPokemon = true
        AppDebugLog.log("Pokedex background cache hydration started at offset \(offset)")
        defer { isHydratingAllPokemon = false }

        while canLoadMore {
            let loadedPage = await loadNextPage(showsPageLoading: false)

            if !loadedPage {
                AppDebugLog.log("Pokedex background cache hydration stopped at offset \(offset)")
                return
            }
        }

        AppDebugLog.log("Pokedex background cache hydration completed with \(pokemon.count) Pokemon")
    }

    @discardableResult
    private func loadNextPage(
        cachePolicy: APIResponseCachePolicy = .returnCacheDataElseLoad,
        showsPageLoading: Bool = true
    ) async -> Bool {
        guard !isLoadingPage, canLoadMore else {
            return false
        }

        if showsPageLoading {
            isLoadingPage = true
        }

        defer {
            if showsPageLoading {
                isLoadingPage = false
            }
        }

        do {
            let response = try await apiClient.fetchPokemonPage(
                limit: pageSize,
                offset: offset,
                cachePolicy: cachePolicy
            )
            let newPokemon = PokemonListItem.makeListItems(
                from: response.results,
                basePokemon: pokemon
            )

            totalCount = response.count
            offset += response.results.count
            appendUniquePokemon(newPokemon)
            errorMessage = nil
            AppDebugLog.log("Pokedex loaded page: offset \(offset), visible cache count \(pokemon.count)")
            return true
        } catch {
            errorMessage = "Could not load Pokemon. Check your connection and try again."
            AppDebugLog.log("Pokedex page load failed at offset \(offset): \(error.localizedDescription)")
            return false
        }
    }

    private func appendUniquePokemon(_ newPokemon: [PokemonListItem]) {
        let existingIDs = Set(pokemon.map(\.id))
        pokemon.append(contentsOf: newPokemon.filter { !existingIDs.contains($0.id) })
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
