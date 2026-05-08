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
    @State private var selectedGame = ShinyGame.scarletViolet
    @State private var path: [NewShinyHuntStep] = []

    let addAction: (ShinyHunt) -> Void

    private var regionalPokemon: [PokemonListItem] {
        pokemonPickerViewModel.filteredPokemon(for: selectedGame)
    }

    var body: some View {
        NavigationStack(path: $path) {
            gamePicker
            .navigationTitle("Select Game")
            .navigationDestination(for: NewShinyHuntStep.self) { step in
                switch step {
                case .pokemon:
                    pokemonPicker
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

    private var gamePicker: some View {
        List {
            Section {
                ForEach(ShinyGame.allCases) { game in
                    Button {
                        selectedGame = game
                        pokemonPickerViewModel.searchText = ""
                        path.append(.pokemon)
                    } label: {
                        ShinyGamePickerRow(game: game)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var pokemonPicker: some View {
        List {
            Section {
                TextField("Search \(selectedGame.regionName) Pokemon", text: $pokemonPickerViewModel.searchText)
            }

            Section("\(selectedGame.regionName) Pokemon") {
                if pokemonPickerViewModel.isLoading {
                    ProgressView("Loading Pokemon...")
                } else if let errorMessage = pokemonPickerViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if regionalPokemon.isEmpty {
                    ContentUnavailableView.search(text: pokemonPickerViewModel.searchText)
                } else {
                    ForEach(regionalPokemon) { pokemon in
                        Button {
                            createHunt(for: pokemon)
                        } label: {
                            ShinyPokemonPickerRow(pokemon: pokemon)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle(selectedGame.regionName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createHunt(for pokemon: PokemonListItem) {
        addAction(
            ShinyHunt(
                pokemonID: pokemon.id,
                pokemonName: pokemon.displayName,
                game: selectedGame,
                method: .randomEncounter,
                oddsDenominator: ShinyMethod.randomEncounter.oddsDenominator(in: selectedGame),
                encounters: 0
            )
        )
        dismiss()
    }
}

private enum NewShinyHuntStep: Hashable {
    case pokemon
}

private struct ShinyGamePickerRow: View {
    let game: ShinyGame

    var body: some View {
        HStack(spacing: 12) {
            ShinyGameIconView(game: game)

            VStack(alignment: .leading, spacing: 3) {
                Text(game.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(game.regionName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

private struct ShinyPokemonPickerRow: View {
    let pokemon: PokemonListItem

    var body: some View {
        HStack(spacing: 12) {
            ShinyPokemonArtworkView(url: pokemon.artworkURL)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(pokemon.displayName)
                    .foregroundStyle(.primary)

                Text("#\(pokemon.formattedNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

struct NewShinyHuntView_Previews: PreviewProvider {
    static var previews: some View {
        NewShinyHuntView { _ in }
    }
}
