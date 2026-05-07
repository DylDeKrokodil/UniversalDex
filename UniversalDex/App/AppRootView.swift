//
//  AppRootView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct AppRootView: View {
    @State private var selectedTab = AppTab.pokedex

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tab.content
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
        AppRootView()
    }
}
