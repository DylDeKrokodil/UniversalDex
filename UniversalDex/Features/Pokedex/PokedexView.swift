//
//  PokedexView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokedexView: View {
    @StateObject private var viewModel = PokedexViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasLoadedPokemon {
                    pokemonList
                } else if viewModel.isLoadingPage {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    unavailableView
                }
            }
            .navigationTitle(AppTab.pokedex.title)
            .task {
                await viewModel.loadInitialPokemonIfNeeded()
            }
        }
    }

    private var pokemonList: some View {
        List {
            ForEach(viewModel.pokemon) { pokemon in
                PokemonListRow(pokemon: pokemon)
                    .task {
                        await viewModel.loadMoreIfNeeded(currentItem: pokemon)
                    }
            }

            if viewModel.isLoadingPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task {
                            await viewModel.retry()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.reloadPokemon()
        }
    }

    private var unavailableView: some View {
        ContentUnavailableView {
            Label("Pokedex unavailable", systemImage: "wifi.exclamationmark")
        } description: {
            Text(viewModel.errorMessage ?? "Pokemon could not be loaded.")
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
        }
    }
}

struct PokedexView_Previews: PreviewProvider {
    static var previews: some View {
        PokedexView()
    }
}
