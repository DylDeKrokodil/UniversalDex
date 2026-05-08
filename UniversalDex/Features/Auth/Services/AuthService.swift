//
//  AuthService.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

enum AuthSignUpResult: Equatable {
    case signedIn(AuthenticatedUser)
    case requiresEmailConfirmation(email: String)
}

enum AuthServiceError: LocalizedError {
    case notConfigured
    case sdkNotInstalled
    case invalidSession

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Authentication is not configured yet."
        case .sdkNotInstalled:
            return "The authentication dependency has not been added to the app."
        case .invalidSession:
            return "The account session could not be loaded."
        }
    }
}

protocol AuthService {
    var availability: AuthAvailability { get }

    func currentUser() async -> AuthenticatedUser?
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signUp(email: String, password: String) async throws -> AuthSignUpResult
    func signOut() async throws
}
