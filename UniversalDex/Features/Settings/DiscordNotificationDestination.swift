//
//  DiscordNotificationDestination.swift
//  UniversalDex
//
//  Created by Codex on 10/05/2026.
//

import Foundation

struct DiscordNotificationDestination: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    var discordUserID: String?
    var discordGuildID: String?
    var discordChannelID: String?
    var displayName: String
    var webhookURL: String?
    var isEnabled: Bool
    var catchNotificationsEnabled: Bool
    var milestoneNotificationsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case discordUserID = "discord_user_id"
        case discordGuildID = "discord_guild_id"
        case discordChannelID = "discord_channel_id"
        case displayName = "display_name"
        case webhookURL = "webhook_url"
        case isEnabled = "is_enabled"
        case catchNotificationsEnabled = "catch_notifications_enabled"
        case milestoneNotificationsEnabled = "milestone_notifications_enabled"
    }

    init(
        id: UUID = UUID(),
        userID: UUID,
        discordUserID: String? = nil,
        discordGuildID: String? = nil,
        discordChannelID: String? = nil,
        displayName: String,
        webhookURL: String? = nil,
        isEnabled: Bool = true,
        catchNotificationsEnabled: Bool = true,
        milestoneNotificationsEnabled: Bool = true
    ) {
        self.id = id
        self.userID = userID
        self.discordUserID = discordUserID
        self.discordGuildID = discordGuildID
        self.discordChannelID = discordChannelID
        self.displayName = displayName
        self.webhookURL = webhookURL
        self.isEnabled = isEnabled
        self.catchNotificationsEnabled = catchNotificationsEnabled
        self.milestoneNotificationsEnabled = milestoneNotificationsEnabled
    }
}
