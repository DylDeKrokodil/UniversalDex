//
//  ShinyMethod.swift
//  UniversalDex
//
//  Created by Dylan de Groot on 05/05/2026.
//

import Foundation

enum ShinyMethod: String, CaseIterable, Codable, Identifiable {
    case randomEncounter
    case shinyCharm
    case masuda
    case masudaCharm
    case pokeRadarChain40
    case chainFishing
    case friendSafari
    case dexNav
    case sosBattle
    case catchCombo31
    case dynamaxAdventure
    case massOutbreak
    case massiveMassOutbreak
    case sandwichCharmOutbreak
    case customOdds

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        case .randomEncounter:
            return "Random encounter"
        case .shinyCharm:
            return "Shiny Charm"
        case .masuda:
            return "Masuda Method"
        case .masudaCharm:
            return "Masuda + Charm"
        case .pokeRadarChain40:
            return "Poke Radar chain 40"
        case .chainFishing:
            return "Chain fishing"
        case .friendSafari:
            return "Friend Safari"
        case .dexNav:
            return "DexNav"
        case .sosBattle:
            return "SOS chain"
        case .catchCombo31:
            return "Catch combo 31+"
        case .dynamaxAdventure:
            return "Dynamax Adventure"
        case .massOutbreak:
            return "Mass outbreak"
        case .massiveMassOutbreak:
            return "Massive mass outbreak"
        case .sandwichCharmOutbreak:
            return "Sparkling + Charm + Outbreak"
        case .customOdds:
            return "Custom odds"
        }
    }

    var dashboardLabel: String {
        switch self {
        case .randomEncounter:
            return "Random"
        case .shinyCharm:
            return "Charm"
        case .masuda:
            return "Masuda"
        case .masudaCharm:
            return "Masuda + Charm"
        case .pokeRadarChain40:
            return "Radar"
        case .chainFishing:
            return "Chain Fishing"
        case .friendSafari:
            return "Safari"
        case .dexNav:
            return "DexNav"
        case .sosBattle:
            return "SOS"
        case .catchCombo31:
            return "Catch Combo"
        case .dynamaxAdventure:
            return "Dynamax"
        case .massOutbreak:
            return "Outbreak"
        case .massiveMassOutbreak:
            return "MMO"
        case .sandwichCharmOutbreak:
            return "Sandwich + Charm"
        case .customOdds:
            return "Custom"
        }
    }

    func isAvailable(in game: ShinyGame) -> Bool {
        switch self {
        case .randomEncounter:
            return true
        case .shinyCharm:
            return game.supportsShinyCharm
        case .masuda:
            return game.generation >= 4
        case .masudaCharm:
            return game.supportsShinyCharm && game.generation >= 5
        case .pokeRadarChain40:
            return [.diamondPearlPlatinum, .xy, .brilliantDiamondShiningPearl].contains(game)
        case .chainFishing:
            return game == .xy || game == .omegaRubyAlphaSapphire
        case .friendSafari:
            return game == .xy
        case .dexNav:
            return game == .omegaRubyAlphaSapphire
        case .sosBattle:
            return game == .sunMoon || game == .ultraSunUltraMoon
        case .catchCombo31:
            return game == .letsGo
        case .dynamaxAdventure:
            return game == .swordShield
        case .massOutbreak:
            return game == .legendsArceus || game == .scarletViolet
        case .massiveMassOutbreak:
            return game == .legendsArceus
        case .sandwichCharmOutbreak:
            return game == .scarletViolet
        case .customOdds:
            return true
        }
    }

    func oddsDenominator(in game: ShinyGame) -> Int {
        switch self {
        case .randomEncounter:
            return game.baseOddsDenominator
        case .shinyCharm:
            return game.baseOddsDenominator == 8192 ? 2731 : 1365
        case .masuda:
            if game.generation == 4 {
                return 1638
            }

            return game.generation == 5 ? 1365 : 683
        case .masudaCharm:
            return game.generation == 5 ? 1024 : 512
        case .pokeRadarChain40:
            return 200
        case .chainFishing:
            return 100
        case .friendSafari:
            return 512
        case .dexNav:
            return 512
        case .sosBattle:
            return game == .ultraSunUltraMoon ? 273 : 315
        case .catchCombo31:
            return 341
        case .dynamaxAdventure:
            return 300
        case .massOutbreak:
            return game == .legendsArceus ? 158 : 1365
        case .massiveMassOutbreak:
            return 216
        case .sandwichCharmOutbreak:
            return 512
        case .customOdds:
            return game.baseOddsDenominator
        }
    }

    func oddsText(in game: ShinyGame) -> String {
        "1/\(oddsDenominator(in: game).formatted())"
    }

    func note(in game: ShinyGame) -> String {
        switch self {
        case .randomEncounter:
            return "Base odds for wild encounters, gifts, fossils, and similar one-roll hunts."
        case .shinyCharm:
            return "Uses the game generation's common Shiny Charm encounter odds."
        case .masuda:
            return "For breeding with compatible Pokemon from different language games."
        case .masudaCharm:
            return "For Masuda breeding while the save file has the Shiny Charm."
        case .pokeRadarChain40:
            return "Best-case Poke Radar odds around a chain of 40."
        case .chainFishing:
            return "Approximate best chain fishing odds once the chain is built."
        case .friendSafari:
            return "Friend Safari has boosted shiny odds in Pokemon X and Y."
        case .dexNav:
            return "Approximate boosted DexNav hunting odds at high search levels."
        case .sosBattle:
            return game == .ultraSunUltraMoon ? "Ultra Sun and Ultra Moon SOS chains can reach stronger boosted odds." : "Sun and Moon SOS chaining odds at the boosted chain stage."
        case .catchCombo31:
            return "Let's Go catch combo odds at 31 or higher without extra lure/charm modifiers."
        case .dynamaxAdventure:
            return "Dynamax Adventure odds without the Shiny Charm."
        case .massOutbreak:
            return game == .legendsArceus ? "Legends: Arceus mass outbreak odds before charm and perfect dex modifiers." : "Scarlet and Violet mass outbreak odds before sandwich/charm stacking."
        case .massiveMassOutbreak:
            return "Legends: Arceus massive mass outbreak odds before charm and perfect dex modifiers."
        case .sandwichCharmOutbreak:
            return "Scarlet and Violet odds for Sparkling Power, Shiny Charm, and a cleared 60+ outbreak."
        case .customOdds:
            return "Use this for event hunts, stacked modifiers, or any setup the preset list does not cover yet."
        }
    }
}
