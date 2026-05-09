//
//  ShinyMethodPickerList.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct ShinyMethodPickerList: View {
    @Environment(\.dismiss) private var dismiss

    let selectedGame: ShinyGame
    let selectedPokemon: PokemonListItem?
    let methods: [ShinyMethod]
    var hasShinyCharm = false
    let selectMethod: (ShinyMethod) -> Void

    var body: some View {
        List {
            if let selectedPokemon {
                Section("Pokemon") {
                    ShinyPokemonPickerRow(pokemon: selectedPokemon, showsChevron: false)
                }
            }

            Section("Methods for \(selectedGame.displayName)") {
                ForEach(methods) { method in
                    Button {
                        selectMethod(method)
                        dismiss()
                    } label: {
                        ShinyMethodPickerRow(
                            method: method,
                            oddsText: method.oddsText(in: selectedGame, hasShinyCharm: hasShinyCharm),
                            note: method.note(in: selectedGame)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Select Method")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShinyMethodPickerRow: View {
    let method: ShinyMethod
    let oddsText: String
    let note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(method.displayName)
                    .foregroundStyle(.primary)

                Spacer()

                Text(oddsText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.accentColor)
            }

            Text(note)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
