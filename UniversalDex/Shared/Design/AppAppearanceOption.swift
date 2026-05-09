//
//  AppAppearanceOption.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

enum AppAppearanceOption: String, CaseIterable, Identifiable {
    case automatic
    case light
    case dark

    static let storageKey = "appAppearanceOption"

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .automatic:
            return "Auto"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .automatic:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
