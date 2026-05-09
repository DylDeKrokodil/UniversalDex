//
//  AppRootView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var authViewModel: AuthViewModel

    @State private var selectedTab = AppTab.home
    @StateObject private var shinyHuntViewModel: ShinyHuntViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel

        let store: any ShinyHuntStore
        if authViewModel.authenticatedUser != nil {
            store = SupabaseShinyHuntStore()
        } else {
            store = LocalShinyHuntStore()
        }

        _shinyHuntViewModel = StateObject(
            wrappedValue: ShinyHuntViewModel(store: store)
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tab.makeContent(
                    shinyHuntViewModel: shinyHuntViewModel,
                    selectedTab: $selectedTab,
                    authViewModel: authViewModel
                )
                    .tag(tab)
                    .tabItem {
                        Image(systemName: tab.iconName)
                    }
                    .accessibilityLabel(tab.title)
            }
        }
        .tint(AppTheme.accentColor)
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView(authViewModel: AuthViewModel())
    }
}
