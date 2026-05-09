//
//  NewShinyHuntView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct NewShinyHuntView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var pokemonPickerViewModel = ShinyPokemonPickerViewModel()
    @State private var selectedGame = ShinyGame.scarlet
    @State private var selectedPokemon: PokemonListItem?
    @State private var path: [NewShinyHuntStep] = []

    let addAction: (ShinyHunt) -> Void

    private var availablePokemon: [PokemonListItem] {
        pokemonPickerViewModel.filteredPokemon(for: selectedGame)
    }

    private var availableMethods: [ShinyMethod] {
        ShinyMethod.allCases.filter { method in
            method != .customOdds && method.isAvailable(in: selectedGame)
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ShinyGamePickerList { game in
                handleGameSelection(game)
            }
            .navigationTitle("Select Game")
            .navigationDestination(for: NewShinyHuntStep.self) { step in
                switch step {
                case .pokemon:
                    ShinyPokemonPickerList(
                        selectedGame: selectedGame,
                        searchText: $pokemonPickerViewModel.searchText,
                        pokemon: availablePokemon,
                        isLoading: pokemonPickerViewModel.isLoading,
                        errorMessage: pokemonPickerViewModel.errorMessage
                    ) { pokemon in
                        handlePokemonSelection(pokemon)
                    }
                case .method:
                    ShinyMethodPickerList(
                        selectedGame: selectedGame,
                        selectedPokemon: selectedPokemon,
                        methods: availableMethods
                    ) { method in
                        createHunt(with: method)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await pokemonPickerViewModel.loadPokemonIfNeeded()
            }
        }
    }

    private func handleGameSelection(_ game: ShinyGame) {
        selectedGame = game
        selectedPokemon = nil
        pokemonPickerViewModel.searchText = ""
        path.append(.pokemon)
    }

    private func handlePokemonSelection(_ pokemon: PokemonListItem) {
        selectedPokemon = pokemon
        path.append(.method)
    }

    private func createHunt(with method: ShinyMethod) {
        guard let selectedPokemon else {
            return
        }

        addAction(
            ShinyHunt(
                pokemonID: selectedPokemon.id,
                pokemonName: selectedPokemon.displayName,
                game: selectedGame,
                method: method,
                oddsDenominator: method.oddsDenominator(in: selectedGame),
                encounters: 0
            )
        )
        dismiss()
    }
}

private enum NewShinyHuntStep: Hashable {
    case pokemon
    case method
}

struct NewShinyHuntView_Previews: PreviewProvider {
    static var previews: some View {
        NewShinyHuntView { _ in }
    }
}
