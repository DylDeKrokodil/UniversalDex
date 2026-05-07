//
//  PokemonGridCard.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

struct PokemonGridCard: View {
    let pokemon: PokemonListItem

    var body: some View {
        VStack(spacing: 8) {
            Text(pokemon.formattedNumber)
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            PokemonArtworkView(url: pokemon.artworkURL)

            Text(pokemon.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .aspectRatio(0.78, contentMode: .fit)
        .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PokemonGridCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            PokemonGridCard(pokemon: PokemonListItem(id: 1, name: "bulbasaur"))
            PokemonGridCard(pokemon: PokemonListItem(id: 25, name: "pikachu"))
            PokemonGridCard(pokemon: PokemonListItem(id: 150, name: "mewtwo"))
        }
        .padding()
        .background(AppTheme.screenBackground)
    }
}
