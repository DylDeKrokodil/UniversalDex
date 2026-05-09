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
                        Text(hunt.pokemonName)
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)

                        if hunt.isCaught {
                            Label("Caught", systemImage: "checkmark.seal.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.green)
                                .labelStyle(.titleAndIcon)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
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
                ShinyMetricView(title: "Count", value: hunt.encounters.formatted())
                ShinyMetricView(title: "Odds", value: hunt.oddsText)
                ShinyMetricView(title: "Chance", value: hunt.cumulativeProbabilityText)
            }

            ProgressView(value: hunt.encounterProgress)
                .tint(hunt.isCaught ? .green : AppTheme.accentColor)

            if hunt.isCaught, let caughtAt = hunt.caughtAt {
                Text("Caught after \(hunt.encounters.formatted()) encounters on \(caughtAt.formatted(date: .abbreviated, time: .omitted)).")
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

            if let shinySpriteURL = hunt.shinySpriteURL {
                ShinyPokemonArtworkView(url: shinySpriteURL)
                .padding(4)
            } else {
                Image(systemName: hunt.isCaught ? "sparkles.rectangle.stack.fill" : "sparkles")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(hunt.isCaught ? .green : AppTheme.accentColor)
            }
        }
        .frame(width: 86, height: 86)
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
