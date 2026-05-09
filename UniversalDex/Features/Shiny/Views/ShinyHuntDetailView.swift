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
    @State private var isPresentingCompletion = false
    @State private var completionNickname = ""
    @State private var completionBall = ShinyCaughtBall.poke
    @State private var completionElapsedTime: TimeInterval = 0
    @State private var completionCaughtAt = Date()
    @State private var completionIsFailed = false

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
        .navigationTitle(hunt?.displayTitle ?? "Shiny Hunt")
        .sheet(isPresented: $isPresentingCompletion) {
            if let hunt {
                completionEditor(for: hunt)
            }
        }
        .onDisappear {
            if let hunt, hunt.isTimerRunning, !isPresentingCompletion {
                viewModel.stopTimer(for: hunt)
            }
        }
    }

    private func huntDetail(_ hunt: ShinyHunt) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                pokemonStage(for: hunt)

                controls(for: hunt)

                metrics(for: hunt)

                if hunt.trackingMetric.tracksEncounters {
                    ProgressView(value: hunt.encounterProgress)
                        .tint(hunt.isCaught ? (hunt.isFailed ? .orange : .green) : AppTheme.accentColor)
                }

                if let completion = hunt.completion {
                    Text(completionSummary(completion, for: hunt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else if hunt.startedAt == nil {
                    Text("This hunt has not started yet.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                } else if hunt.encounters >= hunt.oddsDenominator {
                    Text("You are over odds. The hunt is still live.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(hunt.isCaught ? Color.green.opacity(0.16) : AppTheme.accentColor.opacity(0.12))

                if !hunt.detailShinySpriteURLs.isEmpty {
                    ShinyPokemonArtworkView(sourceURLs: hunt.detailShinySpriteURLs)
                    .padding(30)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 72, weight: .semibold))
                        .foregroundStyle(AppTheme.accentColor)
                }

                if hunt.latestCryURL != nil {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.accentColor)
                        .padding(8)
                        .background(.thinMaterial, in: Circle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(14)
                }
            }
            .frame(width: 184, height: 184)
            .contentShape(Circle())
            .onTapGesture {
                guard hunt.latestCryURL != nil else {
                    return
                }

                cryPlaybackID += 1
            }
            .accessibilityHint(hunt.latestCryURL == nil ? Text("") : Text("Plays the Pokemon cry"))

            VStack(spacing: 4) {
                Text(hunt.pokemonName)
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)

                metadataLine(for: hunt)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private func metadataLine(for hunt: ShinyHunt) -> some View {
        let metadata = [
            hunt.game.displayName,
            hunt.method.dashboardLabel,
            hunt.formattedPokemonNumber.map { "#\($0)" },
        ].compactMap { $0 }

        return Text(metadata.joined(separator: " · "))
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .monospacedDigit()
            .multilineTextAlignment(.center)
    }

    private func metrics(for hunt: ShinyHunt) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if hunt.trackingMetric.tracksEncounters {
                    ShinyMetricView(title: "Encounters", value: hunt.encounters.formatted())
                }

                if hunt.trackingMetric.tracksTime {
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        ShinyMetricView(title: "Time", value: hunt.formattedElapsedTime)
                    }
                }

                ShinyMetricView(title: "Odds", value: hunt.oddsText)
            }

            if hunt.trackingMetric.tracksEncounters {
                HStack(spacing: 12) {
                    ShinyMetricView(title: "Chance", value: hunt.cumulativeProbabilityText)
                    ShinyMetricView(title: "Increment", value: "+\(hunt.encounterIncrement.formatted())")
                }
            }

            if hunt.trackingMetric.tracksEncounters && hunt.trackingMetric.tracksTime {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    ShinyMetricView(title: "Encounters/hour", value: hunt.formattedEncountersPerHour)
                }
            }
        }
    }

    private func controls(for hunt: ShinyHunt) -> some View {
        VStack(spacing: 12) {
            if hunt.trackingMetric.tracksEncounters {
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
            }

            if hunt.trackingMetric.tracksTime {
                Button {
                    if hunt.isTimerRunning {
                        viewModel.stopTimer(for: hunt)
                    } else {
                        viewModel.startTimer(for: hunt)
                    }
                } label: {
                    Label(hunt.isTimerRunning ? "Stop Time" : "Start Time", systemImage: hunt.isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                }
                .buttonStyle(.borderedProminent)
                .tint(hunt.isTimerRunning ? .orange : AppTheme.accentColor)
                .disabled(hunt.isCaught)
            }

            HStack(spacing: 12) {
                if hunt.trackingMetric.tracksEncounters {
                    Button {
                        viewModel.decrementEncounters(for: hunt)
                    } label: {
                        huntControlIcon(systemImage: "minus")
                    }
                    .buttonStyle(.bordered)
                    .disabled(hunt.encounters == 0 || hunt.isCaught)
                    .accessibilityLabel("Undo encounter")
                }

                Button {
                    if hunt.isCaught {
                        viewModel.reopen(hunt)
                    } else {
                        presentCompletion(for: hunt)
                    }
                } label: {
                    huntControlIcon(systemImage: hunt.isCaught ? "arrow.uturn.backward" : "checkmark.seal")
                }
                .buttonStyle(.bordered)
                .tint(hunt.isCaught ? .orange : .green)
                .disabled(!hunt.isCaught && hunt.startedAt == nil)
                .accessibilityLabel(hunt.isCaught ? "Reopen hunt" : "Complete hunt")
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

    private func completionEditor(for hunt: ShinyHunt) -> some View {
        NavigationStack {
            Form {
                Section("Add Pokemon") {
                    TextField("Nickname", text: $completionNickname)
                        .textInputAutocapitalization(.words)

                    Picker("Ball", selection: $completionBall) {
                        ForEach(ShinyCaughtBall.allCases) { ball in
                            Text(ball.displayName).tag(ball)
                        }
                    }
                }

                Section("Result") {
                    if hunt.trackingMetric.tracksEncounters {
                        LabeledContent("Encounters", value: hunt.encounters.formatted())
                    }

                    if hunt.trackingMetric.tracksTime {
                        TimelineView(.periodic(from: .now, by: 1)) { _ in
                            LabeledContent(
                                "Time",
                                value: ShinyHunt.formattedDuration(resolvedCompletionElapsedTime(for: hunt))
                            )
                        }
                    }

                    DatePicker("Date caught", selection: $completionCaughtAt, displayedComponents: .date)

                    Toggle("Failed", isOn: $completionIsFailed)
                }
            }
            .navigationTitle("Complete Hunt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresentingCompletion = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveCompletion(for: hunt)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func presentCompletion(for hunt: ShinyHunt) {
        completionNickname = hunt.completion?.nickname ?? ""
        completionBall = hunt.completion?.ball ?? .poke
        completionElapsedTime = hunt.totalElapsedTime
        completionCaughtAt = hunt.completion?.caughtAt ?? Date()
        completionIsFailed = hunt.completion?.isFailed ?? false
        isPresentingCompletion = true
    }

    private func saveCompletion(for hunt: ShinyHunt) {
        let completion = ShinyHunt.Completion(
            nickname: completionNickname.trimmingCharacters(in: .whitespacesAndNewlines),
            ball: completionBall,
            encounters: hunt.encounters,
            elapsedTime: resolvedCompletionElapsedTime(for: hunt),
            caughtAt: completionCaughtAt,
            isFailed: completionIsFailed
        )

        viewModel.complete(hunt, completion: completion)
        isPresentingCompletion = false
    }

    private func resolvedCompletionElapsedTime(for hunt: ShinyHunt) -> TimeInterval {
        max(completionElapsedTime, hunt.totalElapsedTime)
    }

    private func completionSummary(_ completion: ShinyHunt.Completion, for hunt: ShinyHunt) -> String {
        let status = completion.isFailed ? "Failed" : "Added"
        let dateText = completion.caughtAt.formatted(date: .abbreviated, time: .omitted)
        let resultText: String

        if hunt.trackingMetric.tracksEncounters && hunt.trackingMetric.tracksTime {
            resultText = "\(completion.encounters.formatted()) encounters and \(ShinyHunt.formattedDuration(completion.elapsedTime))"
        } else if hunt.trackingMetric.tracksTime {
            resultText = ShinyHunt.formattedDuration(completion.elapsedTime)
        } else {
            resultText = "\(completion.encounters.formatted()) encounters"
        }

        return "\(status) \(completion.displayName) in a \(completion.ball.displayName) after \(resultText) on \(dateText)."
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
