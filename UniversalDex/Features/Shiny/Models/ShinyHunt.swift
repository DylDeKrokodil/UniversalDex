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
    var huntName: String
    var game: ShinyGame
    var method: ShinyMethod
    var trackingMetric: ShinyTrackingMetric
    var hasShinyCharm: Bool
    var oddsDenominator: Int
    var encounters: Int
    var encounterIncrement: Int
    var encounterEvents: [ShinyEncounterEvent]
    var startedAt: Date?
    var elapsedTime: TimeInterval
    var timerStartedAt: Date?
    var isCaught = false
    var createdAt = Date()
    var caughtAt: Date?
    var completion: Completion?

    struct Completion: Codable, Hashable {
        var nickname: String
        var ball: ShinyCaughtBall
        var encounters: Int
        var elapsedTime: TimeInterval
        var caughtAt: Date
        var isFailed: Bool

        var displayName: String {
            let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedNickname.isEmpty ? "No nickname" : trimmedNickname
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case pokemonID
        case pokemonName
        case huntName
        case game
        case method
        case trackingMetric
        case hasShinyCharm
        case oddsDenominator
        case encounters
        case encounterIncrement
        case encounterEvents
        case startedAt
        case elapsedTime
        case timerStartedAt
        case isCaught
        case createdAt
        case caughtAt
        case completion
    }

    init(
        id: UUID = UUID(),
        pokemonID: Int?,
        pokemonName: String,
        huntName: String? = nil,
        game: ShinyGame,
        method: ShinyMethod,
        trackingMetric: ShinyTrackingMetric = .encounters,
        hasShinyCharm: Bool = false,
        oddsDenominator: Int,
        encounters: Int,
        encounterIncrement: Int = 1,
        encounterEvents: [ShinyEncounterEvent] = [],
        startedAt: Date? = nil,
        elapsedTime: TimeInterval = 0,
        timerStartedAt: Date? = nil,
        isCaught: Bool = false,
        createdAt: Date = Date(),
        caughtAt: Date? = nil,
        completion: Completion? = nil
    ) {
        self.id = id
        self.pokemonID = pokemonID
        self.pokemonName = pokemonName
        self.huntName = huntName ?? pokemonName
        self.game = game
        self.method = method
        self.trackingMetric = trackingMetric
        self.hasShinyCharm = hasShinyCharm
        self.oddsDenominator = oddsDenominator
        self.encounters = encounters
        self.encounterIncrement = max(1, encounterIncrement)
        self.encounterEvents = encounterEvents
        self.startedAt = startedAt
        self.elapsedTime = max(0, elapsedTime)
        self.timerStartedAt = timerStartedAt
        self.isCaught = isCaught
        self.createdAt = createdAt
        self.caughtAt = caughtAt
        self.completion = completion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        pokemonID = try container.decodeIfPresent(Int.self, forKey: .pokemonID)
        pokemonName = try container.decode(String.self, forKey: .pokemonName)
        huntName = try container.decodeIfPresent(String.self, forKey: .huntName) ?? pokemonName
        game = try container.decode(ShinyGame.self, forKey: .game)
        method = try container.decode(ShinyMethod.self, forKey: .method)
        trackingMetric = try container.decodeIfPresent(ShinyTrackingMetric.self, forKey: .trackingMetric) ?? .encounters
        hasShinyCharm = try container.decodeIfPresent(Bool.self, forKey: .hasShinyCharm) ?? (method == .shinyCharm || method == .masudaCharm)
        oddsDenominator = try container.decode(Int.self, forKey: .oddsDenominator)
        encounters = try container.decode(Int.self, forKey: .encounters)
        encounterIncrement = max(1, try container.decodeIfPresent(Int.self, forKey: .encounterIncrement) ?? 1)
        encounterEvents = try container.decodeIfPresent([ShinyEncounterEvent].self, forKey: .encounterEvents) ?? []
        startedAt = try container.decodeIfPresent(Date.self, forKey: .startedAt)
        elapsedTime = max(0, try container.decodeIfPresent(TimeInterval.self, forKey: .elapsedTime) ?? 0)
        timerStartedAt = try container.decodeIfPresent(Date.self, forKey: .timerStartedAt)
        isCaught = try container.decodeIfPresent(Bool.self, forKey: .isCaught) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        caughtAt = try container.decodeIfPresent(Date.self, forKey: .caughtAt)
        completion = try container.decodeIfPresent(Completion.self, forKey: .completion)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(pokemonID, forKey: .pokemonID)
        try container.encode(pokemonName, forKey: .pokemonName)
        try container.encode(huntName, forKey: .huntName)
        try container.encode(game, forKey: .game)
        try container.encode(method, forKey: .method)
        try container.encode(trackingMetric, forKey: .trackingMetric)
        try container.encode(hasShinyCharm, forKey: .hasShinyCharm)
        try container.encode(oddsDenominator, forKey: .oddsDenominator)
        try container.encode(encounters, forKey: .encounters)
        try container.encode(encounterIncrement, forKey: .encounterIncrement)
        try container.encode(encounterEvents, forKey: .encounterEvents)
        try container.encodeIfPresent(startedAt, forKey: .startedAt)
        try container.encode(elapsedTime, forKey: .elapsedTime)
        try container.encodeIfPresent(timerStartedAt, forKey: .timerStartedAt)
        try container.encode(isCaught, forKey: .isCaught)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(caughtAt, forKey: .caughtAt)
        try container.encodeIfPresent(completion, forKey: .completion)
    }

    var oddsText: String {
        "1/\(oddsDenominator.formatted())"
    }

    var displayTitle: String {
        huntName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? pokemonName : huntName
    }

    var isFailed: Bool {
        completion?.isFailed ?? false
    }

    var isTimerRunning: Bool {
        timerStartedAt != nil
    }

    var totalElapsedTime: TimeInterval {
        guard let timerStartedAt else {
            return elapsedTime
        }

        return elapsedTime + max(0, Date().timeIntervalSince(timerStartedAt))
    }

    var formattedElapsedTime: String {
        Self.formattedDuration(totalElapsedTime)
    }

    var encountersPerHour: Double {
        guard trackingMetric.tracksEncounters, trackingMetric.tracksTime, totalElapsedTime > 0 else {
            return 0
        }

        return Double(encounters) / (totalElapsedTime / 3600)
    }

    var formattedEncountersPerHour: String {
        encountersPerHour.formatted(.number.precision(.fractionLength(1)))
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

    var homeShinySpriteURL: URL? {
        guard let pokemonID else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/\(pokemonID).png")
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
            homeShinySpriteURL,
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
        timerStartedAt ?? encounterEvents.last?.recordedAt ?? startedAt ?? createdAt
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
        if startedAt == nil, delta > 0 {
            startedAt = date
        }
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

    mutating func startTimer(at date: Date = Date()) {
        guard timerStartedAt == nil else {
            return
        }

        if startedAt == nil {
            startedAt = date
        }

        timerStartedAt = date
    }

    mutating func stopTimer(at date: Date = Date()) {
        guard let timerStartedAt else {
            return
        }

        elapsedTime += max(0, date.timeIntervalSince(timerStartedAt))
        self.timerStartedAt = nil
    }

    static func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded(.down)))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        }

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }

        return "\(seconds)s"
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
        migrated.startedAt = createdAt
        return migrated
    }
}
