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
    @Published private(set) var species: PokeAPIPokemonSpecies?
    @Published private(set) var evolutionChain: PokeAPIEvolutionChain?
    @Published private(set) var encounters: [PokemonEncounter] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var selectedGame: PokemonGameVersion?

    private let pokemon: PokemonListItem
    private let apiClient: PokeAPIClient

    var title: String {
        pokemon.displayName
    }

    var formattedPokemonNumber: String {
        pokemon.formattedNumber
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

    var selectedPokedexEntry: String? {
        let englishEntries = species?.flavorTextEntries.filter { $0.language.name == "en" } ?? []

        if let selectedGame,
           let gameEntry = englishEntries.first(where: { selectedGame.pokeAPIVersionNames.contains($0.version.name) }) {
            return gameEntry.cleanedFlavorText
        }

        return englishEntries.last?.cleanedFlavorText
    }

    var evolutionStages: [PokemonEvolutionStage] {
        guard let evolutionChain else {
            return []
        }

        return flattenedEvolutionStages(from: evolutionChain.chain)
    }

    var selectedEncounterLocations: [PokemonEncounterLocation] {
        guard let selectedGame else {
            return []
        }

        return encounters.compactMap { encounter in
            guard let versionDetail = encounter.versionDetails.first(where: { selectedGame.pokeAPIVersionNames.contains($0.version.name) }) else {
                return nil
            }

            let details = versionDetail.encounterDetails
                .sorted { first, second in
                    if first.method.name == second.method.name {
                        return first.minLevel < second.minLevel
                    }

                    return first.method.name < second.method.name
                }
                .map { detail in
                    PokemonEncounterMethod(
                        method: detail.method.displayName,
                        chance: detail.chance,
                        levelRange: detail.minLevel == detail.maxLevel
                            ? "Lv. \(detail.minLevel)"
                            : "Lv. \(detail.minLevel)-\(detail.maxLevel)"
                    )
                }

            return PokemonEncounterLocation(
                name: encounter.locationArea.displayName,
                maxChance: versionDetail.maxChance,
                methods: details
            )
        }
        .sorted { $0.name < $1.name }
    }

    var selectedMoves: [PokemonMoveDisplay] {
        guard let selectedGame, let moves = detail?.moves else {
            return []
        }

        return moves.compactMap { move in
            guard let versionGroupDetail = move.versionGroupDetails.first(where: {
                selectedGame.pokeAPIVersionGroupNames.contains($0.versionGroup.name)
            }) else {
                return nil
            }

            return PokemonMoveDisplay(
                name: move.move.displayName,
                learnMethod: versionGroupDetail.moveLearnMethod.displayName,
                level: versionGroupDetail.levelLearnedAt
            )
        }
        .sorted { first, second in
            if first.learnMethod == second.learnMethod {
                if first.level == second.level {
                    return first.name < second.name
                }

                return first.level < second.level
            }

            return first.learnMethod < second.learnMethod
        }
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
            return
        }

        do {
            species = try await apiClient.fetchPokemonSpecies(id: pokemon.displayID)
        } catch {
            AppDebugLog.log("Pokemon species load failed for \(pokemon.displayID): \(error.localizedDescription)")
            return
        }

        await loadSupplementalDetail()
    }

    private func loadSupplementalDetail() async {
        await loadEvolutionChain()
        await loadEncounters()
    }

    private func loadEvolutionChain() async {
        guard let species else {
            return
        }

        do {
            evolutionChain = try await apiClient.fetchEvolutionChain(url: species.evolutionChain.url)
        } catch {
            AppDebugLog.log("Pokemon evolution chain load failed for \(pokemon.id): \(error.localizedDescription)")
        }
    }

    private func loadEncounters() async {
        do {
            encounters = try await apiClient.fetchPokemonEncounters(id: pokemon.id)
        } catch {
            AppDebugLog.log("Pokemon encounters load failed for \(pokemon.id): \(error.localizedDescription)")
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

    private func flattenedEvolutionStages(
        from link: PokemonEvolutionChainLink,
        triggerText: String? = nil
    ) -> [PokemonEvolutionStage] {
        let currentStage = PokemonEvolutionStage(
            pokemon: PokemonListItem(resource: link.species),
            name: link.species.displayName,
            triggerText: triggerText
        )

        return [currentStage] + link.evolvesTo.flatMap { nextLink in
            flattenedEvolutionStages(
                from: nextLink,
                triggerText: evolutionTriggerText(from: nextLink.evolutionDetails.first)
            )
        }
    }

    private func evolutionTriggerText(from detail: PokemonEvolutionDetail?) -> String? {
        guard let detail else {
            return nil
        }

        if let minLevel = detail.minLevel {
            return "Lv. \(minLevel)"
        }

        if let item = detail.item {
            return item.displayName
        }

        return detail.trigger?.displayName
    }
}

struct PokemonEvolutionStage: Identifiable, Hashable {
    let pokemon: PokemonListItem?
    let name: String
    let triggerText: String?

    var id: String {
        pokemon.map { String($0.id) } ?? name
    }
}

struct PokemonEncounterLocation: Identifiable, Hashable {
    let name: String
    let maxChance: Int
    let methods: [PokemonEncounterMethod]

    var id: String {
        name
    }
}

struct PokemonEncounterMethod: Hashable {
    let method: String
    let chance: Int
    let levelRange: String
}

struct PokemonMoveDisplay: Identifiable, Hashable {
    let name: String
    let learnMethod: String
    let level: Int

    var id: String {
        "\(name)-\(learnMethod)-\(level)"
    }
}
