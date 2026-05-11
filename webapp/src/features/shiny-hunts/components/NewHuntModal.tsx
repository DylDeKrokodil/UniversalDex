"use client";

import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabase";
import { GAMES, ShinyGame } from "../data/games";
import { METHODS, ShinyMethod, isMethodAvailable, calculateOdds } from "../data/methods";
import { ShinyGender, TrackingMetric } from "../types";
import styles from "./NewHuntModal.module.css";
import { X, Search } from "lucide-react";

interface PokemonResult {
  id: number;
  name: string;
  sprite: string;
}

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export default function NewHuntModal({ isOpen, onClose, onSuccess }: Props) {
  const [pokemonSearch, setPokemonSearch] = useState("");
  const [pokemonResults, setPokemonResults] = useState<PokemonResult[]>([]);
  const [selectedPokemon, setSelectedPokemon] = useState<PokemonResult | null>(null);
  
  const [huntName, setHuntName] = useState("");
  const [selectedGame, setSelectedGame] = useState<ShinyGame>("scarlet");
  const [selectedMethod, setSelectedMethod] = useState<ShinyMethod>("randomEncounter");
  const [selectedGender, setSelectedGender] = useState<ShinyGender>("male");
  const [hasShinyCharm, setHasShinyCharm] = useState(false);
  const [trackingMetric, setTrackingMetric] = useState<TrackingMetric>("encounters");
  const [startingEncounters, setStartingEncounters] = useState("0");
  const [startingHours, setStartingHours] = useState("0");
  const [startingMinutes, setStartingMinutes] = useState("0");
  const [startingSeconds, setStartingSeconds] = useState("0");
  const [encounterIncrement, setEncounterIncrement] = useState("1");
  
  const [isLoading, setIsLoading] = useState(false);
  const [isSearching, setIsSearching] = useState(false);

  // Debounced search for Pokemon
  useEffect(() => {
    if (pokemonSearch.length < 2 || (selectedPokemon && pokemonSearch === selectedPokemon.name)) {
      setPokemonResults([]);
      return;
    }

    const timer = setTimeout(async () => {
      setIsSearching(true);
      try {
        const res = await fetch(`https://pokeapi.co/api/v2/pokemon?limit=10000`);
        const data = await res.json();
        const matches = data.results
          .filter((p: any) => p.name.includes(pokemonSearch.toLowerCase()))
          .slice(0, 10);
        
        const detailedMatches = await Promise.all(matches.map(async (p: any) => {
          const id = p.url.split('/').filter(Boolean).pop();
          return {
            id: parseInt(id),
            name: p.name.replace(/-/g, ' '),
            sprite: `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/images/sprites/pokemon/other/home/shiny/${id}.png`
          };
        }));
        
        setPokemonResults(detailedMatches);
      } catch (e) {
        console.error(e);
      } finally {
        setIsSearching(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [pokemonSearch, selectedPokemon]);

  const selectPokemon = (p: PokemonResult) => {
    setSelectedPokemon(p);
    setPokemonSearch(p.name);
    setPokemonResults([]);
    if (!huntName) {
      setHuntName(`${p.name.split(' ').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ')} Hunt`);
    }
  };

  const availableMethods = Object.keys(METHODS).filter(m => 
    isMethodAvailable(m as ShinyMethod, selectedGame)
  ) as ShinyMethod[];

  const oddsDenominator = calculateOdds(selectedMethod, selectedGame, hasShinyCharm);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPokemon) return;
    
    setIsLoading(true);

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const totalSeconds = (parseInt(startingHours) * 3600) + (parseInt(startingMinutes) * 60) + parseInt(startingSeconds);

    const { error } = await supabase.from("shiny_hunts").insert({
      user_id: user.id,
      pokemon_id: selectedPokemon.id,
      pokemon_name: selectedPokemon.name,
      hunt_name: huntName || `${selectedPokemon.name} Hunt`,
      game: GAMES[selectedGame].displayName,
      method: METHODS[selectedMethod].displayName,
      gender: selectedGender,
      tracking_metric: trackingMetric,
      has_shiny_charm: hasShinyCharm,
      odds_denominator: oddsDenominator,
      encounters: parseInt(startingEncounters) || 0,
      encounter_increment: parseInt(encounterIncrement) || 1,
      elapsed_time: totalSeconds || 0,
      is_caught: false,
    });

    if (error) {
      alert(error.message);
      setIsLoading(false);
    } else {
      onSuccess();
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <div className={styles.overlay} onClick={onClose}>
      <div className={styles.modal} onClick={e => e.stopPropagation()}>
        <header className={styles.header}>
          <h2>New Shiny Hunt</h2>
          <button onClick={onClose} className={styles.closeBtn}>
            <X size={20} />
          </button>
        </header>

        <form onSubmit={handleCreate} className={styles.form}>
          <div className={styles.scrollArea}>
            <section className={styles.section}>
              <h3>Hunt Details</h3>
              <div className={styles.field}>
                <label>Hunt Name</label>
                <input 
                  value={huntName} 
                  onChange={e => setHuntName(e.target.value)} 
                  placeholder="e.g. My Awesome Hunt"
                />
              </div>

              <div className={styles.field}>
                <label>Target Pokemon</label>
                <div className={styles.searchWrapper}>
                  <Search size={16} className={styles.searchIcon} />
                  <input 
                    value={pokemonSearch} 
                    onChange={e => setPokemonSearch(e.target.value)} 
                    placeholder="Search Pokemon..."
                    autoComplete="off"
                  />
                </div>
                {isSearching && <p className={styles.searching}>Searching...</p>}
                {pokemonResults.length !== 0 && (
                  <div className={styles.results}>
                    {pokemonResults.map(p => (
                      <button 
                        key={p.id} 
                        type="button" 
                        onClick={() => selectPokemon(p)}
                        className={styles.resultItem}
                      >
                        <img src={p.sprite} alt="" />
                        <span>{p.name}</span>
                      </button>
                    ))}
                  </div>
                )}
                {selectedPokemon && !pokemonResults.length && pokemonSearch === selectedPokemon.name && (
                  <div className={styles.selectedPokemon}>
                    <img src={selectedPokemon.sprite} alt="" />
                    <span>{selectedPokemon.name}</span>
                  </div>
                )}
              </div>

              <div className={styles.field}>
                <label>Gender</label>
                <select value={selectedGender} onChange={e => setSelectedGender(e.target.value as ShinyGender)}>
                  <option value="male">Male</option>
                  <option value="female">Female</option>
                  <option value="genderless">Genderless</option>
                </select>
              </div>
            </section>

            <section className={styles.section}>
              <h3>Setup</h3>
              <div className={styles.field}>
                <label>Game</label>
                <select 
                  value={selectedGame} 
                  onChange={e => {
                    const newGame = e.target.value as ShinyGame;
                    setSelectedGame(newGame);
                    if (!isMethodAvailable(selectedMethod, newGame)) {
                      setSelectedMethod("randomEncounter");
                    }
                  }}
                >
                  {Object.entries(GAMES).map(([id, info]) => (
                    <option key={id} value={id}>{info.displayName}</option>
                  ))}
                </select>
              </div>

              <div className={styles.field}>
                <label>Method</label>
                <select 
                  value={selectedMethod} 
                  onChange={e => setSelectedMethod(e.target.value as ShinyMethod)}
                >
                  {availableMethods.map(m => (
                    <option key={m} value={m}>{METHODS[m].displayName}</option>
                  ))}
                </select>
              </div>

              {GAMES[selectedGame].supportsCharm && (
                <div className={styles.checkboxField}>
                  <input 
                    type="checkbox" 
                    id="charm" 
                    checked={hasShinyCharm} 
                    onChange={e => setHasShinyCharm(e.target.checked)} 
                  />
                  <label htmlFor="charm">Shiny Charm</label>
                </div>
              )}

              <div className={styles.oddsPreview}>
                <p>Odds: <strong>1 / {oddsDenominator.toLocaleString()}</strong></p>
              </div>
            </section>

            <section className={styles.section}>
              <h3>Tracking</h3>
              <div className={styles.field}>
                <label>Tracking Metric</label>
                <select value={trackingMetric} onChange={e => setTrackingMetric(e.target.value as TrackingMetric)}>
                  <option value="encounters">Encounters</option>
                  <option value="time">Time</option>
                  <option value="both">Both</option>
                </select>
              </div>

              {trackingMetric !== "time" && (
                <div className={styles.gridFields}>
                  <div className={styles.field}>
                    <label>Starting Encounters</label>
                    <input 
                      type="number" 
                      value={startingEncounters} 
                      onChange={e => setStartingEncounters(e.target.value)} 
                    />
                  </div>
                  <div className={styles.field}>
                    <label>Increment By</label>
                    <input 
                      type="number" 
                      value={encounterIncrement} 
                      onChange={e => setEncounterIncrement(e.target.value)} 
                    />
                  </div>
                </div>
              )}

              {trackingMetric !== "encounters" && (
                <div className={styles.field}>
                  <label>Starting Time</label>
                  <div className={styles.timeFields}>
                    <div className={styles.timeInput}>
                      <input type="number" value={startingHours} onChange={e => setStartingHours(e.target.value)} />
                      <span>h</span>
                    </div>
                    <div className={styles.timeInput}>
                      <input type="number" value={startingMinutes} onChange={e => setStartingMinutes(e.target.value)} />
                      <span>m</span>
                    </div>
                    <div className={styles.timeInput}>
                      <input type="number" value={startingSeconds} onChange={e => setStartingSeconds(e.target.value)} />
                      <span>s</span>
                    </div>
                  </div>
                </div>
              )}
            </section>
          </div>

          <footer className={styles.footer}>
            <button type="button" onClick={onClose} className={styles.cancelBtn}>Cancel</button>
            <button type="submit" disabled={isLoading || !selectedPokemon} className={styles.submitBtn}>
              {isLoading ? "Creating..." : "Start Hunt"}
            </button>
          </footer>
        </form>
      </div>
    </div>
  );
}
