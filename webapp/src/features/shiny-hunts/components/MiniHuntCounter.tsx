"use client";

import { ShinyHunt } from "../types";
import styles from "./MiniHuntCounter.module.css";
import { Plus, Minus, X } from "lucide-react";
import { useKeyboardShortcuts } from "@/hooks/useKeyboardShortcuts";
import ShinySpriteImage from "./ShinySpriteImage";

interface Props {
  hunt: ShinyHunt;
  onIncrement: (delta: number) => void;
  onClose: () => void;
  targetWindow?: Window;
}

export default function MiniHuntCounter({ hunt, onIncrement, onClose, targetWindow }: Props) {
  const spritePokemonId = hunt.pokemon_form_id ?? hunt.pokemon_id;

  useKeyboardShortcuts((delta) => {
    if (delta >= 1) {
      onIncrement(hunt.encounter_increment);
    } else {
      onIncrement(-1);
    }
  }, targetWindow);

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div className={styles.info}>
          <span className={styles.name}>{hunt.pokemon_name}</span>
          <span className={styles.game}>{hunt.game}</span>
        </div>
        <button onClick={onClose} className={styles.closeBtn} aria-label="Close overlay">
          <X size={16} />
        </button>
      </div>

      <div className={styles.artwork}>
        <ShinySpriteImage
          pokemonId={spritePokemonId}
          gender={hunt.gender}
          alt={hunt.pokemon_name}
          className={styles.sprite}
        />
      </div>

      <div className={styles.counter}>
        <span className={styles.count}>{hunt.encounters.toLocaleString()}</span>
        <span className={styles.label}>Encounters</span>
      </div>

      <div className={styles.actions}>
        <button 
          onClick={() => onIncrement(-1)} 
          className={styles.minusBtn}
          disabled={hunt.encounters === 0}
          aria-label="Undo encounter"
        >
          <Minus size={24} />
        </button>
        <button 
          onClick={() => onIncrement(hunt.encounter_increment)} 
          className={styles.plusBtn}
          aria-label={`Add ${hunt.encounter_increment} encounter${hunt.encounter_increment === 1 ? "" : "s"}`}
        >
          <Plus size={32} />
          <span>+{hunt.encounter_increment}</span>
        </button>
      </div>
    </div>
  );
}
