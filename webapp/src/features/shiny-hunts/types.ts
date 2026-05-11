export type TrackingMetric = "encounters" | "time" | "both";

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
  completion_ball: string | null;
  completion_encounters: number | null;
  completion_elapsed_time: number | null;
  completion_is_failed: boolean;
  gender?: "male" | "female" | "genderless";
  created_at: string;
}

export interface ShinyEncounterEvent {
  id: string;
  hunt_id: string;
  user_id: string;
  recorded_at: string;
  delta: number;
  kind: "increment" | "decrement" | "adjustment";
}
