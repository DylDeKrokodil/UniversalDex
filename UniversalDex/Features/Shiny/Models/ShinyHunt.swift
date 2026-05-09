//
//  ShinyHunt.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

struct ShinyHunt: Identifiable, Codable, Hashable {
    var id = UUID()
    var pokemonID: Int?
    var pokemonName: String
    var game: ShinyGame
    var method: ShinyMethod
    var oddsDenominator: Int
    var encounters: Int
    var encounterEvents: [ShinyEncounterEvent]
    var isCaught = false
    var createdAt = Date()
    var caughtAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case pokemonID
        case pokemonName
        case game
        case method
        case oddsDenominator
        case encounters
        case encounterEvents
        case isCaught
        case createdAt
        case caughtAt
    }

    init(
        id: UUID = UUID(),
        pokemonID: Int?,
        pokemonName: String,
        game: ShinyGame,
        method: ShinyMethod,
        oddsDenominator: Int,
        encounters: Int,
        encounterEvents: [ShinyEncounterEvent] = [],
        isCaught: Bool = false,
        createdAt: Date = Date(),
        caughtAt: Date? = nil
    ) {
        self.id = id
        self.pokemonID = pokemonID
        self.pokemonName = pokemonName
        self.game = game
        self.method = method
        self.oddsDenominator = oddsDenominator
        self.encounters = encounters
        self.encounterEvents = encounterEvents
        self.isCaught = isCaught
        self.createdAt = createdAt
        self.caughtAt = caughtAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        pokemonID = try container.decodeIfPresent(Int.self, forKey: .pokemonID)
        pokemonName = try container.decode(String.self, forKey: .pokemonName)
        game = try container.decode(ShinyGame.self, forKey: .game)
        method = try container.decode(ShinyMethod.self, forKey: .method)
        oddsDenominator = try container.decode(Int.self, forKey: .oddsDenominator)
        encounters = try container.decode(Int.self, forKey: .encounters)
        encounterEvents = try container.decodeIfPresent([ShinyEncounterEvent].self, forKey: .encounterEvents) ?? []
        isCaught = try container.decodeIfPresent(Bool.self, forKey: .isCaught) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        caughtAt = try container.decodeIfPresent(Date.self, forKey: .caughtAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(pokemonID, forKey: .pokemonID)
        try container.encode(pokemonName, forKey: .pokemonName)
        try container.encode(game, forKey: .game)
        try container.encode(method, forKey: .method)
        try container.encode(oddsDenominator, forKey: .oddsDenominator)
        try container.encode(encounters, forKey: .encounters)
        try container.encode(encounterEvents, forKey: .encounterEvents)
        try container.encode(isCaught, forKey: .isCaught)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(caughtAt, forKey: .caughtAt)
    }

    var oddsText: String {
        "1/\(oddsDenominator.formatted())"
    }

    var formattedPokemonNumber: String? {
        guard let pokemonID else {
            return nil
        }

        return String(format: "%03d", pokemonID)
    }

    var artworkURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemonID).png")
    }

    var gameShinySpriteURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return game.shinySpriteURL(for: pokemonID)
    }

    var gameAnimatedShinySpriteURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return game.animatedShinySpriteURL(for: pokemonID)
    }

    var showdownAnimatedShinySpriteURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/shiny/\(pokemonID).gif")
    }

    var detailShinySpriteURLs: [URL] {
        uniqueURLs([
            showdownAnimatedShinySpriteURL,
            gameShinySpriteURL,
        ].compactMap { $0 })
    }

    var latestCryURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/\(pokemonID).ogg")
    }

    var encounterProgress: Double {
        guard oddsDenominator > 0 else {
            return 0
        }

        return min(Double(encounters) / Double(oddsDenominator), 1)
    }

    var lastActivityAt: Date {
        encounterEvents.last?.recordedAt ?? createdAt
    }

    private func uniqueURLs(_ urls: [URL]) -> [URL] {
        var seenURLs: Set<URL> = []
        return urls.filter { seenURLs.insert($0).inserted }
    }

    var cumulativeProbabilityText: String {
        guard oddsDenominator > 0, encounters > 0 else {
            return "0%"
        }

        let missChance = pow(1 - (1 / Double(oddsDenominator)), Double(encounters))
        let cumulativeProbability = 1 - missChance

        return cumulativeProbability.formatted(.percent.precision(.fractionLength(1)))
    }

    mutating func recordEncounterChange(
        delta: Int,
        kind: ShinyEncounterEvent.Kind,
        at date: Date = Date()
    ) {
        guard delta != 0 else {
            return
        }

        encounters = max(0, encounters + delta)
        encounterEvents.append(
            ShinyEncounterEvent(
                recordedAt: date,
                delta: delta,
                kind: kind
            )
        )
    }

    func encounters(on day: Date, calendar: Calendar = .current) -> Int {
        max(
            0,
            encounterEvents
                .filter { calendar.isDate($0.recordedAt, inSameDayAs: day) }
                .reduce(into: 0) { partialResult, event in
                    partialResult += event.delta
                }
        )
    }

    func dailyEncounters(
        forLast days: Int,
        endingOn endDate: Date = Date(),
        calendar: Calendar = .current
    ) -> [ShinyEncounterDailyTotal] {
        guard days > 0 else {
            return []
        }

        let endOfDay = calendar.startOfDay(for: endDate)

        return (0..<days).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset - (days - 1), to: endOfDay) else {
                return nil
            }

            return ShinyEncounterDailyTotal(
                id: day,
                date: day,
                encounters: encounters(on: day, calendar: calendar)
            )
        }
    }

    func migratedForEncounterHistory() -> ShinyHunt {
        guard encounters > 0, encounterEvents.isEmpty else {
            return self
        }

        var migrated = self
        migrated.encounterEvents = [
            ShinyEncounterEvent(
                recordedAt: createdAt,
                delta: encounters,
                kind: .adjustment
            )
        ]
        return migrated
    }
}
