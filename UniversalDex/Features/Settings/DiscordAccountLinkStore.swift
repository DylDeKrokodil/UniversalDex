//
//  DiscordAccountLinkStore.swift
//  UniversalDex
//
//  Created by Codex on 10/05/2026.
//

import Foundation

protocol DiscordAccountLinkStore {
    func fetchAccountLink(userID: UUID) async throws -> DiscordAccountLink?
    func startAccountLink() async throws -> URL
    func disconnectAccountLink(userID: UUID) async throws
}

enum DiscordAccountLinkStoreError: LocalizedError {
    case notConfigured
    case missingAuthorizationURL
    case requestFailed(String)
    case sdkNotInstalled

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Discord account linking is not configured yet."
        case .missingAuthorizationURL:
            return "Discord did not return a connection URL."
        case let .requestFailed(message):
            return message
        case .sdkNotInstalled:
            return "The Supabase SDK is not installed."
        }
    }
}

#if canImport(Supabase)
import Supabase

struct SupabaseDiscordAccountLinkStore: DiscordAccountLinkStore {
    private let configuration: SupabaseConfiguration?
    private let client: SupabaseClient?

    init(configuration: SupabaseConfiguration? = SupabaseConfiguration.load()) {
        self.configuration = configuration

        guard let configuration else {
            client = nil
            return
        }

        client = SupabaseClientFactory.makeClient(configuration: configuration)
    }

    func fetchAccountLink(userID: UUID) async throws -> DiscordAccountLink? {
        let client = try requireClient()

        let rows: [DiscordAccountLink] = try await client
            .from("discord_account_links")
            .select()
            .eq("user_id", value: userID.uuidString)
            .limit(1)
            .execute()
            .value

        return rows.first
    }

    func startAccountLink() async throws -> URL {
        guard let configuration else {
            throw DiscordAccountLinkStoreError.notConfigured
        }

        let client = try requireClient()
        let session = try await client.auth.session
        let url = configuration.url.appendingPathComponent("functions/v1/discord-oauth-start")
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        try validate(response: response, data: data)

        let startResponse = try JSONDecoder().decode(DiscordOAuthStartResponse.self, from: data)

        guard let authorizationURL = URL(string: startResponse.authorizationURL) else {
            throw DiscordAccountLinkStoreError.missingAuthorizationURL
        }

        return authorizationURL
    }

    func disconnectAccountLink(userID: UUID) async throws {
        let client = try requireClient()

        try await client
            .from("discord_account_links")
            .delete()
            .eq("user_id", value: userID.uuidString)
            .execute()
    }

    private func requireClient() throws -> SupabaseClient {
        guard let client else {
            throw DiscordAccountLinkStoreError.notConfigured
        }

        return client
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "Discord connection request failed."
            throw DiscordAccountLinkStoreError.requestFailed(message)
        }
    }
}

private struct DiscordOAuthStartResponse: Decodable {
    let authorizationURL: String

    enum CodingKeys: String, CodingKey {
        case authorizationURL = "authorization_url"
    }
}

#else
struct SupabaseDiscordAccountLinkStore: DiscordAccountLinkStore {
    init(configuration _: SupabaseConfiguration? = nil) {}

    func fetchAccountLink(userID _: UUID) async throws -> DiscordAccountLink? {
        throw DiscordAccountLinkStoreError.sdkNotInstalled
    }

    func startAccountLink() async throws -> URL {
        throw DiscordAccountLinkStoreError.sdkNotInstalled
    }

    func disconnectAccountLink(userID _: UUID) async throws {
        throw DiscordAccountLinkStoreError.sdkNotInstalled
    }
}
#endif
