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
    func makeContent(
        shinyHuntViewModel: ShinyHuntViewModel,
        selectedTab: Binding<AppTab>,
        authViewModel: AuthViewModel,
        onRequestSignIn: @escaping () -> Void
    ) -> some View {
        switch self {
        case .home:
            HomeView(
                viewModel: shinyHuntViewModel,
                selectedTab: selectedTab
            )
        case .shiny:
            ShinyView(viewModel: shinyHuntViewModel)
        case .settings:
            SettingsView(
                authViewModel: authViewModel,
                onRequestSignIn: onRequestSignIn
            )
        }
    }
}
