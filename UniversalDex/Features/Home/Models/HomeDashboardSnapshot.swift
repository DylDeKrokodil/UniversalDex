//
//  HomeDashboardSnapshot.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

struct HomeDashboardSnapshot {
    struct FeaturedHunt {
        let id: ShinyHunt.ID
        let title: String
        let methodLabel: String
        let encountersText: String
        let oddsText: String
        let todayEncountersText: String
        let paceHeadline: String
        let dailyEncounters: [ShinyEncounterDailyTotal]
        let secondaryActiveCount: Int
    }

    let featuredHunt: FeaturedHunt?
    let caughtArchiveCount: Int

    init(hunts: [ShinyHunt], now: Date = Date(), calendar: Calendar = .current) {
        let activeHunts = hunts
            .filter { !$0.isCaught }
            .sorted { $0.lastActivityAt > $1.lastActivityAt }

        caughtArchiveCount = hunts.filter(\.isCaught).count

        guard let hunt = activeHunts.first else {
            featuredHunt = nil
            return
        }

        let dailyEncounters = hunt.dailyEncounters(
            forLast: 7,
            endingOn: now,
            calendar: calendar
        )
        let todayEncounters = dailyEncounters.last?.encounters ?? 0

        featuredHunt = FeaturedHunt(
            id: hunt.id,
            title: hunt.pokemonName,
            methodLabel: hunt.method.dashboardLabel,
            encountersText: hunt.encounters.formatted(),
            oddsText: hunt.oddsText,
            todayEncountersText: todayEncounters > 0 ? "+\(todayEncounters.formatted()) today" : "0 today",
            paceHeadline: Self.paceHeadline(
                todayEncounters: todayEncounters,
                totalEncounters: hunt.encounters,
                oddsDenominator: hunt.oddsDenominator
            ),
            dailyEncounters: dailyEncounters,
            secondaryActiveCount: max(0, activeHunts.count - 1)
        )
    }

    private static func paceHeadline(
        todayEncounters: Int,
        totalEncounters: Int,
        oddsDenominator: Int
    ) -> String {
        if todayEncounters >= 100 {
            return "Locked in"
        }

        if todayEncounters >= 40 {
            return "Fast and focused"
        }

        if totalEncounters >= oddsDenominator && oddsDenominator > 0 {
            return "Over odds, still going"
        }

        if todayEncounters > 0 {
            return "Steady progress"
        }

        return "Ready for the next session"
    }
}
