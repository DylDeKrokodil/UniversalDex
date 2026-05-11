import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";
import { ShinyHunt } from "../types";

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
      // In a real app, you'd use a RPC or a transaction to ensure atomic updates
      // and create the encounter event. For now, simple update:
      const { data: hunt, error: fetchError } = await supabase
        .from("shiny_hunts")
        .select("encounters")
        .eq("id", huntId)
        .single();

      if (fetchError) throw fetchError;

      const { error: updateError } = await supabase
        .from("shiny_hunts")
        .update({ encounters: hunt.encounters + delta })
        .eq("id", huntId);

      if (updateError) throw updateError;
      
      // Add encounter event
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
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["shiny-hunts"] });
    },
  });

  return {
    hunts: huntsQuery.data ?? [],
    isLoading: huntsQuery.isLoading,
    error: huntsQuery.error,
    increment: incrementMutation.mutate,
  };
}
