//
//  ShinyCaughtBall.swift
//  UniversalDex
//
//  Created by Codex on 09/05/2026.
//

import Foundation

enum ShinyCaughtBall: String, CaseIterable, Codable, Identifiable {
    case poke
    case great
    case ultra
    case master
    case premier
    case luxury
    case heal
    case net
    case nest
    case dive
    case dusk
    case quick
    case timer
    case repeatBall
    case dream
    case beast
    case fast
    case friend
    case lure
    case level
    case heavy
    case love
    case moon
    case sport
    case safari
    case other

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .poke:
            return "Poke Ball"
        case .great:
            return "Great Ball"
        case .ultra:
            return "Ultra Ball"
        case .master:
            return "Master Ball"
        case .premier:
            return "Premier Ball"
        case .luxury:
            return "Luxury Ball"
        case .heal:
            return "Heal Ball"
        case .net:
            return "Net Ball"
        case .nest:
            return "Nest Ball"
        case .dive:
            return "Dive Ball"
        case .dusk:
            return "Dusk Ball"
        case .quick:
            return "Quick Ball"
        case .timer:
            return "Timer Ball"
        case .repeatBall:
            return "Repeat Ball"
        case .dream:
            return "Dream Ball"
        case .beast:
            return "Beast Ball"
        case .fast:
            return "Fast Ball"
        case .friend:
            return "Friend Ball"
        case .lure:
            return "Lure Ball"
        case .level:
            return "Level Ball"
        case .heavy:
            return "Heavy Ball"
        case .love:
            return "Love Ball"
        case .moon:
            return "Moon Ball"
        case .sport:
            return "Sport Ball"
        case .safari:
            return "Safari Ball"
        case .other:
            return "Other"
        }
    }
}
