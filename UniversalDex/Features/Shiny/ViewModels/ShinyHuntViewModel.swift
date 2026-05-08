//
//  ShinyHuntViewModel.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Combine
import Foundation

@MainActor
final class ShinyHuntViewModel: ObservableObject {
    @Published private(set) var hunts: [ShinyHunt] = [] {
        didSet {
            saveHunts()
        }
    }

    private let storageKey = "universalDex.shinyHunts"

    var activeHunts: [ShinyHunt] {
        hunts
            .filter { !$0.isCaught }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var caughtHunts: [ShinyHunt] {
        hunts
            .filter(\.isCaught)
            .sorted { ($0.caughtAt ?? $0.createdAt) > ($1.caughtAt ?? $1.createdAt) }
    }

    init() {
        loadHunts()
    }

    func add(_ hunt: ShinyHunt) {
        hunts.insert(hunt, at: 0)
    }

    func incrementEncounters(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            guard !editableHunt.isCaught else {
                return
            }

            editableHunt.encounters += 1
        }
    }

    func decrementEncounters(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            editableHunt.encounters = max(0, editableHunt.encounters - 1)
        }
    }

    func setEncounters(for hunt: ShinyHunt, to encounters: Int) {
        update(hunt) { editableHunt in
            editableHunt.encounters = max(0, encounters)
        }
    }

    func markCaught(_ hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            editableHunt.isCaught = true
            editableHunt.caughtAt = Date()
        }
    }

    func reopen(_ hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            editableHunt.isCaught = false
            editableHunt.caughtAt = nil
        }
    }

    func delete(_ hunt: ShinyHunt) {
        hunts.removeAll { $0.id == hunt.id }
    }

    private func update(_ hunt: ShinyHunt, mutation: (inout ShinyHunt) -> Void) {
        guard let index = hunts.firstIndex(where: { $0.id == hunt.id }) else {
            return
        }

        mutation(&hunts[index])
    }

    private func loadHunts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            hunts = try JSONDecoder().decode([ShinyHunt].self, from: data)
        } catch {
            AppDebugLog.log("Could not decode shiny hunts: \(error.localizedDescription)")
            hunts = []
        }
    }

    private func saveHunts() {
        do {
            let data = try JSONEncoder().encode(hunts)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            AppDebugLog.log("Could not save shiny hunts: \(error.localizedDescription)")
        }
    }
}
