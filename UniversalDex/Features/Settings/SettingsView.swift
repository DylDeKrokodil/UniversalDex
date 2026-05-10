//
//  SettingsView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var authViewModel: AuthViewModel
    let onRequestSignIn: () -> Void

    @StateObject private var discordViewModel = DiscordNotificationSettingsViewModel()

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

                discordSection
            }
            .navigationTitle("Settings")
            .task(id: authViewModel.authenticatedUser?.id) {
                await discordViewModel.load(for: authViewModel.authenticatedUser)
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                Task {
                    await discordViewModel.load(for: authViewModel.authenticatedUser)
                }
            }
        }
    }

    private var appearanceSelection: Binding<AppAppearanceOption> {
        Binding(
            get: { AppAppearanceOption(rawValue: appearanceOption) ?? .automatic },
            set: { appearanceOption = $0.rawValue }
        )
    }

    @ViewBuilder
    private var discordSection: some View {
        Section {
            if authViewModel.authenticatedUser == nil {
                Text("Sign in to connect Discord shiny hunt notifications.")
                    .foregroundStyle(.secondary)

                Button("Sign In or Create Account", action: onRequestSignIn)
            } else if discordViewModel.isLoading {
                ProgressView("Loading Discord settings...")
            } else {
                LabeledContent("Status") {
                    Text(discordViewModel.isConnected ? "Connected" : "Not connected")
                        .foregroundStyle(discordViewModel.isConnected ? .green : .secondary)
                }

                if let accountLink = discordViewModel.accountLink {
                    LabeledContent("Account") {
                        Text(accountLink.displayName)
                    }
                }

                if let botInviteURL = discordViewModel.botInviteURL {
                    Button {
                        openURL(botInviteURL)
                    } label: {
                        Label("Invite UniversalDex Bot", systemImage: "plus.message")
                    }
                    .disabled(discordViewModel.isSaving)
                }

                if let errorMessage = discordViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                if let infoMessage = discordViewModel.infoMessage {
                    Text(infoMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task {
                        if let authorizationURL = await discordViewModel.makeDiscordAuthorizationURL() {
                            openURL(authorizationURL)
                        }
                    }
                } label: {
                    if discordViewModel.isSaving {
                        ProgressView()
                    } else {
                        Text(discordViewModel.isConnected ? "Reconnect Discord Account" : "Connect Discord Account")
                    }
                }
                .disabled(discordViewModel.isSaving)

                Button("Refresh Discord Link") {
                    Task {
                        await discordViewModel.refresh()
                    }
                }
                .disabled(discordViewModel.isSaving)

                if discordViewModel.isConnected {
                    Button("Disconnect Discord Account", role: .destructive) {
                        Task {
                            await discordViewModel.disconnect()
                        }
                    }
                    .disabled(discordViewModel.isSaving)
                }
            }
        } header: {
            Text("Discord")
        } footer: {
            Text("Connect your Discord account, invite the bot, then run /here in Discord where shiny hunt posts should be sent.")
        }
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
