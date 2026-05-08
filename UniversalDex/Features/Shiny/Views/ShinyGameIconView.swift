//
//  ShinyGameIconView.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 08/05/2026.
//

import SwiftUI

struct ShinyGameIconView: View {
    let game: ShinyGame
    var size: CGFloat = 34

    var body: some View {
        Image(systemName: game.systemImageName)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(AppTheme.accentColor)
            .frame(width: size, height: size)
            .background(AppTheme.accentColor.opacity(0.12), in: Circle())
            .accessibilityHidden(true)
    }
}

struct ShinyGameIconView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ForEach(ShinyGame.allCases.prefix(6)) { game in
                ShinyGameIconView(game: game)
            }
        }
        .padding()
    }
}
