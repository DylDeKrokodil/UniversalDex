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
    @Published private(set) var accountLink: DiscordAccountLink?
    @Published private(set) var botInviteURL: URL?
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private let accountLinkStore: any DiscordAccountLinkStore
    private var loadedUserID: UUID?

    init() {
        accountLinkStore = SupabaseDiscordAccountLinkStore()
    }

    init(
        accountLinkStore: any DiscordAccountLinkStore
    ) {
        self.accountLinkStore = accountLinkStore
    }

    var isConnected: Bool {
        accountLink != nil
    }

    func load(for user: AuthenticatedUser?) async {
        errorMessage = nil
        infoMessage = nil

        guard let userID = uuid(from: user) else {
            loadedUserID = nil
            accountLink = nil
            botInviteURL = nil
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            loadedUserID = userID
            accountLink = try await accountLinkStore.fetchAccountLink(userID: userID)
            botInviteURL = accountLink == nil ? nil : Self.discordBotInviteURL
        } catch {
            accountLink = nil
            botInviteURL = nil
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Could not load Discord notification settings: \(error.localizedDescription)")
        }
    }

    func makeDiscordAuthorizationURL() async -> URL? {
        isSaving = true
        defer { isSaving = false }

        errorMessage = nil
        infoMessage = nil

        do {
            let authorizationURL = try await accountLinkStore.startAccountLink()
            infoMessage = "Complete the Discord connection, then return here and refresh."
            return authorizationURL
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Could not start Discord account link: \(error.localizedDescription)")
            return nil
        }
    }

    func refresh() async {
        guard let loadedUserID else {
            return
        }

        await load(for: AuthenticatedUser(id: loadedUserID.uuidString, email: ""))
    }

    func disconnect() async {
        guard let loadedUserID else {
            errorMessage = "Sign in before disconnecting Discord."
            return
        }

        isSaving = true
        defer { isSaving = false }

        errorMessage = nil
        infoMessage = nil

        do {
            try await accountLinkStore.disconnectAccountLink(userID: loadedUserID)
            accountLink = nil
            botInviteURL = nil
            infoMessage = "Discord account disconnected."
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Could not disconnect Discord account: \(error.localizedDescription)")
        }
    }

    private func uuid(from user: AuthenticatedUser?) -> UUID? {
        guard let id = user?.id else {
            return nil
        }

        return UUID(uuidString: id)
    }

    private func displayMessage(for error: Error) -> String {
        if let localizedError = error as? LocalizedError,
           let description = localizedError.errorDescription,
           !description.isEmpty {
            return description
        }

        return error.localizedDescription
    }

    private static let discordBotInviteURL = URL(
        string: "https://discord.com/oauth2/authorize?client_id=1503014986325168323&permissions=19456&scope=bot%20applications.commands"
    )
}
