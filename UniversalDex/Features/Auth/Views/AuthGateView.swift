//
//  AuthGateView.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct AuthGateView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isShowingOpeningScreen = true

    var body: some View {
        ZStack {
            destinationView
                .opacity(isShowingOpeningScreen ? 0 : 1)

            if isShowingOpeningScreen {
                AppLaunchView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            async let minimumOpeningScreenDuration: Void = Self.waitForOpeningScreen()
            await viewModel.load()

            await minimumOpeningScreenDuration

            withAnimation(.easeInOut(duration: 0.38)) {
                isShowingOpeningScreen = false
            }
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch viewModel.status {
        case .loading:
            ProgressView("Loading account…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.screenBackground)
        case let .authenticated(user):
            AppRootView(
                authViewModel: viewModel,
                onRequestSignIn: showAuthView
            )
                .id(user.id)
        case let .setupRequired(availability):
            AuthView(
                viewModel: viewModel,
                availability: availability
            )
        case .unauthenticated:
            AuthView(
                viewModel: viewModel,
                availability: nil
            )
        }
    }

    private func showAuthView() {
        Task {
            await viewModel.load()
        }
    }

    private static func waitForOpeningScreen() async {
        do {
            try await Task.sleep(nanoseconds: 2_200_000_000)
        } catch {
            return
        }
    }
}

struct AuthGateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthGateView()
    }
}
