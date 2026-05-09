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
    @FocusState private var focusedField: Field?
    @State private var huntName = ""
    @State private var selectedGame = ShinyGame.scarlet
    @State private var selectedMethod = ShinyMethod.randomEncounter
    @State private var selectedPokemon: PokemonListItem?
    @State private var hasShinyCharm = false
    @State private var trackingMetric = ShinyTrackingMetric.encounters
    @State private var startingEncounterText = "0"
    @State private var startingHoursText = "0"
    @State private var startingMinutesText = "0"
    @State private var startingSecondsText = "0"
    @State private var encounterIncrementText = "1"

    let addAction: (ShinyHunt) -> Void

    private var availablePokemon: [PokemonListItem] {
        pokemonPickerViewModel.filteredPokemon(for: selectedGame)
    }

    private var filteredPokemon: [PokemonListItem] {
        Array(availablePokemon.prefix(24))
    }

    private var availableMethods: [ShinyMethod] {
        ShinyMethod.allCases.filter { method in
            ![.shinyCharm, .masudaCharm].contains(method) && method.isAvailable(in: selectedGame)
        }
    }

    private var oddsDenominator: Int {
        selectedMethod.oddsDenominator(in: selectedGame, hasShinyCharm: hasShinyCharm)
    }

    private var canCreateHunt: Bool {
        selectedPokemon != nil && !huntName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private enum Field: Hashable {
        case huntName
        case targetPokemon
        case startingEncounter
        case startingHours
        case startingMinutes
        case startingSeconds
        case encounterIncrement
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Hunt") {
                    TextField("Hunt name", text: $huntName)
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .huntName)

                    targetPokemonPicker
                }

                Section("Setup") {
                    NavigationLink {
                        ShinyGamePickerList { game in
                            selectGame(game)
                        }
                        .navigationTitle("Select Game")
                    } label: {
                        LabeledContent("Game", value: selectedGame.displayName)
                    }

                    NavigationLink {
                        ShinyMethodPickerList(
                            selectedGame: selectedGame,
                            selectedPokemon: selectedPokemon,
                            methods: availableMethods,
                            hasShinyCharm: hasShinyCharm
                        ) { method in
                            selectedMethod = method
                        }
                    } label: {
                        LabeledContent("Method", value: selectedMethod.displayName)
                    }

                    if selectedGame.supportsShinyCharm {
                        Toggle("Shiny Charm", isOn: $hasShinyCharm)
                    }

                    LabeledContent("Odds", value: "1/\(oddsDenominator.formatted())")
                }

                Section {
                    Picker("Tracking metric", selection: $trackingMetric) {
                        ForEach(ShinyTrackingMetric.allCases) { metric in
                            Text(metric.displayName).tag(metric)
                        }
                    }

                    if trackingMetric.tracksEncounters {
                        TextField("Starting encounter", text: $startingEncounterText)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .startingEncounter)

                        TextField("Increment by", text: $encounterIncrementText)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .encounterIncrement)
                    }

                    if trackingMetric.tracksTime {
                        LabeledContent("Starting time") {
                            HStack(spacing: 8) {
                                durationField("Hours", text: $startingHoursText, suffix: "h", field: .startingHours)
                                durationField("Minutes", text: $startingMinutesText, suffix: "m", field: .startingMinutes)
                                durationField("Seconds", text: $startingSecondsText, suffix: "s", field: .startingSeconds)
                            }
                        }
                    }
                } header: {
                    Text("Tracking")
                } footer: {
                    Text("Set a starting time if this hunt already has tracked time. The timer starts on the first encounter or when you start time tracking.")
                }
            }
            .navigationTitle("New Hunt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createHunt()
                    }
                    .disabled(!canCreateHunt)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .task {
                await pokemonPickerViewModel.loadPokemonIfNeeded()
            }
            .onChange(of: pokemonPickerViewModel.searchText) { _, newValue in
                if selectedPokemon?.displayName != newValue {
                    selectedPokemon = nil
                }
            }
            .onChange(of: startingEncounterText) { _, newValue in
                startingEncounterText = sanitizedNumberText(newValue, fallback: "0")
            }
            .onChange(of: encounterIncrementText) { _, newValue in
                encounterIncrementText = sanitizedNumberText(newValue, fallback: "1")
            }
            .onChange(of: startingHoursText) { _, newValue in
                startingHoursText = sanitizedNumberText(newValue, fallback: "0")
            }
            .onChange(of: startingMinutesText) { _, newValue in
                startingMinutesText = sanitizedDurationComponentText(newValue)
            }
            .onChange(of: startingSecondsText) { _, newValue in
                startingSecondsText = sanitizedDurationComponentText(newValue)
            }
            .onChange(of: trackingMetric) { _, newMetric in
                if !newMetric.tracksEncounters {
                    startingEncounterText = "0"
                    encounterIncrementText = "1"
                }

                if !newMetric.tracksTime {
                    startingHoursText = "0"
                    startingMinutesText = "0"
                    startingSecondsText = "0"
                }
            }
        }
    }

    private var targetPokemonPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Target Pokemon", text: $pokemonPickerViewModel.searchText)
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .targetPokemon)

            if let selectedPokemon {
                selectedPokemonRow(selectedPokemon)
            } else if pokemonPickerViewModel.isLoading {
                ProgressView("Loading Pokemon...")
                    .font(.footnote)
            } else if let errorMessage = pokemonPickerViewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if !pokemonPickerViewModel.searchText.isEmpty {
                ForEach(filteredPokemon) { pokemon in
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

    private func selectedPokemonRow(_ pokemon: PokemonListItem) -> some View {
        HStack {
            ShinyPokemonPickerRow(pokemon: pokemon, showsChevron: false)

            Button {
                selectedPokemon = nil
                pokemonPickerViewModel.searchText = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear target Pokemon")
        }
    }

    private func durationField(
        _ label: String,
        text: Binding<String>,
        suffix: String,
        field: Field
    ) -> some View {
        HStack(spacing: 2) {
            TextField(label, text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: field)
                .frame(minWidth: 28, maxWidth: 44)

            Text(suffix)
                .foregroundStyle(.secondary)
        }
    }

    private func selectGame(_ game: ShinyGame) {
        selectedGame = game
        if !selectedGame.supportsShinyCharm {
            hasShinyCharm = false
        }

        if let selectedPokemon, !selectedGame.containsAvailablePokemon(selectedPokemon) {
            self.selectedPokemon = nil
            pokemonPickerViewModel.searchText = ""
        }

        if !selectedMethod.isAvailable(in: selectedGame) {
            selectedMethod = availableMethods.first ?? .randomEncounter
        }
    }

    private func selectPokemon(_ pokemon: PokemonListItem) {
        selectedPokemon = pokemon
        pokemonPickerViewModel.searchText = pokemon.displayName
        if huntName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            huntName = "\(pokemon.displayName) hunt"
        }
    }

    private func createHunt() {
        guard let selectedPokemon else {
            return
        }

        addAction(
            ShinyHunt(
                pokemonID: selectedPokemon.displayID,
                pokemonFormID: selectedPokemon.id == selectedPokemon.displayID ? nil : selectedPokemon.id,
                pokemonName: selectedPokemon.displayName,
                huntName: huntName.trimmingCharacters(in: .whitespacesAndNewlines),
                game: selectedGame,
                method: selectedMethod,
                trackingMetric: trackingMetric,
                hasShinyCharm: hasShinyCharm,
                oddsDenominator: oddsDenominator,
                encounters: trackingMetric.tracksEncounters ? Int(startingEncounterText) ?? 0 : 0,
                encounterIncrement: trackingMetric.tracksEncounters ? Int(encounterIncrementText) ?? 1 : 1,
                elapsedTime: trackingMetric.tracksTime ? startingElapsedTime : 0
            )
        )
        dismiss()
    }

    private var startingElapsedTime: TimeInterval {
        let hours = Int(startingHoursText) ?? 0
        let minutes = Int(startingMinutesText) ?? 0
        let seconds = Int(startingSecondsText) ?? 0

        return TimeInterval((hours * 3_600) + (minutes * 60) + seconds)
    }

    private func sanitizedNumberText(_ text: String, fallback: String) -> String {
        let digits = text.filter(\.isNumber)
        let trimmedDigits = String(digits.prefix(6))

        if trimmedDigits.isEmpty {
            return fallback
        }

        return trimmedDigits
    }

    private func sanitizedDurationComponentText(_ text: String) -> String {
        let sanitizedText = sanitizedNumberText(text, fallback: "0")
        let component = min(Int(sanitizedText) ?? 0, 59)
        return component.formatted()
    }
}

struct NewShinyHuntView_Previews: PreviewProvider {
    static var previews: some View {
        NewShinyHuntView { _ in }
    }
}
