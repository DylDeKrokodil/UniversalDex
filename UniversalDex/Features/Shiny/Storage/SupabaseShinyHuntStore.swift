//
//  SupabaseShinyHuntStore.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

#if canImport(Supabase)
import Supabase

struct SupabaseShinyHuntStore: ShinyHuntStore {
    private let client: SupabaseClient?

    init(configuration: SupabaseConfiguration? = SupabaseConfiguration.load()) {
        guard let configuration else {
            client = nil
            return
        }

        client = SupabaseClientFactory.makeClient(configuration: configuration)
    }

    func fetchHunts() async throws -> [ShinyHunt] {
        let client = try requireClient()
        let userID = try requireUserID(from: client)

        let huntRows: [ShinyHuntRow] = try await client
            .from("shiny_hunts")
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        let eventRows: [ShinyEncounterEventRow] = try await client
            .from("shiny_encounter_events")
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("recorded_at", ascending: true)
            .execute()
            .value

        let eventsByHuntID = Dictionary(grouping: eventRows, by: \.huntID)

        return huntRows.map { huntRow in
            huntRow.asHunt(
                encounterEvents: eventsByHuntID[huntRow.id, default: []]
                    .map(\.asEncounterEvent)
            )
        }
    }

    func upsert(_ hunt: ShinyHunt) async throws {
        let client = try requireClient()
        let userID = try requireUserID(from: client)

        try await client
            .from("shiny_hunts")
            .upsert(
                ShinyHuntRow(
                    hunt: hunt,
                    userID: userID
                )
            )
            .execute()

        guard !hunt.encounterEvents.isEmpty else {
            return
        }

        try await client
            .from("shiny_encounter_events")
            .upsert(
                hunt.encounterEvents.map {
                    ShinyEncounterEventRow(
                        event: $0,
                        huntID: hunt.id,
                        userID: userID
                    )
                }
            )
            .execute()
    }

    func delete(_ hunt: ShinyHunt) async throws {
        let client = try requireClient()

        try await client
            .from("shiny_encounter_events")
            .delete()
            .eq("hunt_id", value: hunt.id.uuidString)
            .execute()

        try await client
            .from("shiny_hunts")
            .delete()
            .eq("id", value: hunt.id.uuidString)
            .execute()
    }

    private func requireClient() throws -> SupabaseClient {
        guard let client else {
            throw ShinyHuntStoreError.notConfigured
        }

        return client
    }

    private func requireUserID(from client: SupabaseClient) throws -> UUID {
        guard let userID = client.auth.currentUser?.id else {
            throw ShinyHuntStoreError.unauthenticated
        }

        return userID
    }
}

private struct ShinyHuntRow: Codable {
    let id: UUID
    let userID: UUID
    let pokemonID: Int?
    let pokemonName: String
    let huntName: String
    let game: String
    let method: String
    let trackingMetric: String
    let hasShinyCharm: Bool
    let oddsDenominator: Int
    let encounters: Int
    let encounterIncrement: Int
    let startedAt: Date?
    let elapsedTime: TimeInterval
    let timerStartedAt: Date?
    let isCaught: Bool
    let createdAt: Date
    let caughtAt: Date?
    let completionNickname: String?
    let completionBall: String?
    let completionEncounters: Int?
    let completionElapsedTime: TimeInterval?
    let completionIsFailed: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case pokemonID = "pokemon_id"
        case pokemonName = "pokemon_name"
        case huntName = "hunt_name"
        case game
        case method
        case trackingMetric = "tracking_metric"
        case hasShinyCharm = "has_shiny_charm"
        case oddsDenominator = "odds_denominator"
        case encounters
        case encounterIncrement = "encounter_increment"
        case startedAt = "started_at"
        case elapsedTime = "elapsed_time"
        case timerStartedAt = "timer_started_at"
        case isCaught = "is_caught"
        case createdAt = "created_at"
        case caughtAt = "caught_at"
        case completionNickname = "completion_nickname"
        case completionBall = "completion_ball"
        case completionEncounters = "completion_encounters"
        case completionElapsedTime = "completion_elapsed_time"
        case completionIsFailed = "completion_is_failed"
    }

    init(hunt: ShinyHunt, userID: UUID) {
        let persistedHunt = hunt.withoutRunningTimerState()

        id = persistedHunt.id
        self.userID = userID
        pokemonID = persistedHunt.pokemonID
        pokemonName = persistedHunt.pokemonName
        huntName = persistedHunt.huntName
        game = persistedHunt.game.rawValue
        method = persistedHunt.method.rawValue
        trackingMetric = persistedHunt.trackingMetric.rawValue
        hasShinyCharm = persistedHunt.hasShinyCharm
        oddsDenominator = persistedHunt.oddsDenominator
        encounters = persistedHunt.encounters
        encounterIncrement = persistedHunt.encounterIncrement
        startedAt = persistedHunt.startedAt
        elapsedTime = persistedHunt.elapsedTime
        timerStartedAt = nil
        isCaught = persistedHunt.isCaught
        createdAt = persistedHunt.createdAt
        caughtAt = persistedHunt.caughtAt
        completionNickname = persistedHunt.completion?.nickname
        completionBall = persistedHunt.completion?.ball.rawValue
        completionEncounters = persistedHunt.completion?.encounters
        completionElapsedTime = persistedHunt.completion?.elapsedTime
        completionIsFailed = persistedHunt.completion?.isFailed ?? false
    }

    func asHunt(encounterEvents: [ShinyEncounterEvent]) -> ShinyHunt {
        let completion = completionBall.map { ball in
            ShinyHunt.Completion(
                nickname: completionNickname ?? "",
                ball: ShinyCaughtBall(rawValue: ball) ?? .poke,
                encounters: completionEncounters ?? encounters,
                elapsedTime: completionElapsedTime ?? elapsedTime,
                caughtAt: caughtAt ?? Date(),
                isFailed: completionIsFailed
            )
        }

        return ShinyHunt(
            id: id,
            pokemonID: pokemonID,
            pokemonName: pokemonName,
            huntName: huntName,
            game: ShinyGame(rawValue: game) ?? .scarlet,
            method: ShinyMethod(rawValue: method) ?? .randomEncounter,
            trackingMetric: ShinyTrackingMetric(rawValue: trackingMetric) ?? .encounters,
            hasShinyCharm: hasShinyCharm,
            oddsDenominator: oddsDenominator,
            encounters: encounters,
            encounterIncrement: encounterIncrement,
            encounterEvents: encounterEvents,
            startedAt: startedAt,
            elapsedTime: elapsedTime,
            timerStartedAt: nil,
            isCaught: isCaught,
            createdAt: createdAt,
            caughtAt: caughtAt,
            completion: completion
        )
    }
}

private struct ShinyEncounterEventRow: Codable {
    let id: UUID
    let huntID: UUID
    let userID: UUID
    let recordedAt: Date
    let delta: Int
    let kind: String

    enum CodingKeys: String, CodingKey {
        case id
        case huntID = "hunt_id"
        case userID = "user_id"
        case recordedAt = "recorded_at"
        case delta
        case kind
    }

    init(event: ShinyEncounterEvent, huntID: UUID, userID: UUID) {
        id = event.id
        self.huntID = huntID
        self.userID = userID
        recordedAt = event.recordedAt
        delta = event.delta
        kind = event.kind.rawValue
    }

    var asEncounterEvent: ShinyEncounterEvent {
        ShinyEncounterEvent(
            id: id,
            recordedAt: recordedAt,
            delta: delta,
            kind: ShinyEncounterEvent.Kind(rawValue: kind) ?? .adjustment
        )
    }
}
#else
struct SupabaseShinyHuntStore: ShinyHuntStore {
    init(configuration _: SupabaseConfiguration? = nil) {}

    func fetchHunts() async throws -> [ShinyHunt] {
        throw ShinyHuntStoreError.sdkNotInstalled
    }

    func upsert(_: ShinyHunt) async throws {
        throw ShinyHuntStoreError.sdkNotInstalled
    }

    func delete(_: ShinyHunt) async throws {
        throw ShinyHuntStoreError.sdkNotInstalled
    }
}
#endif
