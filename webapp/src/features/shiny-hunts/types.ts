export type TrackingMetric = "encounters" | "time" | "both";
export type ShinyGender = "male" | "female" | "genderless";

export type ShinyCaughtBall = 
  | "poke" | "great" | "ultra" | "master" | "premier" | "luxury" | "heal" | "net" | "nest" | "dive" 
  | "dusk" | "quick" | "timer" | "repeat" | "dream" | "beast" | "fast" | "friend" | "lure" | "level" 
  | "heavy" | "love" | "moon" | "sport" | "safari" | "other";

export const BALL_DISPLAY_NAMES: Record<ShinyCaughtBall, string> = {
  poke: "Poké Ball",
  great: "Great Ball",
  ultra: "Ultra Ball",
  master: "Master Ball",
  premier: "Premier Ball",
  luxury: "Luxury Ball",
  heal: "Heal Ball",
  net: "Net Ball",
  nest: "Nest Ball",
  dive: "Dive Ball",
  dusk: "Dusk Ball",
  quick: "Quick Ball",
  timer: "Timer Ball",
  repeat: "Repeat Ball",
  dream: "Dream Ball",
  beast: "Beast Ball",
  fast: "Fast Ball",
  friend: "Friend Ball",
  lure: "Lure Ball",
  level: "Level Ball",
  heavy: "Heavy Ball",
  love: "Love Ball",
  moon: "Moon Ball",
  sport: "Sport Ball",
  safari: "Safari Ball",
  other: "Other"
};

export interface ShinyHunt {
  id: string;
  user_id: string;
  pokemon_id: number | null;
  pokemon_form_id: number | null;
  pokemon_name: string;
  hunt_name: string;
  game: string;
  method: string;
  tracking_metric: TrackingMetric;
  has_shiny_charm: boolean;
  odds_denominator: number;
  encounters: number;
  encounter_increment: number;
  started_at: string | null;
  elapsed_time: number;
  timer_started_at: string | null;
  is_caught: boolean;
  caught_at: string | null;
  completion_nickname: string | null;
  completion_ball: ShinyCaughtBall | null;
  completion_encounters: number | null;
  completion_elapsed_time: number | null;
  completion_is_failed: boolean;
  gender: ShinyGender;
  created_at: string;
}

export interface ShinyHuntCompletion {
  nickname: string;
  ball: ShinyCaughtBall;
  encounters: number;
  elapsedTime: number;
  caughtAt: string;
  isFailed: boolean;
}

export interface ShinyEncounterEvent {
  id: string;
  hunt_id: string;
  user_id: string;
  recorded_at: string;
  delta: number;
  kind: "increment" | "decrement" | "adjustment";
}
