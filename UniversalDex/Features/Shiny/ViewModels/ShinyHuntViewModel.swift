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
            .sorted { $0.lastActivityAt > $1.lastActivityAt }
    }

    var caughtHunts: [ShinyHunt] {
        hunts
            .filter(\.isCaught)
            .sorted { ($0.caughtAt ?? $0.createdAt) > ($1.caughtAt ?? $1.createdAt) }
    }

    init() {
        loadHunts()
    }

    init(previewHunts: [ShinyHunt]) {
        hunts = previewHunts
    }

    func add(_ hunt: ShinyHunt) {
        hunts.insert(hunt, at: 0)
    }

    func incrementEncounters(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            guard !editableHunt.isCaught else {
                return
            }

            editableHunt.recordEncounterChange(delta: 1, kind: .increment)
        }
    }

    func decrementEncounters(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            guard editableHunt.encounters > 0 else {
                return
            }

            editableHunt.recordEncounterChange(delta: -1, kind: .decrement)
        }
    }

    func setEncounters(for hunt: ShinyHunt, to encounters: Int) {
        update(hunt) { editableHunt in
            let sanitizedEncounters = max(0, encounters)
            let delta = sanitizedEncounters - editableHunt.encounters
            editableHunt.recordEncounterChange(delta: delta, kind: .adjustment)
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
            hunts = try JSONDecoder()
                .decode([ShinyHunt].self, from: data)
                .map { $0.migratedForEncounterHistory() }
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
