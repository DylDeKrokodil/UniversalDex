//
//  ShinyGame.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum ShinyGame: String, CaseIterable, Codable, Identifiable {
    case gold
    case silver
    case crystal
    case ruby
    case sapphire
    case emerald
    case fireRed
    case leafGreen
    case diamond
    case pearl
    case platinum
    case heartGold
    case soulSilver
    case black
    case white
    case black2
    case white2
    case x
    case y
    case omegaRuby
    case alphaSapphire
    case sun
    case moon
    case ultraSun
    case ultraMoon
    case letsGoPikachu
    case letsGoEevee
    case sword
    case shield
    case brilliantDiamond
    case shiningPearl
    case legendsArceus
    case scarlet
    case violet

    private enum GameFamily {
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
    }

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .gold:
            return "Gold"
        case .silver:
            return "Silver"
        case .crystal:
            return "Crystal"
        case .ruby:
            return "Ruby"
        case .sapphire:
            return "Sapphire"
        case .emerald:
            return "Emerald"
        case .fireRed:
            return "FireRed"
        case .leafGreen:
            return "LeafGreen"
        case .diamond:
            return "Diamond"
        case .pearl:
            return "Pearl"
        case .platinum:
            return "Platinum"
        case .heartGold:
            return "HeartGold"
        case .soulSilver:
            return "SoulSilver"
        case .black:
            return "Black"
        case .white:
            return "White"
        case .black2:
            return "Black 2"
        case .white2:
            return "White 2"
        case .x:
            return "X"
        case .y:
            return "Y"
        case .omegaRuby:
            return "Omega Ruby"
        case .alphaSapphire:
            return "Alpha Sapphire"
        case .sun:
            return "Sun"
        case .moon:
            return "Moon"
        case .ultraSun:
            return "Ultra Sun"
        case .ultraMoon:
            return "Ultra Moon"
        case .letsGoPikachu:
            return "Let's Go, Pikachu!"
        case .letsGoEevee:
            return "Let's Go, Eevee!"
        case .sword:
            return "Sword"
        case .shield:
            return "Shield"
        case .brilliantDiamond:
            return "Brilliant Diamond"
        case .shiningPearl:
            return "Shining Pearl"
        case .legendsArceus:
            return "Legends: Arceus"
        case .scarlet:
            return "Scarlet"
        case .violet:
            return "Violet"
        }
    }

    var regionName: String {
        switch family {
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
        switch family {
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
        switch family {
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
        switch family {
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
        switch family {
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

    func shinySpriteURL(for pokemonID: Int) -> URL? {
        guard let shinySpritePath else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/\(shinySpritePath)/\(pokemonID).png")
    }

    func animatedShinySpriteURL(for pokemonID: Int) -> URL? {
        guard let animatedShinySpritePath else {
            return nil
        }

        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/\(animatedShinySpritePath)/\(pokemonID).gif")
    }

    private var family: GameFamily {
        switch self {
        case .gold, .silver, .crystal:
            return .goldSilverCrystal
        case .ruby, .sapphire, .emerald:
            return .rubySapphireEmerald
        case .fireRed, .leafGreen:
            return .fireRedLeafGreen
        case .diamond, .pearl, .platinum:
            return .diamondPearlPlatinum
        case .heartGold, .soulSilver:
            return .heartGoldSoulSilver
        case .black, .white:
            return .blackWhite
        case .black2, .white2:
            return .black2White2
        case .x, .y:
            return .xy
        case .omegaRuby, .alphaSapphire:
            return .omegaRubyAlphaSapphire
        case .sun, .moon:
            return .sunMoon
        case .ultraSun, .ultraMoon:
            return .ultraSunUltraMoon
        case .letsGoPikachu, .letsGoEevee:
            return .letsGo
        case .sword, .shield:
            return .swordShield
        case .brilliantDiamond, .shiningPearl:
            return .brilliantDiamondShiningPearl
        case .legendsArceus:
            return .legendsArceus
        case .scarlet, .violet:
            return .scarletViolet
        }
    }

    private var availablePokemonIDRange: ClosedRange<Int> {
        switch family {
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

    private var shinySpritePath: String? {
        switch self {
        case .gold:
            return "generation-ii/gold/shiny"
        case .silver:
            return "generation-ii/silver/shiny"
        case .crystal:
            return "generation-ii/crystal/shiny"
        case .ruby, .sapphire:
            return "generation-iii/ruby-sapphire/shiny"
        case .emerald:
            return "generation-iii/emerald/shiny"
        case .fireRed, .leafGreen:
            return "generation-iii/firered-leafgreen/shiny"
        case .diamond, .pearl:
            return "generation-iv/diamond-pearl/shiny"
        case .platinum:
            return "generation-iv/platinum/shiny"
        case .heartGold, .soulSilver:
            return "generation-iv/heartgold-soulsilver/shiny"
        case .black, .white, .black2, .white2:
            return "generation-v/black-white/shiny"
        case .x, .y:
            return "generation-vi/x-y/shiny"
        case .omegaRuby, .alphaSapphire:
            return "generation-vi/omegaruby-alphasapphire/shiny"
        case .sun, .moon, .ultraSun, .ultraMoon:
            return "generation-vii/ultra-sun-ultra-moon/shiny"
        case .letsGoPikachu,
             .letsGoEevee,
             .sword,
             .shield,
             .brilliantDiamond,
             .shiningPearl,
             .legendsArceus,
             .scarlet,
             .violet:
            return nil
        }
    }

    private var animatedShinySpritePath: String? {
        switch self {
        case .crystal:
            return "generation-ii/crystal/animated/shiny"
        case .black, .white, .black2, .white2:
            return "generation-v/black-white/animated/shiny"
        default:
            return nil
        }
    }
}
