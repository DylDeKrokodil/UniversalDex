//
//  ShinyHuntCard.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct ShinyHuntCard: View {
    let hunt: ShinyHunt

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                pokemonArtwork

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(hunt.displayTitle)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        if hunt.isCaught {
                            Label(hunt.isFailed ? "Failed" : "Added", systemImage: hunt.isFailed ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(hunt.isFailed ? .orange : .green)
                                .labelStyle(.titleAndIcon)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        if hunt.displayTitle != hunt.pokemonName {
                            Text(hunt.pokemonName)
                                .lineLimit(1)
                        }

                        Text(hunt.game.displayName)
                            .lineLimit(1)

                        Text(hunt.method.displayName)
                            .lineLimit(2)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    if let formattedPokemonNumber = hunt.formattedPokemonNumber {
                        Text("#\(formattedPokemonNumber)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 12) {
                if hunt.trackingMetric.tracksEncounters {
                    ShinyMetricView(title: "Count", value: hunt.encounters.formatted())
                }

                if hunt.trackingMetric.tracksTime {
                    ShinyMetricView(title: "Time", value: hunt.formattedElapsedTime)
                }

                ShinyMetricView(title: "Odds", value: hunt.oddsText)
            }

            if hunt.trackingMetric.tracksEncounters && hunt.trackingMetric.tracksTime {
                ShinyMetricView(title: "Encounters/hour", value: hunt.formattedEncountersPerHour)
            }

            if hunt.trackingMetric.tracksEncounters {
                ProgressView(value: hunt.encounterProgress)
                    .tint(hunt.isCaught ? (hunt.isFailed ? .orange : .green) : AppTheme.accentColor)
            }

            if let completion = hunt.completion {
                Text(cardCompletionSummary(completion, for: hunt))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if hunt.startedAt == nil {
                Text("Not started yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else if hunt.encounters >= hunt.oddsDenominator {
                Text("You are over odds. The hunt is still live.")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.orange)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
    }

    private var pokemonArtwork: some View {
        ZStack {
            Circle()
                .fill(hunt.isCaught ? Color.green.opacity(0.18) : AppTheme.accentColor.opacity(0.14))

            if let homeShinySpriteURL = hunt.homeShinySpriteURL {
                ShinyPokemonArtworkView(url: homeShinySpriteURL, fallbackURL: hunt.gameShinySpriteURL)
                .padding(4)
            } else {
                Image(systemName: hunt.isCaught ? "sparkles.rectangle.stack.fill" : "sparkles")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(hunt.isCaught ? .green : AppTheme.accentColor)
            }
        }
        .frame(width: 86, height: 86)
    }

    private func cardCompletionSummary(_ completion: ShinyHunt.Completion, for hunt: ShinyHunt) -> String {
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

        return "\(status) after \(resultText) on \(dateText)."
    }
}

struct ShinyHuntCard_Previews: PreviewProvider {
    static var previews: some View {
        ShinyHuntCard(
            hunt: ShinyHunt(
                pokemonID: 25,
                pokemonName: "Pikachu",
                game: .scarlet,
                method: .sandwichCharmOutbreak,
                oddsDenominator: 512,
                encounters: 128
            )
        )
        .padding()
        .background(AppTheme.screenBackground)
    }
}
