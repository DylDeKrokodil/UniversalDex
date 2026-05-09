//
//  HomeView.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ShinyHuntViewModel
    @Binding var selectedTab: AppTab

    private var snapshot: HomeDashboardSnapshot {
        HomeDashboardSnapshot(hunts: viewModel.hunts)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.screenBackground
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        AppTheme.accentColor.opacity(0.16),
                        AppTheme.homeBackgroundBottom.opacity(0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if let featuredHunt = snapshot.featuredHunt {
                            activeHuntCard(featuredHunt)
                            statRow(featuredHunt)
                            paceCard(featuredHunt)
                        } else {
                            emptyStateCard
                        }

                        archiveCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(AppTab.home.title)
        }
    }

    private func activeHuntCard(_ hunt: HomeDashboardSnapshot.FeaturedHunt) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Active Hunt")
                        .font(.caption.weight(.semibold))
                        .tracking(5)
                        .textCase(.uppercase)
                        .foregroundStyle(AppTheme.homeMutedText)

                    Text(hunt.title)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 0)

                Text(hunt.methodLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.homeChipText)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(AppTheme.homeChipBackground, in: Capsule())
            }

            if hunt.secondaryActiveCount > 0 {
                Text("+\(hunt.secondaryActiveCount) more active \(hunt.secondaryActiveCount == 1 ? "hunt" : "hunts")")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppTheme.homeMutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private func statRow(_ hunt: HomeDashboardSnapshot.FeaturedHunt) -> some View {
        HStack(spacing: 14) {
            homeStatCard(
                title: "Encounters",
                value: hunt.encountersText,
                background: LinearGradient(
                    colors: [AppTheme.homeAccentStrong, AppTheme.homeAccent],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                valueColor: .white
            )

            homeStatCard(
                title: "Target Odds",
                value: hunt.oddsText,
                background: LinearGradient(
                    colors: [AppTheme.homeCardBackground, AppTheme.homeCardBackground],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                valueColor: AppTheme.homeOddsText
            )
        }
    }

    private func homeStatCard(
        title: String,
        value: String,
        background: LinearGradient,
        valueColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption.weight(.semibold))
                .tracking(4)
                .textCase(.uppercase)
                .foregroundStyle(title == "Encounters" ? Color.white.opacity(0.82) : AppTheme.homeMutedText)

            Spacer(minLength: 18)

            Text(value)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(valueColor)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .leading)
        .padding(22)
        .background(background, in: RoundedRectangle(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private func paceCard(_ hunt: HomeDashboardSnapshot.FeaturedHunt) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Session Pace")
                        .font(.caption.weight(.semibold))
                        .tracking(4)
                        .textCase(.uppercase)
                        .foregroundStyle(AppTheme.homeMutedText)

                    Text(hunt.paceHeadline)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 0)

                Text(hunt.todayEncountersText)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppTheme.homePositiveText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(AppTheme.homePositiveBackground, in: Capsule())
            }

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(hunt.dailyEncounters) { day in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.homeAccentStrong, AppTheme.homeAccentSoft],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: barHeight(for: day.encounters, in: hunt.dailyEncounters))

                        Text(day.date, format: .dateTime.weekday(.narrow))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.homeMutedText)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
            }
            .frame(height: 210, alignment: .bottom)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private var archiveCard: some View {
        Button {
            selectedTab = .shiny
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Caught archive")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)

                    Text("See completed hunts without losing today’s focus.")
                        .font(.body)
                        .foregroundStyle(AppTheme.homeMutedText)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 2) {
                    Text(snapshot.caughtArchiveCount.formatted())
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Color.primary.opacity(0.04), in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.homeArchiveBackground, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(
                        AppTheme.homeCardBorder,
                        style: StrokeStyle(lineWidth: 1, dash: [6, 6])
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Hunt")
                .font(.caption.weight(.semibold))
                .tracking(5)
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.homeMutedText)

            Text("No hunt in progress")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("Start a shiny hunt to unlock live encounter stats, odds, and pace trends here.")
                .font(.body)
                .foregroundStyle(AppTheme.homeMutedText)

            Button("Start a hunt") {
                selectedTab = .shiny
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.homeAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private func barHeight(
        for value: Int,
        in data: [ShinyEncounterDailyTotal]
    ) -> CGFloat {
        let maxValue = max(data.map(\.encounters).max() ?? 0, 1)
        let normalizedValue = CGFloat(value) / CGFloat(maxValue)
        return max(30, normalizedValue * 140)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: ShinyHuntViewModel(previewHunts: previewHunts),
            selectedTab: .constant(.home)
        )
    }

    private static var previewHunts: [ShinyHunt] {
        let now = Date()
        let calendar = Calendar.current
        let dailyDeltas = [12, 24, 16, 31, 26, 37, 42]

        var encounterEvents: [ShinyEncounterEvent] = []
        for (index, delta) in dailyDeltas.enumerated() {
            let offset = index - (dailyDeltas.count - 1)
            if let date = calendar.date(byAdding: .day, value: offset, to: now) {
                encounterEvents.append(
                    ShinyEncounterEvent(
                        recordedAt: date,
                        delta: delta,
                        kind: .increment
                    )
                )
            }
        }

        let activeHunt = ShinyHunt(
            pokemonID: 4,
            pokemonName: "Charmander",
            game: .scarlet,
            method: .masuda,
            oddsDenominator: 512,
            encounters: dailyDeltas.reduce(0, +),
            encounterEvents: encounterEvents
        )

        let caughtHunt = ShinyHunt(
            pokemonID: 25,
            pokemonName: "Pikachu",
            game: .letsGoPikachu,
            method: .catchCombo31,
            oddsDenominator: 341,
            encounters: 188,
            encounterEvents: [
                ShinyEncounterEvent(
                    recordedAt: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                    delta: 188,
                    kind: .adjustment
                )
            ],
            isCaught: true,
            createdAt: calendar.date(byAdding: .day, value: -8, to: now) ?? now,
            caughtAt: calendar.date(byAdding: .day, value: -1, to: now)
        )

        return [activeHunt, caughtHunt]
    }
}
