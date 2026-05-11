//
//  PokemonDetailView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokemonDetailView: View {
    @State private var selectedEvolution: PokemonListItem?
    @State private var selectedTab = PokemonDetailTab.info
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
        .navigationDestination(item: $selectedEvolution) { pokemon in
            PokemonDetailView(pokemon: pokemon)
        }
        .task {
            await viewModel.loadDetailIfNeeded()
        }
    }

    private func detailContent(_ detail: PokeAPIPokemonDetail) -> some View {
        VStack(spacing: 16) {
            hero(detail)

            detailTabs

            switch selectedTab {
            case .info:
                infoContent(detail)
            case .evolutions:
                evolutionsContent
            case .catch:
                catchContent
            case .moves:
                movesContent
            }
        }
    }

    private var detailTabs: some View {
        Picker("Detail Tab", selection: $selectedTab) {
            ForEach(PokemonDetailTab.allCases) { tab in
                Label(tab.title, systemImage: tab.systemImage)
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private func infoContent(_ detail: PokeAPIPokemonDetail) -> some View {
        Group {
            if let pokedexEntry = viewModel.selectedPokedexEntry {
                detailSection("Pokedex Entry") {
                    Text(pokedexEntry)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

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
                detailRow("Number", viewModel.formattedPokemonNumber)
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

    private var evolutionsContent: some View {
        detailSection("Evolutions") {
            let stages = viewModel.evolutionStages

            if stages.isEmpty {
                Text("Evolution data is not available yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        if index > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down")
                                Text(stage.triggerText ?? "Evolves")
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        }

                        evolutionStageRow(stage)
                    }
                }
            }
        }
    }

    private var catchContent: some View {
        detailSection("Catch") {
            let locations = viewModel.selectedEncounterLocations

            if locations.isEmpty {
                Text("No catch locations found for \(viewModel.selectedGameDisplayName).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(locations.prefix(20)) { location in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(location.name)
                                    .font(.subheadline.weight(.semibold))

                                Spacer()

                                Text("\(location.maxChance)%")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }

                            tagFlow(location.methods.prefix(4).map { method in
                                "\(method.method) \(method.levelRange)"
                            })
                        }
                        .padding(.vertical, 4)
                    }

                    if locations.count > 20 {
                        Text("+ \(locations.count - 20) more locations")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var movesContent: some View {
        detailSection("Moves") {
            let moves = viewModel.selectedMoves

            if moves.isEmpty {
                Text("No moves found for \(viewModel.selectedGameDisplayName).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(moves) { move in
                        HStack(spacing: 12) {
                            Text(move.level > 0 ? "Lv. \(move.level)" : move.learnMethod)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 88, alignment: .leading)

                            Text(move.name)
                                .font(.subheadline.weight(.semibold))

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func evolutionStageRow(_ stage: PokemonEvolutionStage) -> some View {
        if let pokemon = stage.pokemon {
            Button {
                selectedEvolution = pokemon
            } label: {
                evolutionStageRowContent(stage)
            }
            .buttonStyle(.plain)
        } else {
            evolutionStageRowContent(stage)
        }
    }

    private func evolutionStageRowContent(_ stage: PokemonEvolutionStage) -> some View {
        HStack(spacing: 12) {
            PokemonImageView(urls: stage.pokemon?.artworkURLs ?? [])
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(stage.name)
                    .font(.headline)

                if let number = stage.pokemon?.formattedNumber {
                    Text(number)
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if stage.pokemon != nil {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .contentShape(Rectangle())
        .background(AppTheme.screenBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private func hero(_ detail: PokeAPIPokemonDetail) -> some View {
        VStack(spacing: 12) {
            let pokemon = PokemonListItem(id: detail.id, name: detail.name)
            let spriteURL = detail.sprites.frontDefault
            let imageURLs = ([spriteURL].compactMap { $0 } + pokemon.artworkURLs)

            PokemonImageView(urls: imageURLs)
                .frame(height: 180)

            Text(detail.name.displayName)
                .font(.title.bold())

            Text(viewModel.formattedPokemonNumber)
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

private enum PokemonDetailTab: String, CaseIterable, Identifiable {
    case info
    case evolutions
    case `catch`
    case moves

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .info:
            return "Info"
        case .evolutions:
            return "Evolutions"
        case .catch:
            return "Catch"
        case .moves:
            return "Moves"
        }
    }

    var systemImage: String {
        switch self {
        case .info:
            return "info.circle"
        case .evolutions:
            return "arrow.triangle.branch"
        case .catch:
            return "mappin.and.ellipse"
        case .moves:
            return "bolt"
        }
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PokemonDetailView(pokemon: PokemonListItem(id: 25, name: "pikachu"))
        }
    }
}
