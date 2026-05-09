//
//  UniversalDexApp.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

@main
struct UniversalDexApp: App {
    @AppStorage(AppAppearanceOption.storageKey)
    private var appearanceOption = AppAppearanceOption.automatic.rawValue

    init() {
        AppNetworkRequestLogger.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(selectedAppearanceOption.colorScheme)
        }
    }

    private var selectedAppearanceOption: AppAppearanceOption {
        AppAppearanceOption(rawValue: appearanceOption) ?? .automatic
    }
}
