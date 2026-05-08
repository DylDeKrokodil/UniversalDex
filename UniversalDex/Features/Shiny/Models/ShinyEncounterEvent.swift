//
//  ShinyEncounterEvent.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

struct ShinyEncounterEvent: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, Hashable {
        case increment
        case decrement
        case adjustment
    }

    var id: UUID
    var recordedAt: Date
    var delta: Int
    var kind: Kind

    init(
        id: UUID = UUID(),
        recordedAt: Date = Date(),
        delta: Int,
        kind: Kind
    ) {
        self.id = id
        self.recordedAt = recordedAt
        self.delta = delta
        self.kind = kind
    }
}

struct ShinyEncounterDailyTotal: Identifiable, Hashable {
    let id: Date
    let date: Date
    let encounters: Int
}
