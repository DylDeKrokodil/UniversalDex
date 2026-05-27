"use client";

import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/lib/supabase";
import ShinySpriteImage from "@/features/shiny-hunts/components/ShinySpriteImage";
import { ShinyGender, TrackingMetric } from "@/features/shiny-hunts/types";
import { OverlayOptions } from "@/features/shiny-hunts/utils/overlayOptions";
import styles from "./Overlay.module.css";

interface OverlayHunt {
  pokemon_id: number | null;
  pokemon_form_id: number | null;
  pokemon_name: string;
  hunt_name: string;
  gender: ShinyGender;
  game: string;
  encounters: number;
  encounter_increment: number;
  tracking_metric: TrackingMetric;
  is_caught: boolean;
}

interface Props {
  token: string;
  options: OverlayOptions;
}

export default function OverlayClient({ token, options }: Props) {
  const [hunt, setHunt] = useState<OverlayHunt | null>(null);
  const [error, setError] = useState<string | null>(null);
  const overlayClassName = [
    styles.overlay,
    styles[options.layout],
    styles[options.size],
    styles[options.theme],
    !options.showSprite ? styles.noSprite : "",
  ].filter(Boolean).join(" ");

  const spritePokemonId = useMemo(() => {
    if (!hunt) return null;
    return hunt.pokemon_form_id ?? hunt.pokemon_id;
  }, [hunt]);

  useEffect(() => {
    let isMounted = true;

    async function loadOverlay() {
      try {
        const response = await fetch(`/api/overlays/${token}`, {
          cache: "no-store",
        });

        if (!response.ok) {
          throw new Error("Overlay unavailable");
        }

        const data = (await response.json()) as OverlayHunt;

        if (isMounted) {
          setHunt(data);
          setError(null);
        }
      } catch {
        if (isMounted) {
          setError("Overlay unavailable");
        }
      }
    }

    loadOverlay();

    const channel = supabase
      .channel(`overlay:${token}`)
      .on("broadcast", { event: "overlay-update" }, ({ payload }) => {
        if (isMounted) {
          setHunt(payload as OverlayHunt);
          setError(null);
        }
      })
      .subscribe();

    return () => {
      isMounted = false;
      supabase.removeChannel(channel);
    };
  }, [token]);

  if (error) {
    return (
      <main className={styles.page}>
        <OverlayGlobalStyles />
        <div className={styles.error}>{error}</div>
      </main>
    );
  }

  if (!hunt) {
    return (
      <main className={styles.page}>
        <OverlayGlobalStyles />
        <div className={styles.loading}>Loading</div>
      </main>
    );
  }

  return (
    <main className={styles.page}>
      <OverlayGlobalStyles />
      <section className={overlayClassName} aria-label={`${hunt.pokemon_name} shiny hunt overlay`}>
        {options.showSprite && (
          <div className={styles.artwork}>
            <ShinySpriteImage
              pokemonId={spritePokemonId}
              gender={hunt.gender}
              alt={hunt.pokemon_name}
              className={styles.sprite}
            />
          </div>
        )}
        <div className={styles.content}>
          {options.showName && (
            <span className={styles.name}>{hunt.hunt_name || hunt.pokemon_name}</span>
          )}
          <span className={styles.count}>{hunt.encounters.toLocaleString()}</span>
          {options.showLabel && <span className={styles.label}>Encounters</span>}
          {options.showGame && <span className={styles.game}>{hunt.game}</span>}
        </div>
      </section>
    </main>
  );
}

function OverlayGlobalStyles() {
  return (
    <style jsx global>{`
      html,
      body {
        background: transparent;
      }
    `}</style>
  );
}
