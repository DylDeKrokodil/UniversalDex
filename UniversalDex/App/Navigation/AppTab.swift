//
//  AppTab.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

enum AppTab: CaseIterable, Hashable, Identifiable {
    case home
    case shiny
    case settings

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .shiny:
            return "Shiny"
        case .settings:
            return "Settings"
        }
    }

    var path: String {
        switch self {
        case .home:
            return "/home"
        case .shiny:
            return "/shiny"
        case .settings:
            return "/settings"
        }
    }

    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .shiny:
            return "sparkles"
        case .settings:
            return "gearshape.fill"
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            HomeView()
        case .shiny:
            ShinyView()
        case .settings:
            SettingsView()
        }
    }
}
