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
    @Published private(set) var hunts: [ShinyHunt] = []

    private let store: any ShinyHuntStore

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
        store = LocalShinyHuntStore()

        Task {
            await loadHunts()
        }
    }

    init(store: any ShinyHuntStore) {
        self.store = store

        Task {
            await loadHunts()
        }
    }

    init(previewHunts: [ShinyHunt]) {
        store = LocalShinyHuntStore()
        hunts = previewHunts
    }

    func add(_ hunt: ShinyHunt) {
        hunts.insert(hunt, at: 0)
        sync(hunt)
    }

    func incrementEncounters(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            guard !editableHunt.isCaught else {
                return
            }

            editableHunt.recordEncounterChange(delta: editableHunt.encounterIncrement, kind: .increment)
            if editableHunt.trackingMetric.tracksTime {
                editableHunt.startTimer()
            }
        }
    }

    func decrementEncounters(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            guard editableHunt.encounters > 0 else {
                return
            }

            editableHunt.recordEncounterChange(
                delta: -min(editableHunt.encounterIncrement, editableHunt.encounters),
                kind: .decrement
            )
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
            editableHunt.stopTimer()
            editableHunt.isCaught = true
            editableHunt.caughtAt = Date()
        }
    }

    func startTimer(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            guard !editableHunt.isCaught else {
                return
            }

            editableHunt.startTimer()
        }
    }

    func stopTimer(for hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            editableHunt.stopTimer()
        }
    }

    func stopRunningTimers() {
        for hunt in hunts where hunt.isTimerRunning {
            stopTimer(for: hunt)
        }
    }

    func complete(_ hunt: ShinyHunt, completion: ShinyHunt.Completion) {
        update(hunt) { editableHunt in
            var savedCompletion = completion
            savedCompletion.encounters = max(0, completion.encounters)
            savedCompletion.elapsedTime = max(0, max(completion.elapsedTime, editableHunt.totalElapsedTime))

            editableHunt.stopTimer()
            editableHunt.encounters = savedCompletion.encounters
            editableHunt.elapsedTime = savedCompletion.elapsedTime
            editableHunt.timerStartedAt = nil
            editableHunt.isCaught = true
            editableHunt.caughtAt = savedCompletion.caughtAt
            editableHunt.completion = savedCompletion
        }
    }

    func reopen(_ hunt: ShinyHunt) {
        update(hunt) { editableHunt in
            editableHunt.isCaught = false
            editableHunt.caughtAt = nil
            editableHunt.completion = nil
        }
    }

    func delete(_ hunt: ShinyHunt) {
        hunts.removeAll { $0.id == hunt.id }
        Task {
            do {
                try await store.delete(hunt)
            } catch {
                AppDebugLog.log("Could not delete shiny hunt: \(error.localizedDescription)")
            }
        }
    }

    private func update(_ hunt: ShinyHunt, mutation: (inout ShinyHunt) -> Void) {
        guard let index = hunts.firstIndex(where: { $0.id == hunt.id }) else {
            return
        }

        mutation(&hunts[index])
        sync(hunts[index])
    }

    private func loadHunts() async {
        do {
            hunts = try await store
                .fetchHunts()
                .map { $0.migratedForEncounterHistory() }
        } catch {
            AppDebugLog.log("Could not load shiny hunts: \(error.localizedDescription)")
            hunts = []
        }
    }

    private func sync(_ hunt: ShinyHunt) {
        Task {
            do {
                try await store.upsert(hunt)
            } catch {
                AppDebugLog.log("Could not save shiny hunt: \(error.localizedDescription)")
            }
        }
    }
}
