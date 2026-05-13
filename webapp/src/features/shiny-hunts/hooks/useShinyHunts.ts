import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";
import { ShinyHunt } from "../types";
import { tracksTime } from "../utils/tracking";

export function useShinyHunts() {
  const queryClient = useQueryClient();

  const huntsQuery = useQuery({
    queryKey: ["shiny-hunts"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("shiny_hunts")
        .select("*")
        .order("created_at", { ascending: false });

      if (error) throw error;
      return data as ShinyHunt[];
    },
  });

  const incrementMutation = useMutation({
    mutationFn: async ({ huntId, delta }: { huntId: string; delta: number }) => {
      // Fetch current value for atomic-like update on server
      const { data: hunt, error: fetchError } = await supabase
        .from("shiny_hunts")
        .select("encounters,tracking_metric,timer_started_at,started_at")
        .eq("id", huntId)
        .single();

      if (fetchError) throw fetchError;

      const now = new Date().toISOString();
      const shouldStartTimer = delta > 0 && tracksTime(hunt) && !hunt.timer_started_at;
      const updates = {
        encounters: Math.max(0, hunt.encounters + delta),
        ...(shouldStartTimer
          ? {
              timer_started_at: now,
              started_at: hunt.started_at ?? now,
            }
          : {}),
      };

      const { error: updateError } = await supabase
        .from("shiny_hunts")
        .update(updates)
        .eq("id", huntId);

      if (updateError) throw updateError;
      
      const { data: userData } = await supabase.auth.getUser();
      if (userData.user) {
        await supabase.from("shiny_encounter_events").insert({
          hunt_id: huntId,
          user_id: userData.user.id,
          delta,
          kind: delta > 0 ? "increment" : "decrement",
        });
      }
    },
    onMutate: async ({ huntId, delta }) => {
      // Cancel any outgoing refetches (so they don't overwrite our optimistic update)
      await queryClient.cancelQueries({ queryKey: ["shiny-hunts"] });

      // Snapshot the previous value
      const previousHunts = queryClient.getQueryData<ShinyHunt[]>(["shiny-hunts"]);
      const now = new Date().toISOString();

      // Optimistically update to the new value
      queryClient.setQueryData<ShinyHunt[]>(["shiny-hunts"], (old) => 
        old?.map(hunt => {
          if (hunt.id !== huntId) return hunt;

          const shouldStartTimer = delta > 0 && tracksTime(hunt) && !hunt.timer_started_at;

          return {
            ...hunt,
            encounters: Math.max(0, hunt.encounters + delta),
            ...(shouldStartTimer
              ? {
                  started_at: hunt.started_at ?? now,
                  timer_started_at: now,
                }
              : {}),
          };
        })
      );

      // Return a context object with the snapshotted value
      return { previousHunts };
    },
    onError: (err, newInfo, context) => {
      // If the mutation fails, use the context returned from onMutate to roll back
      if (context?.previousHunts) {
        queryClient.setQueryData(["shiny-hunts"], context.previousHunts);
      }
    },
    onSettled: () => {
      // Always refetch after error or success to allow the server to be the source of truth
      queryClient.invalidateQueries({ queryKey: ["shiny-hunts"] });
    },
  });

  const completeMutation = useMutation({
    mutationFn: async ({ huntId, completion }: { huntId: string; completion: any }) => {
      const { error } = await supabase
        .from("shiny_hunts")
        .update({ 
          is_caught: true,
          caught_at: completion.caughtAt,
          completion_nickname: completion.nickname,
          completion_ball: completion.ball,
          completion_encounters: completion.encounters,
          completion_elapsed_time: completion.elapsedTime,
          completion_is_failed: completion.isFailed,
          elapsed_time: completion.elapsedTime,
          timer_started_at: null
        })
        .eq("id", huntId);

      if (error) throw error;
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["shiny-hunts"] });
    },
  });

  const timerMutation = useMutation({
    mutationFn: async ({ huntId, shouldRun }: { huntId: string; shouldRun: boolean }) => {
      const { data: hunt, error: fetchError } = await supabase
        .from("shiny_hunts")
        .select("elapsed_time,timer_started_at,started_at")
        .eq("id", huntId)
        .single();

      if (fetchError) throw fetchError;

      const now = new Date();

      if (shouldRun) {
        const { error } = await supabase
          .from("shiny_hunts")
          .update({
            timer_started_at: now.toISOString(),
            started_at: hunt.started_at ?? now.toISOString(),
          })
          .eq("id", huntId);

        if (error) throw error;
        return;
      }

      const startedAt = hunt.timer_started_at ? new Date(hunt.timer_started_at).getTime() : null;
      const elapsedSinceStart = startedAt ? Math.max(0, (now.getTime() - startedAt) / 1000) : 0;

      const { error } = await supabase
        .from("shiny_hunts")
        .update({
          elapsed_time: Math.max(0, hunt.elapsed_time + elapsedSinceStart),
          timer_started_at: null,
        })
        .eq("id", huntId);

      if (error) throw error;
    },
    onMutate: async ({ huntId, shouldRun }) => {
      await queryClient.cancelQueries({ queryKey: ["shiny-hunts"] });

      const previousHunts = queryClient.getQueryData<ShinyHunt[]>(["shiny-hunts"]);
      const now = new Date();

      queryClient.setQueryData<ShinyHunt[]>(["shiny-hunts"], (old) =>
        old?.map((hunt) => {
          if (hunt.id !== huntId) return hunt;

          if (shouldRun) {
            return {
              ...hunt,
              started_at: hunt.started_at ?? now.toISOString(),
              timer_started_at: now.toISOString(),
            };
          }

          return {
            ...hunt,
            elapsed_time: hunt.timer_started_at
              ? hunt.elapsed_time + Math.max(0, (now.getTime() - new Date(hunt.timer_started_at).getTime()) / 1000)
              : hunt.elapsed_time,
            timer_started_at: null,
          };
        })
      );

      return { previousHunts };
    },
    onError: (err, newInfo, context) => {
      if (context?.previousHunts) {
        queryClient.setQueryData(["shiny-hunts"], context.previousHunts);
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["shiny-hunts"] });
    },
  });

  return {
    hunts: huntsQuery.data ?? [],
    isLoading: huntsQuery.isLoading,
    error: huntsQuery.error,
    increment: incrementMutation.mutate,
    toggleTimer: timerMutation.mutate,
    complete: completeMutation.mutate,
  };
}
