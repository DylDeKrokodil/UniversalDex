//
//  ShinyPokemonPickerList.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct ShinyPokemonPickerList: View {
    let selectedGame: ShinyGame
    @Binding var searchText: String
    let pokemon: [PokemonListItem]
    let isLoading: Bool
    let errorMessage: String?
    let selectPokemon: (PokemonListItem) -> Void

    var body: some View {
        List {
            Section {
                TextField("Search Pokemon", text: $searchText)
            }

            Section("Pokemon Available in \(selectedGame.displayName)") {
                if isLoading {
                    ProgressView("Loading Pokemon...")
                } else if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else if pokemon.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(pokemon) { pokemon in
                        Button {
                            selectPokemon(pokemon)
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
}

struct ShinyPokemonPickerRow: View {
    let pokemon: PokemonListItem
    var showsChevron = true

    var body: some View {
        HStack(spacing: 12) {
            PokemonImageView(urls: pokemon.artworkNonShinyURLs)
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(pokemon.displayName)
                    .foregroundStyle(.primary)

                Text("#\(pokemon.formattedNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if showsChevron {
                ShinyPickerChevron()
            }
        }
        .contentShape(Rectangle())
    }
}
