//
//  DiscordAccountLink.swift
//  UniversalDex
//
//  Created by Codex on 10/05/2026.
//

import Foundation

struct DiscordAccountLink: Codable, Equatable {
    let userID: UUID
    let discordUserID: String
    let discordUsername: String?
    let discordAvatarURL: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case discordUserID = "discord_user_id"
        case discordUsername = "discord_username"
        case discordAvatarURL = "discord_avatar_url"
    }

    var displayName: String {
        let trimmedUsername = discordUsername?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedUsername.isEmpty ? "Discord user \(discordUserID)" : trimmedUsername
    }
}
