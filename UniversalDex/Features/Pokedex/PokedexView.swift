//
//  PokedexView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokedexView: View {
    @StateObject private var viewModel = PokedexViewModel()
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 3
    )

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
        ScrollView {
            PokedexFilterBar(
                selectedGeneration: $viewModel.selectedGeneration,
                sortOption: $viewModel.sortOption
            )

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.filteredPokemon) { pokemon in
                    PokemonGridCard(pokemon: pokemon)
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: pokemon)
                        }
                }

                if viewModel.filteredPokemon.isEmpty && viewModel.isHydratingAllPokemon {
                    ProgressView("Loading matching Pokemon...")
                        .gridCellColumns(3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else if viewModel.filteredPokemon.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                        .gridCellColumns(3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else if viewModel.isLoadingPage {
                    ProgressView()
                        .gridCellColumns(3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else if viewModel.isHydratingAllPokemon {
                    HStack(spacing: 8) {
                        ProgressView()

                        Text("Preparing full Pokedex...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .gridCellColumns(3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
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
                    .gridCellColumns(3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(AppTheme.screenBackground)
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
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
