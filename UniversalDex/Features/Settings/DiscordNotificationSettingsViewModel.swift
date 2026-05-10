//
//  DiscordNotificationSettingsViewModel.swift
//  UniversalDex
//
//  Created by Codex on 10/05/2026.
//

import Combine
import Foundation

@MainActor
final class DiscordNotificationSettingsViewModel: ObservableObject {
    @Published private(set) var destination: DiscordNotificationDestination?
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var displayName = ""
    @Published var webhookURL = ""
    @Published var isEnabled = true
    @Published var catchNotificationsEnabled = true
    @Published var milestoneNotificationsEnabled = true
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private let store: any DiscordNotificationDestinationStore
    private var loadedUserID: UUID?

    init(store: any DiscordNotificationDestinationStore = SupabaseDiscordNotificationDestinationStore()) {
        self.store = store
    }

    var hasDestination: Bool {
        destination != nil
    }

    var canSave: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            webhookURL.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("https://")
    }

    func load(for user: AuthenticatedUser?) async {
        errorMessage = nil
        infoMessage = nil

        guard let userID = uuid(from: user) else {
            loadedUserID = nil
            destination = nil
            resetForm()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let destinations = try await store.fetchDestinations(userID: userID)
            loadedUserID = userID
            destination = destinations.first
            apply(destination: destinations.first, userID: userID)
        } catch {
            destination = nil
            resetForm()
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Could not load Discord notification settings: \(error.localizedDescription)")
        }
    }

    func save() async {
        guard let loadedUserID else {
            errorMessage = "Sign in before connecting Discord notifications."
            return
        }

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWebhookURL = webhookURL.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedDisplayName.isEmpty else {
            errorMessage = "Enter a display name."
            return
        }

        guard isValidDiscordWebhookURL(trimmedWebhookURL) else {
            errorMessage = "Enter a valid Discord webhook URL."
            return
        }

        isSaving = true
        defer { isSaving = false }

        errorMessage = nil
        infoMessage = nil

        let savedDestination = DiscordNotificationDestination(
            id: destination?.id ?? UUID(),
            userID: loadedUserID,
            displayName: trimmedDisplayName,
            webhookURL: trimmedWebhookURL,
            isEnabled: isEnabled,
            catchNotificationsEnabled: catchNotificationsEnabled,
            milestoneNotificationsEnabled: milestoneNotificationsEnabled
        )

        do {
            try await store.upsert(savedDestination)
            destination = savedDestination
            displayName = trimmedDisplayName
            webhookURL = trimmedWebhookURL
            infoMessage = "Discord notifications saved."
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Could not save Discord notification settings: \(error.localizedDescription)")
        }
    }

    func disconnect() async {
        guard let destination else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        errorMessage = nil
        infoMessage = nil

        do {
            try await store.delete(destination)
            self.destination = nil
            resetForm()
            infoMessage = "Discord notifications disconnected."
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Could not disconnect Discord notifications: \(error.localizedDescription)")
        }
    }

    private func apply(destination: DiscordNotificationDestination?, userID: UUID) {
        if let destination {
            displayName = destination.displayName
            webhookURL = destination.webhookURL
            isEnabled = destination.isEnabled
            catchNotificationsEnabled = destination.catchNotificationsEnabled
            milestoneNotificationsEnabled = destination.milestoneNotificationsEnabled
        } else {
            displayName = "UniversalDex"
            webhookURL = ""
            isEnabled = true
            catchNotificationsEnabled = true
            milestoneNotificationsEnabled = true
        }

        loadedUserID = userID
    }

    private func resetForm() {
        displayName = "UniversalDex"
        webhookURL = ""
        isEnabled = true
        catchNotificationsEnabled = true
        milestoneNotificationsEnabled = true
    }

    private func uuid(from user: AuthenticatedUser?) -> UUID? {
        guard let id = user?.id else {
            return nil
        }

        return UUID(uuidString: id)
    }

    private func isValidDiscordWebhookURL(_ value: String) -> Bool {
        guard let url = URL(string: value),
              url.scheme == "https",
              let host = url.host?.lowercased(),
              host == "discord.com" || host == "discordapp.com" || host == "canary.discord.com" else {
            return false
        }

        return url.path.hasPrefix("/api/webhooks/")
    }

    private func displayMessage(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription,
           !description.isEmpty {
            return description
        }

        return error.localizedDescription
    }
}
