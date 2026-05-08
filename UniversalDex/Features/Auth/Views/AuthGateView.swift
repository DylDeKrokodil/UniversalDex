//
//  AuthGateView.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct AuthGateView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isUsingOfflineMode = false

    var body: some View {
        Group {
            if isUsingOfflineMode {
                AppRootView(authViewModel: viewModel)
            } else {
                switch viewModel.status {
                case .loading:
                    ProgressView("Loading account…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.screenBackground)
                case let .authenticated(user):
                    AppRootView(authViewModel: viewModel)
                        .id(user.id)
                case let .setupRequired(availability):
                    AuthView(
                        viewModel: viewModel,
                        availability: availability,
                        continueWithoutAuth: {
                            isUsingOfflineMode = true
                        }
                    )
                case .unauthenticated:
                    AuthView(
                        viewModel: viewModel,
                        availability: nil,
                        continueWithoutAuth: {
                            isUsingOfflineMode = true
                        }
                    )
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct AuthGateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthGateView()
    }
}
