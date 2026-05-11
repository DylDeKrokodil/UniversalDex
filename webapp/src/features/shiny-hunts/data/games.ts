export type ShinyGame = 
  | "gold" | "silver" | "crystal"
  | "ruby" | "sapphire" | "emerald"
  | "fireRed" | "leafGreen"
  | "diamond" | "pearl" | "platinum"
  | "heartGold" | "soulSilver"
  | "black" | "white"
  | "black2" | "white2"
  | "x" | "y"
  | "omegaRuby" | "alphaSapphire"
  | "sun" | "moon"
  | "ultraSun" | "ultraMoon"
  | "letsGoPikachu" | "letsGoEevee"
  | "sword" | "shield"
  | "brilliantDiamond" | "shiningPearl"
  | "legendsArceus"
  | "scarlet" | "violet";

export interface GameInfo {
  displayName: string;
  baseOdds: number;
  supportsCharm: boolean;
  generation: number;
}

export const GAMES: Record<ShinyGame, GameInfo> = {
  gold: { displayName: "Gold", baseOdds: 8192, supportsCharm: false, generation: 2 },
  silver: { displayName: "Silver", baseOdds: 8192, supportsCharm: false, generation: 2 },
  crystal: { displayName: "Crystal", baseOdds: 8192, supportsCharm: false, generation: 2 },
  ruby: { displayName: "Ruby", baseOdds: 8192, supportsCharm: false, generation: 3 },
  sapphire: { displayName: "Sapphire", baseOdds: 8192, supportsCharm: false, generation: 3 },
  emerald: { displayName: "Emerald", baseOdds: 8192, supportsCharm: false, generation: 3 },
  fireRed: { displayName: "FireRed", baseOdds: 8192, supportsCharm: false, generation: 3 },
  leafGreen: { displayName: "LeafGreen", baseOdds: 8192, supportsCharm: false, generation: 3 },
  diamond: { displayName: "Diamond", baseOdds: 8192, supportsCharm: false, generation: 4 },
  pearl: { displayName: "Pearl", baseOdds: 8192, supportsCharm: false, generation: 4 },
  platinum: { displayName: "Platinum", baseOdds: 8192, supportsCharm: false, generation: 4 },
  heartGold: { displayName: "HeartGold", baseOdds: 8192, supportsCharm: false, generation: 4 },
  soulSilver: { displayName: "SoulSilver", baseOdds: 8192, supportsCharm: false, generation: 4 },
  black: { displayName: "Black", baseOdds: 8192, supportsCharm: false, generation: 5 },
  white: { displayName: "White", baseOdds: 8192, supportsCharm: false, generation: 5 },
  black2: { displayName: "Black 2", baseOdds: 8192, supportsCharm: true, generation: 5 },
  white2: { displayName: "White 2", baseOdds: 8192, supportsCharm: true, generation: 5 },
  x: { displayName: "X", baseOdds: 4096, supportsCharm: true, generation: 6 },
  y: { displayName: "Y", baseOdds: 4096, supportsCharm: true, generation: 6 },
  omegaRuby: { displayName: "Omega Ruby", baseOdds: 4096, supportsCharm: true, generation: 6 },
  alphaSapphire: { displayName: "Alpha Sapphire", baseOdds: 4096, supportsCharm: true, generation: 6 },
  sun: { displayName: "Sun", baseOdds: 4096, supportsCharm: true, generation: 7 },
  moon: { displayName: "Moon", baseOdds: 4096, supportsCharm: true, generation: 7 },
  ultraSun: { displayName: "Ultra Sun", baseOdds: 4096, supportsCharm: true, generation: 7 },
  ultraMoon: { displayName: "Ultra Moon", baseOdds: 4096, supportsCharm: true, generation: 7 },
  letsGoPikachu: { displayName: "Let's Go, Pikachu!", baseOdds: 4096, supportsCharm: true, generation: 7 },
  letsGoEevee: { displayName: "Let's Go, Eevee!", baseOdds: 4096, supportsCharm: true, generation: 7 },
  sword: { displayName: "Sword", baseOdds: 4096, supportsCharm: true, generation: 8 },
  shield: { displayName: "Shield", baseOdds: 4096, supportsCharm: true, generation: 8 },
  brilliantDiamond: { displayName: "Brilliant Diamond", baseOdds: 4096, supportsCharm: true, generation: 8 },
  shiningPearl: { displayName: "Shining Pearl", baseOdds: 4096, supportsCharm: true, generation: 8 },
  legendsArceus: { displayName: "Legends: Arceus", baseOdds: 4096, supportsCharm: true, generation: 8 },
  scarlet: { displayName: "Scarlet", baseOdds: 4096, supportsCharm: true, generation: 9 },
  violet: { displayName: "Violet", baseOdds: 4096, supportsCharm: true, generation: 9 },
};
