//
//  AppTheme.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import SwiftUI

enum AppTheme {
    static let accentColor = Color.red
    static let screenBackground = Color(.systemGroupedBackground)
    static let artworkBackground = Color(.secondarySystemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    static let homeBackgroundTop = screenBackground
    static let homeBackgroundBottom = Color(.secondarySystemGroupedBackground)
    static let homeCardBackground = cardBackground
    static let homeArchiveBackground = cardBackground
    static let homeCardBorder = Color.primary.opacity(0.08)
    static let homeMutedText = Color.secondary
    static let homeAccentStrong = accentColor
    static let homeAccent = accentColor.opacity(0.88)
    static let homeAccentSoft = Color.orange
    static let homeOddsText = Color.blue
    static let homeChipBackground = accentColor.opacity(0.12)
    static let homeChipText = accentColor
    static let homePositiveBackground = Color.green.opacity(0.14)
    static let homePositiveText = Color.green
}
