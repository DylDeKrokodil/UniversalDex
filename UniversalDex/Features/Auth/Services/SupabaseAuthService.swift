//
//  SupabaseAuthService.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

#if canImport(Supabase)
import Supabase

struct SupabaseAuthService: AuthService {
    let availability: AuthAvailability

    private let client: SupabaseClient?

    init(configuration: SupabaseConfiguration? = SupabaseConfiguration.load()) {
        guard let configuration else {
            self.client = nil
            self.availability = .missingConfiguration
            return
        }

        self.client = SupabaseClient(
            supabaseURL: configuration.url,
            supabaseKey: configuration.anonKey,
            options: .init(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
        self.availability = .ready
    }

    func currentUser() async -> AuthenticatedUser? {
        guard let currentUser = client?.auth.currentSession?.user else {
            return nil
        }

        return mapUser(id: currentUser.id, email: currentUser.email)
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        guard let client else {
            throw AuthServiceError.notConfigured
        }

        try await client.auth.signIn(
            email: email,
            password: password
        )

        return try await authenticatedUser(from: client)
    }

    func signUp(email: String, password: String) async throws -> AuthSignUpResult {
        guard let client else {
            throw AuthServiceError.notConfigured
        }

        try await client.auth.signUp(
            email: email,
            password: password
        )

        if let session = try? await client.auth.session {
            return .signedIn(mapUser(id: session.user.id, email: session.user.email))
        }

        return .requiresEmailConfirmation(email: email)
    }

    func signOut() async throws {
        guard let client else {
            throw AuthServiceError.notConfigured
        }

        try await client.auth.signOut()
    }

    private func authenticatedUser(from client: SupabaseClient) async throws -> AuthenticatedUser {
        let session = try await client.auth.session
        return mapUser(id: session.user.id, email: session.user.email)
    }

    private func mapUser(id: some CustomStringConvertible, email: String?) -> AuthenticatedUser {
        AuthenticatedUser(
            id: String(describing: id),
            email: email ?? "No email"
        )
    }
}
#else
struct SupabaseAuthService: AuthService {
    let availability: AuthAvailability = .sdkNotInstalled

    init(configuration _: SupabaseConfiguration? = nil) {}

    func currentUser() async -> AuthenticatedUser? {
        nil
    }

    func signIn(email _: String, password _: String) async throws -> AuthenticatedUser {
        throw AuthServiceError.sdkNotInstalled
    }

    func signUp(email _: String, password _: String) async throws -> AuthSignUpResult {
        throw AuthServiceError.sdkNotInstalled
    }

    func signOut() async throws {
        throw AuthServiceError.sdkNotInstalled
    }
}
#endif
