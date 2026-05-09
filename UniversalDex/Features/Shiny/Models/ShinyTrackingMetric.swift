//
//  ShinyTrackingMetric.swift
//  UniversalDex
//
//  Created by Codex on 09/05/2026.
//

import Foundation

enum ShinyTrackingMetric: String, CaseIterable, Codable, Identifiable {
    case encounters
    case time
    case both

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .encounters:
            return "Encounters"
        case .time:
            return "Time"
        case .both:
            return "Both"
        }
    }

    var tracksEncounters: Bool {
        self == .encounters || self == .both
    }

    var tracksTime: Bool {
        self == .time || self == .both
    }
}
