//
//  AuthView.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct AuthView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign In"
        case signUp = "Create Account"

        var id: String {
            rawValue
        }

        var actionTitle: String {
            switch self {
            case .signIn:
                return "Sign In"
            case .signUp:
                return "Create Account"
            }
        }
    }

    @ObservedObject var viewModel: AuthViewModel

    @State private var mode = Mode.signIn

    let availability: AuthAvailability?
    let continueWithoutAuth: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.accentColor.opacity(0.15),
                    AppTheme.screenBackground,
                    AppTheme.screenBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("UniversalDex")
                            .font(.system(size: 34, weight: .bold, design: .rounded))

                        Text("Sign in to sync your hunts across devices.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    if let availability, availability != .ready {
                        messageCard(
                            title: availability.title,
                            message: availability.message,
                            tint: .orange
                        )
                    }

                    if let infoMessage = viewModel.infoMessage {
                        messageCard(
                            title: "Almost there",
                            message: infoMessage,
                            tint: .green
                        )
                    }

                    if let errorMessage = viewModel.errorMessage {
                        messageCard(
                            title: "Could not continue",
                            message: errorMessage,
                            tint: .red
                        )
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Auth Mode", selection: $mode) {
                            ForEach(Mode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(availability == .sdkNotInstalled)

                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 16))

                            SecureField("Password", text: $viewModel.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding()
                                .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            Task {
                                switch mode {
                                case .signIn:
                                    await viewModel.signIn()
                                case .signUp:
                                    await viewModel.signUp()
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isWorking {
                                    ProgressView()
                                        .tint(.white)
                                }

                                Text(mode.actionTitle)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accentColor)
                        .disabled(viewModel.isWorking || availability == .sdkNotInstalled)

                        Button("Continue Without Sign In", action: continueWithoutAuth)
                            .buttonStyle(.bordered)
                    }
                    .padding(20)
                    .background(AppTheme.homeCardBackground, in: RoundedRectangle(cornerRadius: 28))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(AppTheme.homeCardBorder, lineWidth: 1)
                    }

                }
                .padding(24)
            }
        }
    }

    private func messageCard(title: String, message: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(tint)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(
            viewModel: AuthViewModel(),
            availability: .missingConfiguration,
            continueWithoutAuth: {}
        )
    }
}
