import { ShinyGame, GAMES } from "./games";

export type ShinyMethod =
  | "randomEncounter"
  | "shinyCharm"
  | "masuda"
  | "masudaCharm"
  | "pokeRadarChain40"
  | "chainFishing"
  | "friendSafari"
  | "dexNav"
  | "sosBattle"
  | "catchCombo31"
  | "dynamaxAdventure"
  | "massOutbreak"
  | "massiveMassOutbreak"
  | "sandwichCharmOutbreak";

export interface MethodInfo {
  displayName: string;
}

export const METHODS: Record<ShinyMethod, MethodInfo> = {
  randomEncounter: { displayName: "Random encounter" },
  shinyCharm: { displayName: "Shiny Charm" },
  masuda: { displayName: "Masuda Method" },
  masudaCharm: { displayName: "Masuda + Charm" },
  pokeRadarChain40: { displayName: "Poke Radar chain 40" },
  chainFishing: { displayName: "Chain fishing" },
  friendSafari: { displayName: "Friend Safari" },
  dexNav: { displayName: "DexNav" },
  sosBattle: { displayName: "SOS chain" },
  catchCombo31: { displayName: "Catch combo 31+" },
  dynamaxAdventure: { displayName: "Dynamax Adventure" },
  massOutbreak: { displayName: "Mass outbreak" },
  massiveMassOutbreak: { displayName: "Massive mass outbreak" },
  sandwichCharmOutbreak: { displayName: "Sparkling + Charm + Outbreak" },
};

export function isMethodAvailable(method: ShinyMethod, game: ShinyGame): boolean {
  const info = GAMES[game];
  if (!info) return false;
  switch (method) {
    case "randomEncounter": return true;
    case "shinyCharm": return info.supportsCharm;
    case "masuda": return info.generation >= 4;
    case "masudaCharm": return info.supportsCharm && info.generation >= 5;
    case "pokeRadarChain40":
      return ["diamond", "pearl", "platinum", "x", "y", "brilliantDiamond", "shiningPearl"].includes(game);
    case "chainFishing":
      return ["x", "y", "omegaRuby", "alphaSapphire"].includes(game);
    case "friendSafari":
      return ["x", "y"].includes(game);
    case "dexNav":
      return ["omegaRuby", "alphaSapphire"].includes(game);
    case "sosBattle":
      return ["sun", "moon", "ultraSun", "ultraMoon"].includes(game);
    case "catchCombo31":
      return ["letsGoPikachu", "letsGoEevee"].includes(game);
    case "dynamaxAdventure":
      return ["sword", "shield"].includes(game);
    case "massOutbreak":
      return ["legendsArceus", "scarlet", "violet"].includes(game);
    case "massiveMassOutbreak":
      return game === "legendsArceus";
    case "sandwichCharmOutbreak":
      return ["scarlet", "violet"].includes(game);
    default: return false;
  }
}

export function calculateOdds(method: ShinyMethod, game: ShinyGame, hasShinyCharm: boolean): number {
  const info = GAMES[game];
  if (!info) return 4096;
  
  if (hasShinyCharm && info.supportsCharm) {
    switch (method) {
      case "randomEncounter": return info.baseOdds === 8192 ? 2731 : 1365;
      case "masuda": return info.generation === 5 ? 1024 : 512;
      case "dynamaxAdventure": return 100;
      case "massOutbreak":
        if (game === "legendsArceus") return 137;
        if (["scarlet", "violet"].includes(game)) return 819;
        break;
      case "massiveMassOutbreak":
        if (game === "legendsArceus") return 180;
        break;
    }
  }

  switch (method) {
    case "randomEncounter": return info.baseOdds;
    case "shinyCharm": return info.baseOdds === 8192 ? 2731 : 1365;
    case "masuda":
      if (info.generation === 4) return 1638;
      return info.generation === 5 ? 1365 : 683;
    case "masudaCharm": return info.generation === 5 ? 1024 : 512;
    case "pokeRadarChain40": return 200;
    case "chainFishing": return 100;
    case "friendSafari": return 512;
    case "dexNav": return 512;
    case "sosBattle": return ["ultraSun", "ultraMoon"].includes(game) ? 273 : 315;
    case "catchCombo31": return 341;
    case "dynamaxAdventure": return 300;
    case "massOutbreak": return game === "legendsArceus" ? 158 : 1365;
    case "massiveMassOutbreak": return 216;
    case "sandwichCharmOutbreak": return 512;
    default: return info.baseOdds;
  }
}
