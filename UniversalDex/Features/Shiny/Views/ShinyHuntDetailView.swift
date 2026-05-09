//
//  ShinyHuntDetailView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 08/05/2026.
//

import SwiftUI

struct ShinyHuntDetailView: View {
    @ObservedObject var viewModel: ShinyHuntViewModel
    let huntID: ShinyHunt.ID
    @State private var cryPlaybackID = 0
    @State private var isPresentingEncounterEditor = false
    @State private var encounterDraftText = ""

    private var hunt: ShinyHunt? {
        viewModel.hunts.first { $0.id == huntID }
    }

    var body: some View {
        Group {
            if let hunt {
                huntDetail(hunt)
            } else {
                ContentUnavailableView {
                    Label("Hunt unavailable", systemImage: "sparkles")
                } description: {
                    Text("This shiny hunt could not be found.")
                }
            }
        }
        .background(AppTheme.screenBackground)
        .navigationTitle(hunt?.pokemonName ?? "Shiny Hunt")
        .sheet(isPresented: $isPresentingEncounterEditor) {
            if let hunt {
                encounterEditor(for: hunt)
            }
        }
        .onChange(of: encounterDraftText) { _, newValue in
            encounterDraftText = sanitizedNumberText(newValue)
        }
    }

    private func huntDetail(_ hunt: ShinyHunt) -> some View {
        ScrollView {
            VStack(spacing: 22) {
                pokemonStage(for: hunt)

                HStack(spacing: 12) {
                    ShinyMetricView(title: "Encounters", value: hunt.encounters.formatted())
                    ShinyMetricView(title: "Odds", value: hunt.oddsText)
                    ShinyMetricView(title: "Probability", value: hunt.cumulativeProbabilityText)
                }

                ProgressView(value: hunt.encounterProgress)
                    .tint(hunt.isCaught ? .green : AppTheme.accentColor)

                controls(for: hunt)

                if hunt.isCaught, let caughtAt = hunt.caughtAt {
                    Text("Caught after \(hunt.encounters.formatted()) encounters on \(caughtAt.formatted(date: .abbreviated, time: .omitted)).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else if hunt.encounters >= hunt.oddsDenominator {
                    Text("You are over odds. The hunt is still live.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                }
            }
            .padding(16)
            .overlay {
                ShinyPokemonCryPlayerView(
                    url: hunt.latestCryURL,
                    playbackID: cryPlaybackID
                )
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .allowsHitTesting(false)
            }
        }
    }

    private func pokemonStage(for hunt: ShinyHunt) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(hunt.isCaught ? Color.green.opacity(0.16) : AppTheme.accentColor.opacity(0.12))

                if hunt.shinySpriteURL != nil || hunt.animatedShinySpriteURL != nil {
                    ShinyPokemonArtworkView(
                        url: hunt.shinySpriteURL,
                        animatedURL: hunt.animatedShinySpriteURL
                    )
                    .padding(12)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundStyle(AppTheme.accentColor)
                }
            }
            .frame(width: 220, height: 220)

            VStack(spacing: 4) {
                Text(hunt.pokemonName)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                VStack(spacing: 2) {
                    Text(hunt.game.displayName)
                        .lineLimit(1)

                    Text(hunt.method.displayName)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                if let formattedPokemonNumber = hunt.formattedPokemonNumber {
                    Text("#\(formattedPokemonNumber)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                if hunt.latestCryURL != nil {
                    Button {
                        cryPlaybackID += 1
                    } label: {
                        Label("Cry", systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }

    private func controls(for hunt: ShinyHunt) -> some View {
        VStack(spacing: 12) {
            Button {
                viewModel.incrementEncounters(for: hunt)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 34, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 82)
            }
            .buttonStyle(.borderedProminent)
            .disabled(hunt.isCaught)
            .accessibilityLabel("Add encounter")

            HStack(spacing: 12) {
                Button {
                    viewModel.decrementEncounters(for: hunt)
                } label: {
                    huntControlIcon(systemImage: "minus")
                }
                .buttonStyle(.bordered)
                .disabled(hunt.encounters == 0)
                .accessibilityLabel("Undo encounter")

                Button {
                    encounterDraftText = hunt.encounters.formatted(.number.grouping(.never))
                    isPresentingEncounterEditor = true
                } label: {
                    huntControlIcon(systemImage: "number.square")
                }
                .buttonStyle(.bordered)
                .disabled(hunt.isCaught)
                .accessibilityLabel("Set encounter count")

                Button {
                    if hunt.isCaught {
                        viewModel.reopen(hunt)
                    } else {
                        viewModel.markCaught(hunt)
                    }
                } label: {
                    huntControlIcon(systemImage: hunt.isCaught ? "arrow.uturn.backward" : "checkmark.seal")
                }
                .buttonStyle(.bordered)
                .tint(hunt.isCaught ? .orange : .green)
                .accessibilityLabel(hunt.isCaught ? "Reopen hunt" : "Mark as caught")
            }
            .controlSize(.large)
        }
    }

    private func huntControlIcon(systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(.title3.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
    }

    private func encounterEditor(for hunt: ShinyHunt) -> some View {
        NavigationStack {
            Form {
                Section("Encounter Count") {
                    TextField("Encounters", text: $encounterDraftText)
                        .keyboardType(.numberPad)

                    LabeledContent("Current", value: hunt.encounters.formatted())
                }
            }
            .navigationTitle("Set Count")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresentingEncounterEditor = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.setEncounters(for: hunt, to: Int(encounterDraftText) ?? 0)
                        isPresentingEncounterEditor = false
                    }
                }
            }
        }
        .presentationDetents([.height(220)])
    }

    private func sanitizedNumberText(_ text: String) -> String {
        let digits = text.filter(\.isNumber)
        let trimmedDigits = String(digits.prefix(6))

        if trimmedDigits == text {
            return text
        }

        return trimmedDigits
    }
}

struct ShinyHuntDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShinyHuntDetailView(
                viewModel: ShinyHuntViewModel(),
                huntID: UUID()
            )
        }
    }
}
