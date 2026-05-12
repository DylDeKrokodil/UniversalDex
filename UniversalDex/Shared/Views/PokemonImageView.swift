//
//  PokemonImageView.swift
//  UniversalDex
//
//  Created by Gemini on 11/05/2026.
//

import SwiftUI

struct PokemonImageView: View {
    let urls: [URL]
    var placeholderSystemName: String = "questionmark.circle.fill"

    var body: some View {
        if urls.isEmpty {
            fallbackImage
        } else {
            RecursiveImageView(urls: urls, placeholderSystemName: placeholderSystemName)
        }
    }

    private var fallbackImage: some View {
        Image("PokemonEgg")
            .resizable()
            .scaledToFit()
    }
}

private struct RecursiveImageView: View {
    let urls: [URL]
    let placeholderSystemName: String

    var body: some View {
        AsyncImage(url: urls.first) { phase in
            switch phase {
            case .empty:
                Image("PokemonEgg")
                    .resizable()
                    .scaledToFit()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                let remaining = Array(urls.dropFirst())
                if !remaining.isEmpty {
                    RecursiveImageView(urls: remaining, placeholderSystemName: placeholderSystemName)
                } else {
                    Image("PokemonEgg")
                        .resizable()
                        .scaledToFit()
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}
