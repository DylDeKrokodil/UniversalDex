import { ShinyHunt } from "../types";

export function tracksEncounters(hunt: Pick<ShinyHunt, "tracking_metric">): boolean {
  return hunt.tracking_metric === "encounters" || hunt.tracking_metric === "both";
}

export function tracksTime(hunt: Pick<ShinyHunt, "tracking_metric">): boolean {
  return hunt.tracking_metric === "time" || hunt.tracking_metric === "both";
}

export function totalElapsedSeconds(hunt: Pick<ShinyHunt, "elapsed_time" | "timer_started_at">): number {
  if (!hunt.timer_started_at) {
    return Math.max(0, Math.floor(hunt.elapsed_time));
  }

  const startedAt = new Date(hunt.timer_started_at).getTime();
  const elapsedSinceStart = Math.max(0, Math.floor((Date.now() - startedAt) / 1000));

  return Math.max(0, Math.floor(hunt.elapsed_time) + elapsedSinceStart);
}
