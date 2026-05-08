//
//  RoutePlaceholderView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct RoutePlaceholderView: View {
    let tab: AppTab

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.screenBackground
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: tab.iconName)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(AppTheme.accentColor)

                    Text(tab.path)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(tab.title)
        }
    }
}

struct RoutePlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        RoutePlaceholderView(tab: .settings)
    }
}
