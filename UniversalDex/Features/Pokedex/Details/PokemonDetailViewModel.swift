//
//  PokemonDetailViewModel.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Combine
import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokeAPIPokemonDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var selectedGame: PokemonGameVersion?

    private let pokemon: PokemonListItem
    private let apiClient: PokeAPIClient

    var title: String {
        pokemon.displayName
    }

    var selectedGameDisplayName: String {
        selectedGame?.displayName ?? "Game"
    }

    var selectedGameIndex: PokemonGameIndex? {
        guard let selectedGame else {
            return nil
        }

        return detail?.gameIndices.first { selectedGame.pokeAPIVersionNames.contains($0.version.name) }
    }

    init(
        pokemon: PokemonListItem,
        apiClient: PokeAPIClient? = nil
    ) {
        self.pokemon = pokemon
        self.apiClient = apiClient ?? PokeAPIClient()
    }

    func loadDetailIfNeeded() async {
        guard detail == nil else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let detail = try await apiClient.fetchPokemonDetail(id: pokemon.id)
            self.detail = detail
            selectedGame = defaultGame(for: detail)
            errorMessage = nil
        } catch {
            errorMessage = "Could not load details for \(pokemon.displayName)."
            AppDebugLog.log("Pokemon detail load failed for \(pokemon.id): \(error.localizedDescription)")
        }
    }

    func gameVersions(in generation: PokemonGameGeneration) -> [PokemonGameVersion] {
        PokemonGameVersion.versions(in: generation)
    }

    func selectGame(_ game: PokemonGameVersion) {
        selectedGame = game
    }

    private func defaultGame(for detail: PokeAPIPokemonDetail) -> PokemonGameVersion {
        PokemonGameVersion.all.first { game in
            detail.gameIndices.contains { game.pokeAPIVersionNames.contains($0.version.name) }
        } ?? PokemonGameVersion.all.last!
    }
}
