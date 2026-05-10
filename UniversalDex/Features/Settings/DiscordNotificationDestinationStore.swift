//
//  DiscordNotificationDestinationStore.swift
//  UniversalDex
//
//  Created by Codex on 10/05/2026.
//

import Foundation

protocol DiscordNotificationDestinationStore {
    func fetchDestinations(userID: UUID) async throws -> [DiscordNotificationDestination]
    func upsert(_ destination: DiscordNotificationDestination) async throws
    func delete(_ destination: DiscordNotificationDestination) async throws
}

enum DiscordNotificationDestinationStoreError: LocalizedError {
    case notConfigured
    case sdkNotInstalled

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Discord notifications are not configured yet."
        case .sdkNotInstalled:
            return "The Supabase SDK is not installed."
        }
    }
}

#if canImport(Supabase)
import Supabase

struct SupabaseDiscordNotificationDestinationStore: DiscordNotificationDestinationStore {
    private let client: SupabaseClient?

    init(configuration: SupabaseConfiguration? = SupabaseConfiguration.load()) {
        guard let configuration else {
            client = nil
            return
        }

        client = SupabaseClientFactory.makeClient(configuration: configuration)
    }

    func fetchDestinations(userID: UUID) async throws -> [DiscordNotificationDestination] {
        let client = try requireClient()

        let rows: [DiscordNotificationDestination] = try await client
            .from("discord_notification_destinations")
            .select()
            .eq("user_id", value: userID.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value

        return rows
    }

    func upsert(_ destination: DiscordNotificationDestination) async throws {
        let client = try requireClient()

        try await client
            .from("discord_notification_destinations")
            .upsert(destination)
            .execute()
    }

    func delete(_ destination: DiscordNotificationDestination) async throws {
        let client = try requireClient()

        try await client
            .from("discord_notification_destinations")
            .delete()
            .eq("id", value: destination.id.uuidString)
            .execute()
    }

    private func requireClient() throws -> SupabaseClient {
        guard let client else {
            throw DiscordNotificationDestinationStoreError.notConfigured
        }

        return client
    }
}
#else
struct SupabaseDiscordNotificationDestinationStore: DiscordNotificationDestinationStore {
    init(configuration _: SupabaseConfiguration? = nil) {}

    func fetchDestinations(userID _: UUID) async throws -> [DiscordNotificationDestination] {
        throw DiscordNotificationDestinationStoreError.sdkNotInstalled
    }

    func upsert(_: DiscordNotificationDestination) async throws {
        throw DiscordNotificationDestinationStoreError.sdkNotInstalled
    }

    func delete(_: DiscordNotificationDestination) async throws {
        throw DiscordNotificationDestinationStoreError.sdkNotInstalled
    }
}
#endif
