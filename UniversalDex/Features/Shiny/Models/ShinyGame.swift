//
//  ShinyGame.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum ShinyGame: String, CaseIterable, Codable, Identifiable {
    case goldSilverCrystal
    case rubySapphireEmerald
    case fireRedLeafGreen
    case diamondPearlPlatinum
    case heartGoldSoulSilver
    case blackWhite
    case black2White2
    case xy
    case omegaRubyAlphaSapphire
    case sunMoon
    case ultraSunUltraMoon
    case letsGo
    case swordShield
    case brilliantDiamondShiningPearl
    case legendsArceus
    case scarletViolet

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .goldSilverCrystal:
            return "Gold, Silver, Crystal"
        case .rubySapphireEmerald:
            return "Ruby, Sapphire, Emerald"
        case .fireRedLeafGreen:
            return "FireRed, LeafGreen"
        case .diamondPearlPlatinum:
            return "Diamond, Pearl, Platinum"
        case .heartGoldSoulSilver:
            return "HeartGold, SoulSilver"
        case .blackWhite:
            return "Black, White"
        case .black2White2:
            return "Black 2, White 2"
        case .xy:
            return "X, Y"
        case .omegaRubyAlphaSapphire:
            return "Omega Ruby, Alpha Sapphire"
        case .sunMoon:
            return "Sun, Moon"
        case .ultraSunUltraMoon:
            return "Ultra Sun, Ultra Moon"
        case .letsGo:
            return "Let's Go"
        case .swordShield:
            return "Sword, Shield"
        case .brilliantDiamondShiningPearl:
            return "Brilliant Diamond, Shining Pearl"
        case .legendsArceus:
            return "Legends: Arceus"
        case .scarletViolet:
            return "Scarlet, Violet"
        }
    }

    var regionName: String {
        switch self {
        case .goldSilverCrystal, .heartGoldSoulSilver:
            return "Johto"
        case .rubySapphireEmerald, .omegaRubyAlphaSapphire:
            return "Hoenn"
        case .fireRedLeafGreen, .letsGo:
            return "Kanto"
        case .diamondPearlPlatinum, .brilliantDiamondShiningPearl, .legendsArceus:
            return "Sinnoh"
        case .blackWhite, .black2White2:
            return "Unova"
        case .xy:
            return "Kalos"
        case .sunMoon, .ultraSunUltraMoon:
            return "Alola"
        case .swordShield:
            return "Galar"
        case .scarletViolet:
            return "Paldea"
        }
    }

    var systemImageName: String {
        switch self {
        case .goldSilverCrystal:
            return "sparkle"
        case .rubySapphireEmerald:
            return "diamond.fill"
        case .fireRedLeafGreen:
            return "flame.fill"
        case .diamondPearlPlatinum:
            return "circle.hexagongrid.fill"
        case .heartGoldSoulSilver:
            return "heart.fill"
        case .blackWhite:
            return "circle.lefthalf.filled"
        case .black2White2:
            return "circle.righthalf.filled"
        case .xy:
            return "xmark"
        case .omegaRubyAlphaSapphire:
            return "seal.fill"
        case .sunMoon:
            return "sun.max.fill"
        case .ultraSunUltraMoon:
            return "sun.max.trianglebadge.exclamationmark.fill"
        case .letsGo:
            return "figure.walk.circle.fill"
        case .swordShield:
            return "shield.fill"
        case .brilliantDiamondShiningPearl:
            return "suit.diamond.fill"
        case .legendsArceus:
            return "book.closed.fill"
        case .scarletViolet:
            return "circle.grid.cross.fill"
        }
    }

    var baseOddsDenominator: Int {
        switch self {
        case .goldSilverCrystal,
             .rubySapphireEmerald,
             .fireRedLeafGreen,
             .diamondPearlPlatinum,
             .heartGoldSoulSilver,
             .blackWhite,
             .black2White2:
            return 8192
        case .xy,
             .omegaRubyAlphaSapphire,
             .sunMoon,
             .ultraSunUltraMoon,
             .letsGo,
             .swordShield,
             .brilliantDiamondShiningPearl,
             .legendsArceus,
             .scarletViolet:
            return 4096
        }
    }

    var supportsShinyCharm: Bool {
        switch self {
        case .black2White2,
             .xy,
             .omegaRubyAlphaSapphire,
             .sunMoon,
             .ultraSunUltraMoon,
             .letsGo,
             .swordShield,
             .brilliantDiamondShiningPearl,
             .legendsArceus,
             .scarletViolet:
            return true
        default:
            return false
        }
    }

    var generation: Int {
        switch self {
        case .goldSilverCrystal:
            return 2
        case .rubySapphireEmerald, .fireRedLeafGreen:
            return 3
        case .diamondPearlPlatinum, .heartGoldSoulSilver:
            return 4
        case .blackWhite, .black2White2:
            return 5
        case .xy, .omegaRubyAlphaSapphire:
            return 6
        case .sunMoon, .ultraSunUltraMoon, .letsGo:
            return 7
        case .swordShield, .brilliantDiamondShiningPearl, .legendsArceus:
            return 8
        case .scarletViolet:
            return 9
        }
    }

    func containsAvailablePokemon(_ pokemon: PokemonListItem) -> Bool {
        availablePokemonIDRange.contains(pokemon.id)
    }

    private var availablePokemonIDRange: ClosedRange<Int> {
        switch self {
        case .fireRedLeafGreen, .letsGo:
            return 1...151
        case .goldSilverCrystal:
            return 1...251
        case .heartGoldSoulSilver:
            return 1...493
        case .rubySapphireEmerald:
            return 1...386
        case .diamondPearlPlatinum, .brilliantDiamondShiningPearl:
            return 1...493
        case .blackWhite, .black2White2:
            return 1...649
        case .xy, .omegaRubyAlphaSapphire:
            return 1...721
        case .sunMoon, .ultraSunUltraMoon:
            return 1...809
        case .swordShield, .legendsArceus:
            return 1...905
        case .scarletViolet:
            return 1...1025
        }
    }
}
