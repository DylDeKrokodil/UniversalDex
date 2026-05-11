import React, { useState } from 'react';
import { ShinyHunt, ShinyCaughtBall, BALL_DISPLAY_NAMES, ShinyHuntCompletion } from '../types';
import styles from './CompletionModal.module.css';
import { X } from 'lucide-react';

interface Props {
  hunt: ShinyHunt;
  isOpen: boolean;
  onClose: () => void;
  onConfirm: (completion: ShinyHuntCompletion) => void;
}

export default function CompletionModal({ hunt, isOpen, onClose, onConfirm }: Props) {
  const [nickname, setNickname] = useState('');
  const [ball, setBall] = useState<ShinyCaughtBall>('poke');
  const [caughtAt, setCaughtAt] = useState(new Date().toISOString().split('T')[0]);
  const [isFailed, setIsFailed] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onConfirm({
      nickname,
      ball,
      encounters: hunt.encounters,
      elapsedTime: hunt.elapsed_time,
      caughtAt: new Date(caughtAt).toISOString(),
      isFailed
    });
  };

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={styles.modal} onClick={e => e.stopPropagation()}>
        <header className={styles.header}>
          <h2>Complete Hunt</h2>
          <button onClick={onClose} className={styles.closeBtn}>
            <X size={20} />
          </button>
        </header>

        <form onSubmit={handleSubmit} className={styles.form}>
          <div className={styles.section}>
            <h3>Pokemon Details</h3>
            <div className={styles.field}>
              <label htmlFor="nickname">Nickname</label>
              <input 
                id="nickname"
                type="text" 
                value={nickname} 
                onChange={e => setNickname(e.target.value)}
                placeholder="Enter nickname..."
              />
            </div>
            <div className={styles.field}>
              <label htmlFor="ball">Ball</label>
              <select 
                id="ball"
                value={ball} 
                onChange={e => setBall(e.target.value as ShinyCaughtBall)}
              >
                {(Object.keys(BALL_DISPLAY_NAMES) as ShinyCaughtBall[]).map(b => (
                  <option key={b} value={b}>{BALL_DISPLAY_NAMES[b]}</option>
                ))}
              </select>
            </div>
          </div>

          <div className={styles.section}>
            <h3>Result</h3>
            <div className={styles.statsRow}>
              <div className={styles.stat}>
                <span className={styles.statLabel}>Encounters</span>
                <span className={styles.statValue}>{hunt.encounters.toLocaleString()}</span>
              </div>
              <div className={styles.stat}>
                <span className={styles.statLabel}>Odds</span>
                <span className={styles.statValue}>1/{hunt.odds_denominator.toLocaleString()}</span>
              </div>
            </div>

            <div className={styles.field}>
              <label htmlFor="caughtAt">Date Caught</label>
              <input 
                id="caughtAt"
                type="date" 
                value={caughtAt} 
                onChange={e => setCaughtAt(e.target.value)}
              />
            </div>

            <div className={styles.checkboxField}>
              <input 
                id="isFailed"
                type="checkbox" 
                checked={isFailed} 
                onChange={e => setIsFailed(e.target.checked)}
              />
              <label htmlFor="isFailed">This hunt was failed</label>
            </div>
          </div>

          <footer className={styles.footer}>
            <button type="button" onClick={onClose} className={styles.cancelBtn}>Cancel</button>
            <button type="submit" className={styles.confirmBtn}>Complete Hunt</button>
          </footer>
        </form>
      </div>
    </div>
  );
}
