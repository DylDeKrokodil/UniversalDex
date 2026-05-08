//
//  ShinyGamePickerList.swift
//  UniversalDex
//
//  Created by Codex on 08/05/2026.
//

import SwiftUI

struct ShinyGamePickerList: View {
    let games: [ShinyGame]
    let selectGame: (ShinyGame) -> Void

    init(
        games: [ShinyGame] = ShinyGame.allCases,
        selectGame: @escaping (ShinyGame) -> Void
    ) {
        self.games = games
        self.selectGame = selectGame
    }

    var body: some View {
        List {
            Section {
                ForEach(games) { game in
                    Button {
                        selectGame(game)
                    } label: {
                        ShinyGamePickerRow(game: game)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ShinyGamePickerRow: View {
    let game: ShinyGame

    var body: some View {
        HStack(spacing: 12) {
            ShinyGameIconView(game: game)

            VStack(alignment: .leading, spacing: 3) {
                Text(game.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(game.regionName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ShinyPickerChevron()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
