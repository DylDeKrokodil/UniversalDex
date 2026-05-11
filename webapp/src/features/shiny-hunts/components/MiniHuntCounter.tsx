"use client";

import { ShinyHunt } from "../../types";
import styles from "./MiniHuntCounter.module.css";
import { Plus, Minus, X } from "lucide-react";
import { useKeyboardShortcuts } from "@/hooks/useKeyboardShortcuts";

interface Props {
  hunt: ShinyHunt;
  onIncrement: (delta: number) => void;
  onClose: () => void;
  targetWindow?: Window;
}

export default function MiniHuntCounter({ hunt, onIncrement, onClose, targetWindow }: Props) {
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
        <img 
          src={`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/${hunt.pokemon_id}.png`} 
          alt="" 
          className={styles.sprite}
        />
        <div className={styles.info}>
          <span className={styles.name}>{hunt.pokemon_name}</span>
          <span className={styles.game}>{hunt.game}</span>
        </div>
        <button onClick={onClose} className={styles.closeBtn}>
          <X size={16} />
        </button>
      </div>

      <div className={styles.counter}>
        <span className={styles.count}>{hunt.encounters.toLocaleString()}</span>
      </div>

      <div className={styles.actions}>
        <button 
          onClick={() => onIncrement(-1)} 
          className={styles.minusBtn}
          disabled={hunt.encounters === 0}
        >
          <Minus size={24} />
        </button>
        <button 
          onClick={() => onIncrement(hunt.encounter_increment)} 
          className={styles.plusBtn}
        >
          <Plus size={32} />
          <span>+{hunt.encounter_increment}</span>
        </button>
      </div>
    </div>
  );
}
