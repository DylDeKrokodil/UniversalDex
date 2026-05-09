//
//  HomeView.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ShinyHuntViewModel
    @Binding var selectedTab: AppTab
    @State private var selectedStatsHunt: HomeDashboardSnapshot.FeaturedHunt?

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
            .sheet(item: $selectedStatsHunt) { hunt in
                HomeHuntStatsView(hunt: hunt)
            }
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
        Button {
            selectedStatsHunt = hunt
        } label: {
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

                    HStack(spacing: 8) {
                        Text(hunt.todayEncountersText)
                            .font(.headline.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .monospacedDigit()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(AppTheme.homeMutedText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.primary.opacity(0.04), in: Capsule())
                }

                dailyPaceChart(hunt.dailyEncounters)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 30))
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
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

    private func dailyPaceChart(_ data: [ShinyEncounterDailyTotal]) -> some View {
        let maxValue = maxDailyEncounterCount(in: data)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Last 7 days")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.homeMutedText)

                Spacer(minLength: 0)

                Text("Details")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.homeMutedText)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, day in
                    dailyPaceColumn(
                        day,
                        maxValue: maxValue,
                        isToday: index == data.count - 1
                    )
                }
            }
            .frame(height: 148, alignment: .bottom)
        }
        .padding(.top, 2)
    }

    private func dailyPaceColumn(
        _ day: ShinyEncounterDailyTotal,
        maxValue: Int,
        isToday: Bool
    ) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.06))

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.homeAccentStrong, AppTheme.homeAccentSoft],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: barHeight(for: day.encounters, maxValue: maxValue, maxHeight: 112))
                    .opacity(day.encounters == 0 ? 0.35 : 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 112)

            Text(day.date, format: .dateTime.weekday(.narrow))
                .font(.caption2.weight(isToday ? .bold : .semibold))
                .foregroundStyle(isToday ? .primary : AppTheme.homeMutedText)
                .frame(height: 14)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
    }

    private func barHeight(
        for value: Int,
        maxValue: Int,
        maxHeight: CGFloat
    ) -> CGFloat {
        guard value > 0 else {
            return 5
        }

        let normalizedValue = CGFloat(value) / CGFloat(maxValue)
        return max(10, normalizedValue * maxHeight)
    }

    private func maxDailyEncounterCount(in data: [ShinyEncounterDailyTotal]) -> Int {
        max(data.map(\.encounters).max() ?? 0, 1)
    }
}

private struct HomeHuntStatsView: View {
    let hunt: HomeDashboardSnapshot.FeaturedHunt

    private var peakDay: ShinyEncounterDailyTotal? {
        hunt.dailyEncounters.max { $0.encounters < $1.encounters }
    }

    private var activeDayCount: Int {
        hunt.dailyEncounters.filter { $0.encounters > 0 }.count
    }

    private var averageDailyEncounters: Double {
        guard !hunt.dailyEncounters.isEmpty else {
            return 0
        }

        let total = hunt.dailyEncounters.reduce(0) { $0 + $1.encounters }
        return Double(total) / Double(hunt.dailyEncounters.count)
    }

    private var oddsProgressText: String {
        guard hunt.oddsDenominator > 0 else {
            return "0%"
        }

        let progress = Double(hunt.encounters) / Double(hunt.oddsDenominator)
        return progress.formatted(.percent.precision(.fractionLength(0)))
    }

    private var cumulativeProbabilityText: String {
        guard hunt.oddsDenominator > 0, hunt.encounters > 0 else {
            return "0%"
        }

        let missChance = pow(1 - (1 / Double(hunt.oddsDenominator)), Double(hunt.encounters))
        return (1 - missChance).formatted(.percent.precision(.fractionLength(1)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    metricGrid
                    oddsSection
                    dailyBreakdown
                }
                .padding(18)
            }
            .background(AppTheme.screenBackground)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(hunt.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(hunt.methodLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.homeMutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metricGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            statsTile(title: "Total", value: hunt.encountersText)
            statsTile(title: "Today", value: hunt.todayEncounters.formatted())
            statsTile(title: "Average/day", value: averageDailyEncounters.formatted(.number.precision(.fractionLength(1))))
            statsTile(title: "Active days", value: "\(activeDayCount)/\(hunt.dailyEncounters.count)")
            statsTile(title: "Peak day", value: peakDay?.encounters.formatted() ?? "0")
            statsTile(title: "Probability", value: cumulativeProbabilityText)
        }
    }

    private var oddsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Odds Progress")
                    .font(.headline.weight(.bold))

                Spacer(minLength: 0)

                Text(oddsProgressText)
                    .font(.headline.weight(.bold))
                    .monospacedDigit()
            }

            ProgressView(value: oddsProgress)
                .tint(AppTheme.accentColor)

            Text("\(hunt.encountersText) encounters toward \(hunt.oddsText)")
                .font(.subheadline)
                .foregroundStyle(AppTheme.homeMutedText)
        }
        .padding(16)
        .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private var dailyBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Breakdown")
                .font(.headline.weight(.bold))

            VStack(spacing: 10) {
                ForEach(hunt.dailyEncounters) { day in
                    dailyRow(day)
                }
            }
        }
        .padding(16)
        .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private var oddsProgress: Double {
        guard hunt.oddsDenominator > 0 else {
            return 0
        }

        return min(Double(hunt.encounters) / Double(hunt.oddsDenominator), 1)
    }

    private func statsTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(AppTheme.homeMutedText)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding(14)
        .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
        }
    }

    private func dailyRow(_ day: ShinyEncounterDailyTotal) -> some View {
        let maxValue = max(hunt.dailyEncounters.map(\.encounters).max() ?? 0, 1)
        let progress = Double(day.encounters) / Double(maxValue)

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(day.date, format: .dateTime.weekday(.wide))
                    .font(.subheadline.weight(.semibold))

                Text(day.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(AppTheme.homeMutedText)
            }
            .frame(width: 92, alignment: .leading)

            ProgressView(value: progress)
                .tint(AppTheme.accentColor)

            Text(day.encounters.formatted())
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
                .frame(width: 46, alignment: .trailing)
        }
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
