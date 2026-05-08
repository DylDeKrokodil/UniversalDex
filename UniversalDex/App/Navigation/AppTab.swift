//
//  AppTab.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

enum AppTab: CaseIterable, Hashable, Identifiable {
    case shiny
    case settings

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .shiny:
            return "Shiny"
        case .settings:
            return "Settings"
        }
    }

    var path: String {
        switch self {
        case .shiny:
            return "/shiny"
        case .settings:
            return "/settings"
        }
    }

    var iconName: String {
        switch self {
        case .shiny:
            return "sparkles"
        case .settings:
            return "gearshape.fill"
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .shiny:
            ShinyView()
        case .settings:
            SettingsView()
        }
    }
}
