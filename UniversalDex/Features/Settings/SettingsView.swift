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
                    Text(discordViewModel.hasDestination ? "Connected" : "Not connected")
                        .foregroundStyle(discordViewModel.hasDestination ? .green : .secondary)
                }

                TextField("Display name", text: $discordViewModel.displayName)
                    .textInputAutocapitalization(.words)
                    .disabled(discordViewModel.isSaving)

                TextField("Discord webhook URL", text: $discordViewModel.webhookURL)
                    .textInputAutocapitalization(.never)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .disabled(discordViewModel.isSaving)

                Toggle("Discord notifications", isOn: $discordViewModel.isEnabled)
                    .disabled(discordViewModel.isSaving)

                Toggle("Milestone posts", isOn: $discordViewModel.milestoneNotificationsEnabled)
                    .disabled(!discordViewModel.isEnabled || discordViewModel.isSaving)

                Toggle("Catch posts", isOn: $discordViewModel.catchNotificationsEnabled)
                    .disabled(!discordViewModel.isEnabled || discordViewModel.isSaving)

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
                        await discordViewModel.save()
                    }
                } label: {
                    if discordViewModel.isSaving {
                        ProgressView()
                    } else {
                        Text(discordViewModel.hasDestination ? "Save Discord Settings" : "Connect Discord Webhook")
                    }
                }
                .disabled(!discordViewModel.canSave || discordViewModel.isSaving)

                if discordViewModel.hasDestination {
                    Button("Disconnect Discord Notifications", role: .destructive) {
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
            Text("Posts shiny hunt milestones and catches to the connected Discord channel.")
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
