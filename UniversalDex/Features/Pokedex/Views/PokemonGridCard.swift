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

            PokemonImageView(urls: pokemon.artworkURLs)

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
