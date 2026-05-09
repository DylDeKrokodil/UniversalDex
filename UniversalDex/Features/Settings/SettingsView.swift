//
//  SettingsView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let onRequestSignIn: () -> Void

    @AppStorage(AppAppearanceOption.storageKey)
    private var appearanceOption = AppAppearanceOption.automatic.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Mode", selection: appearanceSelection) {
                        ForEach(AppAppearanceOption.allCases) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Auto follows your device appearance.")
                }

                Section("About") {
                    NavigationLink {
                        LegalCreditsView()
                    } label: {
                        Label("Legal & Credits", systemImage: "info.circle")
                    }
                }

                Section("Account") {
                    if let user = authViewModel.authenticatedUser {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.email)
                                .font(.headline)

                            Text("Signed in")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button("Sign Out", role: .destructive) {
                            Task {
                                await authViewModel.signOut()
                            }
                        }
                    } else {
                        Text("You are browsing without an account.")
                            .foregroundStyle(.secondary)

                        Button("Sign In or Create Account", action: onRequestSignIn)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var appearanceSelection: Binding<AppAppearanceOption> {
        Binding(
            get: { AppAppearanceOption(rawValue: appearanceOption) ?? .automatic },
            set: { appearanceOption = $0.rawValue }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            authViewModel: AuthViewModel(),
            onRequestSignIn: {}
        )
    }
}
