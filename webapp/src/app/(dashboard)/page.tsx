"use client";

import { useAuth } from "@/features/auth/AuthProvider";
import { useRouter } from "next/navigation";
import { useState, useCallback, useEffect } from "react";
import { useShinyHunts } from "@/features/shiny-hunts/hooks/useShinyHunts";
import { useKeyboardShortcuts } from "@/hooks/useKeyboardShortcuts";
import { useSettingsStore } from "@/store/settingsStore";
import ShinyHuntCard from "@/features/shiny-hunts/components/ShinyHuntCard";
import NewHuntModal from "@/features/shiny-hunts/components/NewHuntModal";
import styles from "./Dashboard.module.css";

export default function DashboardPage() {
  const { user, isLoading: authLoading } = useAuth();
  const { hunts, isLoading: huntsLoading, increment, complete } = useShinyHunts();
  const { lastHuntId } = useSettingsStore();
  const router = useRouter();
  const [isNewHuntModalOpen, setIsNewHuntModalOpen] = useState(false);

  const handleIncrement = useCallback((id: string, delta: number) => {
    increment({ huntId: id, delta });
  }, [increment]);

  const handleComplete = useCallback((id: string, completion: any) => {
    complete({ huntId: id, completion });
  }, [complete]);

  const handleShortcutIncrement = useCallback((delta: number) => {
    const targetHuntId = lastHuntId || (hunts.length !== 0 ? hunts[0].id : null);
    if (!targetHuntId) return;

    const hunt = hunts.find(h => h.id === targetHuntId);
    if (!hunt || hunt.is_caught) return;

    const finalDelta = delta >= 1 ? hunt.encounter_increment : -1;
    handleIncrement(targetHuntId, finalDelta);
  }, [hunts, lastHuntId, handleIncrement]);

  useKeyboardShortcuts(handleShortcutIncrement);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
    }
  }, [user, authLoading, router]);

  if (authLoading || (huntsLoading && !hunts.length)) {
    return (
      <main className={styles.loading}>
        <p>Loading your shiny hunts...</p>
      </main>
    );
  }

  if (!user) {
    return null;
  }

  const activeHunts = hunts.filter(h => !h.is_caught);
  const caughtHunts = hunts.filter(h => h.is_caught);

  return (
    <main className={styles.container}>
      <header className={styles.header}>
        <div>
          <h1>Your Hunt Deck</h1>
          <p>Manage your active shiny hunts across all games.</p>
        </div>
        <button onClick={() => setIsNewHuntModalOpen(true)} className={styles.addBtn}>New Hunt</button>
      </header>

      {hunts.length === 0 ? (
        <div className={styles.empty}>
          <p>You don't have any active hunts yet.</p>
          <button onClick={() => setIsNewHuntModalOpen(true)} className={styles.addBtn}>Start Your First Hunt</button>
        </div>
      ) : (
        <section className={styles.grid}>
          {activeHunts.map(hunt => (
            <ShinyHuntCard 
              key={hunt.id} 
              hunt={hunt} 
              onIncrement={handleIncrement}
              onComplete={handleComplete}
            />
          ))}
          
          {caughtHunts.length !== 0 && (
            <div className={styles.caughtSection}>
              <h2>Recently Caught</h2>
              <div className={styles.grid}>
                {caughtHunts.map(hunt => (
                  <ShinyHuntCard 
                    key={hunt.id} 
                    hunt={hunt} 
                    onIncrement={() => {}} 
                    onComplete={() => {}}
                  />
                ))}
              </div>
            </div>
          )}
        </section>
      )}

      <NewHuntModal 
        isOpen={isNewHuntModalOpen} 
        onClose={() => setIsNewHuntModalOpen(false)}
        onSuccess={() => {}}
      />
    </main>
  );
}
