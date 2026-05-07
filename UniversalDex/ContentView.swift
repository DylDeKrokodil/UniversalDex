//
//  ContentView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = AppTab.pokedex

    var body: some View {
        TabView(selection: $selectedTab) {
            PokedexView()
                .tag(AppTab.pokedex)
                .tabItem {
                    Image(systemName: AppTab.pokedex.iconName)
                }
                .accessibilityLabel(AppTab.pokedex.title)

            ShinyView()
                .tag(AppTab.shiny)
                .tabItem {
                    Image(systemName: AppTab.shiny.iconName)
                }
                .accessibilityLabel(AppTab.shiny.title)

            SettingsView()
                .tag(AppTab.settings)
                .tabItem {
                    Image(systemName: AppTab.settings.iconName)
                }
                .accessibilityLabel(AppTab.settings.title)
        }
        .tint(.red)
    }
}

private enum AppTab: Hashable {
    case pokedex
    case shiny
    case settings

    var title: String {
        switch self {
        case .pokedex:
            return "Pokedex"
        case .shiny:
            return "Shiny"
        case .settings:
            return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .pokedex:
            return "book.pages.fill"
        case .shiny:
            return "sparkles"
        case .settings:
            return "gearshape.fill"
        }
    }
}

private struct PokedexView: View {
    var body: some View {
        RoutePlaceholderView(
            title: "Pokedex",
            path: "/pokedex",
            iconName: AppTab.pokedex.iconName
        )
    }
}

private struct ShinyView: View {
    var body: some View {
        RoutePlaceholderView(
            title: "Shiny",
            path: "/shiny",
            iconName: AppTab.shiny.iconName
        )
    }
}

private struct SettingsView: View {
    var body: some View {
        RoutePlaceholderView(
            title: "Settings",
            path: "/settings",
            iconName: AppTab.settings.iconName
        )
    }
}

private struct RoutePlaceholderView: View {
    let title: String
    let path: String
    let iconName: String

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: iconName)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.red)

                    Text(path)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
}
