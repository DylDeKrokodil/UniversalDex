import { ShinyHunt, ShinyHuntCompletion, BALL_DISPLAY_NAMES } from "../types";
import styles from "./ShinyHuntCard.module.css";
import { ExternalLink, CheckCircle } from "lucide-react";
import { createRoot } from "react-dom/client";
import { useRef, useEffect, useCallback, useState } from "react";
import { useSettingsStore } from "@/store/settingsStore";
import MiniHuntCounter from "./MiniHuntCounter";
import CompletionModal from "./CompletionModal";
import ShinySpriteImage from "./ShinySpriteImage";

interface Props {
  hunt: ShinyHunt;
  onIncrement: (id: string, delta: number) => void;
  onComplete: (id: string, completion: ShinyHuntCompletion) => void;
}

export default function ShinyHuntCard({ hunt, onIncrement, onComplete }: Props) {
  const [isCompletionModalOpen, setIsCompletionModalOpen] = useState(false);
  const progress = Math.min((hunt.encounters / hunt.odds_denominator) * 100, 100);
  const { setLastHuntId } = useSettingsStore();
  
  const caughtDate = hunt.caught_at ? new Date(hunt.caught_at).toLocaleDateString(undefined, { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  }) : null;

  const ballName = hunt.completion_ball ? BALL_DISPLAY_NAMES[hunt.completion_ball] : null;
  const statusLabel = hunt.completion_is_failed ? "Failed" : "Caught";

  // Use refs to handle the pop-out window and its React root
  const huntRef = useRef(hunt);
  const pipWindowRef = useRef<any>(null);
  const pipRootRef = useRef<any>(null);

  const handleIncrement = useCallback((id: string, delta: number) => {
    setLastHuntId(id);
    onIncrement(id, delta);
  }, [onIncrement, setLastHuntId]);

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
  }, [hunt, handleIncrement]);

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
        const root = pipRootRef.current;
        const windowRef = pipWindowRef.current;
        
        // Defer unmounting to avoid synchronous unmount errors during React render cycles
        setTimeout(() => {
          try {
            if (root) {
              root.unmount();
            }
          } catch (e) {
            // Ignore unmount errors if window is already closed
          }
        }, 0);

        pipRootRef.current = null;
        if (windowRef === pipWindow) {
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
            <ShinySpriteImage
              pokemonId={hunt.pokemon_id}
              gender={hunt.gender}
              alt={hunt.pokemon_name}
              className={styles.sprite}
            />
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
          style={{ width: `${progress}%`, backgroundColor: hunt.is_caught ? (hunt.completion_is_failed ? "#ef4444" : "#4ade80") : "var(--accent)" }}
        />
      </div>

      {hunt.is_caught && (
        <div className={styles.caughtSummary}>
          <p>
            {statusLabel} {hunt.completion_nickname || hunt.pokemon_name} 
            {ballName && ` in a ${ballName}`}
            {caughtDate && ` on ${caughtDate}`}
          </p>
        </div>
      )}

      <div className={styles.footer}>
        <div className={styles.odds}>
          <span>Odds: 1/{hunt.odds_denominator.toLocaleString()}</span>
        </div>
        <div className={styles.actions}>
          {!hunt.is_caught && (
            <button 
              onClick={() => setIsCompletionModalOpen(true)}
              className={styles.completeBtn}
              title="Mark as caught"
            >
              <CheckCircle size={20} />
            </button>
          )}
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

      <CompletionModal 
        hunt={hunt}
        isOpen={isCompletionModalOpen}
        onClose={() => setIsCompletionModalOpen(false)}
        onConfirm={(completion) => {
          onComplete(hunt.id, completion);
          setIsCompletionModalOpen(false);
        }}
      />
    </div>
  );
}
