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
            gamePicker
            .navigationTitle("Select Game")
            .navigationDestination(for: NewShinyHuntStep.self) { step in
                switch step {
                case .pokemon:
                    pokemonPicker
                case .method:
                    methodPicker
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
                        selectedPokemon = nil
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
                TextField("Search Pokemon", text: $pokemonPickerViewModel.searchText)
            }

            Section("Pokemon Available in \(selectedGame.displayName)") {
                if pokemonPickerViewModel.isLoading {
                    ProgressView("Loading Pokemon...")
                } else if let errorMessage = pokemonPickerViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if availablePokemon.isEmpty {
                    ContentUnavailableView.search(text: pokemonPickerViewModel.searchText)
                } else {
                    ForEach(availablePokemon) { pokemon in
                        Button {
                            selectedPokemon = pokemon
                            path.append(.method)
                        } label: {
                            ShinyPokemonPickerRow(pokemon: pokemon)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Select Pokemon")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var methodPicker: some View {
        List {
            if let selectedPokemon {
                Section("Pokemon") {
                    ShinyPokemonPickerRow(pokemon: selectedPokemon)
                }
            }

            Section("Methods for \(selectedGame.displayName)") {
                ForEach(availableMethods) { method in
                    Button {
                        createHunt(with: method)
                    } label: {
                        ShinyMethodPickerRow(
                            method: method,
                            oddsText: method.oddsText(in: selectedGame),
                            note: method.note(in: selectedGame)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Select Method")
        .navigationBarTitleDisplayMode(.inline)
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

private struct ShinyMethodPickerRow: View {
    let method: ShinyMethod
    let oddsText: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(method.displayName)
                    .foregroundStyle(.primary)

                Spacer()

                Text(oddsText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accentColor)
            }

            Text(note)
                .font(.caption)
                .foregroundStyle(.secondary)
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
