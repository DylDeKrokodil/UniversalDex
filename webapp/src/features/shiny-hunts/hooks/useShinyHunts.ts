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
      // Fetch current value for atomic-like update on server
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

      // Optimistically update to the new value
      queryClient.setQueryData<ShinyHunt[]>(["shiny-hunts"], (old) => 
        old?.map(hunt => 
          hunt.id === huntId 
            ? { ...hunt, encounters: Math.max(0, hunt.encounters + delta) } 
            : hunt
        )
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

  return {
    hunts: huntsQuery.data ?? [],
    isLoading: huntsQuery.isLoading,
    error: huntsQuery.error,
    increment: incrementMutation.mutate,
  };
}
