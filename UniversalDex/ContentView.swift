//
//  ContentView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.10, blue: 0.18),
                    Color(red: 0.10, green: 0.25, blue: 0.32),
                    Color(red: 0.95, green: 0.29, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Image(systemName: "sparkles")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.pulse)

                VStack(spacing: 10) {
                    Text("UniversalDex")
                        .font(.largeTitle.weight(.bold))

                    Text("Your creature companion starts here.")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.82))
                        .multilineTextAlignment(.center)
                }

                Button {
                } label: {
                    Label("Open Dex", systemImage: "book.pages.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
                .foregroundStyle(.black)
                .padding(.top, 12)
            }
            .foregroundStyle(.white)
            .padding(32)
            .frame(maxWidth: 420)
        }
    }
}

#Preview {
    ContentView()
}
