//
//  PokemonListRow.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokemonListRow: View {
    let pokemon: PokemonListItem

    var body: some View {
        HStack(spacing: 16) {
            PokemonArtworkView(url: pokemon.artworkURL)

            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(pokemon.formattedNumber)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

private struct PokemonArtworkView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 56, height: 56)
        .background(AppTheme.artworkBackground, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct PokemonListRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PokemonListRow(pokemon: PokemonListItem(id: 25, name: "pikachu"))
        }
    }
}
