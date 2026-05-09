//
//  LegalCreditsView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 09/05/2026.
//

import SwiftUI

struct LegalCreditsView: View {
    var body: some View {
        List {
            Section {
                Text("UniversalDex is an unofficial fan-made companion app and is not affiliated with, endorsed, sponsored, or approved by Nintendo, Creatures Inc., GAME FREAK inc., or The Pokémon Company.")
            } header: {
                Text("Unofficial App")
            }

            Section {
                Text("Pokémon, Pokémon character names, game names, sprites, artwork, and related assets are trademarks and/or copyrighted materials of their respective owners.")

                Text("Pokémon and Pokémon character names are trademarks of Nintendo.")
            } header: {
                Text("Pokémon")
            }

            Section {
                Text("Pokémon data and sprite references are provided through PokéAPI. PokéAPI is created by Paul Hallett and other PokéAPI contributors and is licensed under the BSD 3-Clause License.")
            } header: {
                Text("Data & Sprites")
            }

            Section {
                Link(destination: URL(string: "https://pokeapi.co/docs/v2")!) {
                    Label("PokéAPI Documentation", systemImage: "link")
                }

                Link(destination: URL(string: "https://github.com/PokeAPI/pokeapi/blob/master/LICENSE.md")!) {
                    Label("PokéAPI License", systemImage: "doc.text")
                }

                Link(destination: URL(string: "https://www.pokemon.com/uk/legal/information")!) {
                    Label("Pokémon Legal Information", systemImage: "building.columns")
                }
            } header: {
                Text("Links")
            } footer: {
                Text("This page is provided for attribution and transparency. It is not legal advice.")
            }
        }
        .navigationTitle("Legal & Credits")
    }
}

struct LegalCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LegalCreditsView()
        }
    }
}
