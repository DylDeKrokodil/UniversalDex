//
//  AppTab.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

enum AppTab: CaseIterable, Hashable, Identifiable {
    case pokedex
    case map
    case shiny
    case settings

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .pokedex:
            return "Pokedex"
        case .map:
            return "Map"
        case .shiny:
            return "Shiny"
        case .settings:
            return "Settings"
        }
    }

    var path: String {
        switch self {
        case .pokedex:
            return "/pokedex"
        case .map:
            return "/map"
        case .shiny:
            return "/shiny"
        case .settings:
            return "/settings"
        }
    }

    var iconName: String {
        switch self {
        case .pokedex:
            return "book.pages.fill"
        case .map:
            return "map.fill"
        case .shiny:
            return "sparkles"
        case .settings:
            return "gearshape.fill"
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .pokedex:
            PokedexView()
        case .map:
            MapView()
        case .shiny:
            ShinyView()
        case .settings:
            SettingsView()
        }
    }
}
