"use client";

import { useAuth } from "@/features/auth/AuthProvider";
import { useRouter } from "next/navigation";
import { useEffect, useCallback } from "react";
import { useShinyHunts } from "@/features/shiny-hunts/hooks/useShinyHunts";
import { useKeyboardShortcuts } from "@/hooks/useKeyboardShortcuts";
import { useSettingsStore } from "@/store/settingsStore";
import ShinyHuntCard from "@/features/shiny-hunts/components/ShinyHuntCard";
import styles from "./Dashboard.module.css";

import Link from "next/link";

export default function DashboardPage() {
  const { user, isLoading: authLoading } = useAuth();
  const { hunts, isLoading: huntsLoading, increment } = useShinyHunts();
  const { lastHuntId } = useSettingsStore();
  const router = useRouter();

  const handleIncrement = useCallback((id: string, delta: number) => {
    increment({ huntId: id, delta });
  }, [increment]);

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
        <Link href="/new" className={styles.addBtn}>New Hunt</Link>
      </header>

      {hunts.length === 0 ? (
        <div className={styles.empty}>
          <p>You don't have any active hunts yet.</p>
          <Link href="/new" className={styles.addBtn}>Start Your First Hunt</Link>
        </div>
      ) : (
        <section className={styles.grid}>
          {activeHunts.map(hunt => (
            <ShinyHuntCard 
              key={hunt.id} 
              hunt={hunt} 
              onIncrement={handleIncrement}
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
                  />
                ))}
              </div>
            </div>
          )}
        </section>
      )}
    </main>
  );
}
