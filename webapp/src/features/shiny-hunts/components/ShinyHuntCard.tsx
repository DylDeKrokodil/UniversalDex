import { ShinyHunt } from "../types";
import styles from "./ShinyHuntCard.module.css";
import { ExternalLink } from "lucide-react";
import { createRoot } from "react-dom/client";
import { useRef, useEffect } from "react";
import { useSettingsStore } from "@/store/settingsStore";
import MiniHuntCounter from "./MiniHuntCounter";

interface Props {
  hunt: ShinyHunt;
  onIncrement: (id: string, delta: number) => void;
}

export default function ShinyHuntCard({ hunt, onIncrement }: Props) {
  const progress = Math.min((hunt.encounters / hunt.odds_denominator) * 100, 100);
  const spriteUrl = `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/${hunt.pokemon_id}.png`;
  const { setLastHuntId } = useSettingsStore();
  
  // Use refs to handle the pop-out window and its React root
  const huntRef = useRef(hunt);
  const pipWindowRef = useRef<any>(null);
  const pipRootRef = useRef<any>(null);

  const handleIncrement = (id: string, delta: number) => {
    setLastHuntId(id);
    onIncrement(id, delta);
  };

  useEffect(() => {
    huntRef.current = hunt;
    // Immediately re-render the pop-out if it's open
    if (pipRootRef.current && pipWindowRef.current && !pipWindowRef.current.closed) {
      pipRootRef.current.render(
        <MiniHuntCounter 
          hunt={hunt} 
          onIncrement={(delta) => handleIncrement(hunt.id, delta)}
          onClose={() => pipWindowRef.current.close()}
          targetWindow={pipWindowRef.current}
        />
      );
    }
  }, [hunt, onIncrement]);

  // Clean up pop-out window if the component unmounts
  useEffect(() => {
    return () => {
      if (pipWindowRef.current && !pipWindowRef.current.closed) {
        pipWindowRef.current.close();
      }
    };
  }, []);

  const handlePopOut = async () => {
    if (pipWindowRef.current && !pipWindowRef.current.closed) {
      pipWindowRef.current.focus();
      return;
    }

    try {
      if ('documentPictureInPicture' in window) {
        // @ts-ignore - Document PiP API is still experimental in TS definitions
        pipWindowRef.current = await window.documentPictureInPicture.requestWindow({
          width: 320,
          height: 320,
        });
      } else {
        // Fallback for Firefox/Safari/Other browsers
        pipWindowRef.current = window.open("", "_blank", "width=320,height=350,menubar=no,toolbar=no,location=no,status=no,resizable=yes");
        
        if (!pipWindowRef.current) {
          alert("Pop-out window was blocked! Please allow pop-ups for this site to use the mini-counter.");
          return;
        }

        // Set up the fallback window document
        pipWindowRef.current.document.title = `Counter: ${hunt.pokemon_name}`;
        pipWindowRef.current.document.body.style.margin = "0";
        pipWindowRef.current.document.body.style.overflow = "hidden";
        pipWindowRef.current.document.body.style.backgroundColor = document.documentElement.classList.contains('dark') ? "#121212" : "#ffffff";
      }

      const pipWindow = pipWindowRef.current;

      // Copy styles to the new window
      [...document.styleSheets].forEach((styleSheet) => {
        try {
          const cssRules = [...styleSheet.cssRules].map((rule) => rule.cssText).join('');
          const style = document.createElement('style');
          style.textContent = cssRules;
          pipWindow.document.head.appendChild(style);
        } catch (e) {
          const link = document.createElement('link');
          if (styleSheet.href) {
            link.rel = 'stylesheet';
            link.href = styleSheet.href;
            pipWindow.document.head.appendChild(link);
          }
        }
      });

      // Inherit dark mode class
      if (document.documentElement.classList.contains('dark')) {
        pipWindow.document.documentElement.classList.add('dark');
      }

      pipRootRef.current = createRoot(pipWindow.document.body);
      
      const renderMini = () => {
        const currentHunt = huntRef.current;
        pipRootRef.current.render(
          <MiniHuntCounter 
            hunt={currentHunt} 
            onIncrement={(delta) => handleIncrement(currentHunt.id, delta)}
            onClose={() => pipWindow.close()}
            targetWindow={pipWindow}
          />
        );
      };

      renderMini();

      const cleanup = () => {
        try {
          if (pipRootRef.current) {
            pipRootRef.current.unmount();
          }
        } catch (e) {
          // Ignore unmount errors if window is already closed
        }
        pipRootRef.current = null;
        if (pipWindowRef.current === pipWindow) {
          pipWindowRef.current = null;
        }
      };

      pipWindow.addEventListener("pagehide", cleanup);
      pipWindow.addEventListener("beforeunload", cleanup);

    } catch (err) {
      console.error("Failed to open Pop-out window:", err);
    }
  };

  return (
    <div className={styles.card}>
      <div className={styles.header}>
        <div className={styles.pokemonInfo}>
          <div className={styles.spriteContainer}>
            <img src={spriteUrl} alt={hunt.pokemon_name} className={styles.sprite} />
          </div>
          <div className={styles.titleInfo}>
            <div className={styles.titleRow}>
              <h3>{hunt.hunt_name || hunt.pokemon_name}</h3>
              <button 
                onClick={handlePopOut} 
                className={styles.popOutBtn}
                title="Pop out counter"
              >
                <ExternalLink size={14} />
              </button>
            </div>
            <span className={styles.gameTag}>{hunt.game}</span>
          </div>
        </div>
        <div className={styles.encounters}>
          <span className={styles.count}>{hunt.encounters.toLocaleString()}</span>
          <span className={styles.label}>Encounters</span>
        </div>
      </div>

      <div className={styles.progressBar}>
        <div 
          className={styles.progressFill} 
          style={{ width: `${progress}%`, backgroundColor: hunt.is_caught ? "#4ade80" : "var(--accent)" }}
        />
      </div>

      <div className={styles.footer}>
        <div className={styles.odds}>
          <span>Odds: 1/{hunt.odds_denominator.toLocaleString()}</span>
        </div>
        <div className={styles.actions}>
          <button 
            onClick={() => handleIncrement(hunt.id, -1)}
            disabled={hunt.encounters === 0 || hunt.is_caught}
            className={styles.minorBtn}
          >
            -
          </button>
          <button 
            onClick={() => handleIncrement(hunt.id, hunt.encounter_increment)}
            disabled={hunt.is_caught}
            className={styles.majorBtn}
          >
            +{hunt.encounter_increment}
          </button>
        </div>
      </div>
    </div>
  );
}
