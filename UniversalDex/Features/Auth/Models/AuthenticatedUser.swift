//
//  AuthenticatedUser.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import Foundation

struct AuthenticatedUser: Equatable {
    let id: String
    let email: String
}

enum AuthAvailability: Equatable {
    case ready
    case missingConfiguration
    case sdkNotInstalled

    var title: String {
        switch self {
        case .ready:
            return "Ready"
        case .missingConfiguration:
            return "Configuration needed"
        case .sdkNotInstalled:
            return "Dependency needed"
        }
    }

    var message: String {
        switch self {
        case .ready:
            return "Authentication is ready."
        case .missingConfiguration:
            return "Create a local config file from the example file and add your project URL and publishable key."
        case .sdkNotInstalled:
            return "Add the required authentication package in Xcode before the app can connect."
        }
    }
}

enum AuthStatus: Equatable {
    case loading
    case unauthenticated
    case authenticated(AuthenticatedUser)
    case setupRequired(AuthAvailability)
}
