//
//  SettingsView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let user = authViewModel.authenticatedUser {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.email)
                                .font(.headline)

                            Text("Signed in")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button("Sign Out", role: .destructive) {
                            Task {
                                await authViewModel.signOut()
                            }
                        }
                    } else {
                        Text("You are browsing without an account.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(authViewModel: AuthViewModel())
    }
}
