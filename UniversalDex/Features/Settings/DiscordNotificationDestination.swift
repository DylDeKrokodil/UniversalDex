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
    var displayName: String
    var webhookURL: String
    var isEnabled: Bool
    var catchNotificationsEnabled: Bool
    var milestoneNotificationsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case displayName = "display_name"
        case webhookURL = "webhook_url"
        case isEnabled = "is_enabled"
        case catchNotificationsEnabled = "catch_notifications_enabled"
        case milestoneNotificationsEnabled = "milestone_notifications_enabled"
    }

    init(
        id: UUID = UUID(),
        userID: UUID,
        displayName: String,
        webhookURL: String,
        isEnabled: Bool = true,
        catchNotificationsEnabled: Bool = true,
        milestoneNotificationsEnabled: Bool = true
    ) {
        self.id = id
        self.userID = userID
        self.displayName = displayName
        self.webhookURL = webhookURL
        self.isEnabled = isEnabled
        self.catchNotificationsEnabled = catchNotificationsEnabled
        self.milestoneNotificationsEnabled = milestoneNotificationsEnabled
    }
}
