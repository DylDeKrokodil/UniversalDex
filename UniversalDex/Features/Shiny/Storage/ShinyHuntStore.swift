//
//  ShinyHuntStore.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

enum ShinyHuntStoreError: LocalizedError {
    case notConfigured
    case sdkNotInstalled
    case unauthenticated

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "The hunt store is not configured yet."
        case .sdkNotInstalled:
            return "The required data dependency has not been added to the app."
        case .unauthenticated:
            return "You must be signed in before hunts can sync."
        }
    }
}

protocol ShinyHuntStore {
    func fetchHunts() async throws -> [ShinyHunt]
    func upsert(_ hunt: ShinyHunt) async throws
    func delete(_ hunt: ShinyHunt) async throws
}

struct LocalShinyHuntStore: ShinyHuntStore {
    private let storageKey = "universalDex.shinyHunts"

    func fetchHunts() async throws -> [ShinyHunt] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }

        return try JSONDecoder().decode([ShinyHunt].self, from: data)
    }

    func upsert(_ hunt: ShinyHunt) async throws {
        var hunts = try await fetchHunts()

        if let index = hunts.firstIndex(where: { $0.id == hunt.id }) {
            hunts[index] = hunt
        } else {
            hunts.insert(hunt, at: 0)
        }

        try save(hunts)
    }

    func delete(_ hunt: ShinyHunt) async throws {
        let hunts = try await fetchHunts().filter { $0.id != hunt.id }
        try save(hunts)
    }

    private func save(_ hunts: [ShinyHunt]) throws {
        let data = try JSONEncoder().encode(hunts)
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
