//
//  PokemonDetailView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel

    init(pokemon: PokemonListItem) {
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemon: pokemon))
    }

    var body: some View {
        ScrollView {
            Group {
                if let detail = viewModel.detail {
                    detailContent(detail)
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 280)
                } else {
                    unavailableView
                }
            }
            .padding(16)
        }
        .background(AppTheme.screenBackground)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                gameMenu
            }
        }
        .task {
            await viewModel.loadDetailIfNeeded()
        }
    }

    private func detailContent(_ detail: PokeAPIPokemonDetail) -> some View {
        VStack(spacing: 16) {
            hero(detail)

            if let selectedGame = viewModel.selectedGame {
                detailSection("Selected Game") {
                    detailRow("Game", selectedGame.displayName)
                    detailRow("Generation", selectedGame.generation.displayName)

                    if let selectedGameIndex = viewModel.selectedGameIndex {
                        detailRow("PokeAPI Game Index", String(selectedGameIndex.gameIndex))
                    } else {
                        detailRow("PokeAPI Game Index", "Not provided")
                    }
                }
            }

            detailSection("Profile") {
                detailRow("Number", String(format: "%03d", detail.id))
                detailRow("Height", String(format: "%.1f m", Double(detail.height) / 10))
                detailRow("Weight", String(format: "%.1f kg", Double(detail.weight) / 10))
                detailRow("Base XP", detail.baseExperience.map { String($0) } ?? "Unknown")
            }

            detailSection("Types") {
                tagFlow(detail.types.sorted { $0.slot < $1.slot }.map { $0.type.displayName })
            }

            detailSection("Abilities") {
                tagFlow(detail.abilities.sorted { $0.slot < $1.slot }.map { ability in
                    ability.isHidden ? "\(ability.ability.displayName) (Hidden)" : ability.ability.displayName
                })
            }

            detailSection("Base Stats") {
                ForEach(detail.stats, id: \.stat.name) { stat in
                    VStack(alignment: .leading, spacing: 6) {
                        detailRow(stat.stat.displayName, String(stat.baseStat))

                        ProgressView(value: Double(stat.baseStat), total: 255)
                            .tint(AppTheme.accentColor)
                    }
                }
            }
        }
    }

    private func hero(_ detail: PokeAPIPokemonDetail) -> some View {
        VStack(spacing: 12) {
            AsyncImage(url: detail.sprites.frontDefault ?? PokemonListItem(id: detail.id, name: detail.name).artworkURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180)

            Text(detail.name.displayName)
                .font(.title.bold())

            Text(String(format: "%03d", detail.id))
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private var gameMenu: some View {
        Menu {
            if viewModel.detail != nil {
                ForEach(PokemonGameGeneration.allCases) { generation in
                    Section(generation.displayName) {
                        ForEach(viewModel.gameVersions(in: generation)) { game in
                            Button {
                                viewModel.selectGame(game)
                            } label: {
                                if viewModel.selectedGame == game {
                                    Label(game.displayName, systemImage: "checkmark")
                                } else {
                                    Text(game.displayName)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No games available")
            }
        } label: {
            Image(systemName: "gamecontroller.fill")
        }
        .disabled(viewModel.detail == nil)
    }

    private var unavailableView: some View {
        ContentUnavailableView {
            Label("Details unavailable", systemImage: "wifi.exclamationmark")
        } description: {
            Text(viewModel.errorMessage ?? "Pokemon details could not be loaded.")
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadDetailIfNeeded()
                }
            }
        }
    }

    private func detailSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func tagFlow(_ tags: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

private extension String {
    var displayName: String {
        split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PokemonDetailView(pokemon: PokemonListItem(id: 25, name: "pikachu"))
        }
    }
}
