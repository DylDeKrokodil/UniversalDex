//
//  AuthViewModel.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var status: AuthStatus = .loading
    @Published private(set) var isWorking = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private let authService: AuthService

    var authenticatedUser: AuthenticatedUser? {
        guard case let .authenticated(user) = status else {
            return nil
        }

        return user
    }

    init() {
        authService = SupabaseAuthService()
    }

    init(authService: AuthService) {
        self.authService = authService
    }

    func load() async {
        errorMessage = nil

        guard authService.availability == .ready else {
            status = .setupRequired(authService.availability)
            return
        }

        if let user = await authService.currentUser() {
            status = .authenticated(user)
        } else {
            status = .unauthenticated
        }
    }

    func signIn() async {
        guard validateCredentials() else {
            return
        }

        isWorking = true
        defer { isWorking = false }

        errorMessage = nil
        infoMessage = nil

        do {
            let user = try await authService.signIn(email: email, password: password)
            status = .authenticated(user)
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Sign in failed: \(error.localizedDescription)")
        }
    }

    func signUp() async {
        guard validateCredentials() else {
            return
        }

        isWorking = true
        defer { isWorking = false }

        errorMessage = nil
        infoMessage = nil

        do {
            let result = try await authService.signUp(email: email, password: password)

            switch result {
            case let .signedIn(user):
                status = .authenticated(user)
            case let .requiresEmailConfirmation(email):
                status = .unauthenticated
                infoMessage = "Check \(email) and confirm your email before signing in."
                password = ""
            }
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Sign up failed: \(error.localizedDescription)")
        }
    }

    func signOut() async {
        isWorking = true
        defer { isWorking = false }

        errorMessage = nil
        infoMessage = nil

        do {
            try await authService.signOut()
            password = ""
            status = .unauthenticated
        } catch {
            errorMessage = displayMessage(for: error)
            AppDebugLog.log("Sign out failed: \(error.localizedDescription)")
        }
    }

    private func validateCredentials() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            errorMessage = "Enter a valid email address."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        email = trimmedEmail
        return true
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
