"use client";

import { useState, useEffect } from "react";
import { supabase } from "@/lib/supabase";
import { useRouter } from "next/navigation";
import { GAMES, ShinyGame } from "@/features/shiny-hunts/data/games";
import { METHODS, ShinyMethod, isMethodAvailable, calculateOdds } from "@/features/shiny-hunts/data/methods";
import styles from "./NewHunt.module.css";

interface PokemonResult {
  id: number;
  name: string;
  sprite: string;
}

export default function NewHuntPage() {
  const [pokemonSearch, setPokemonSearch] = useState("");
  const [pokemonResults, setPokemonResults] = useState<PokemonResult[]>([]);
  const [selectedPokemon, setSelectedPokemon] = useState<PokemonResult | null>(null);
  
  const [selectedGame, setSelectedGame] = useState<ShinyGame>("scarlet");
  const [selectedMethod, setSelectedMethod] = useState<ShinyMethod>("randomEncounter");
  const [hasShinyCharm, setHasShinyCharm] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSearching, setIsSearching] = useState(false);
  
  const router = useRouter();

  // Debounced search for Pokemon
  useEffect(() => {
    if (pokemonSearch.length < 2) {
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
            sprite: `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/${id}.png`
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
  }, [pokemonSearch]);

  const availableMethods = Object.keys(METHODS).filter(m => 
    isMethodAvailable(m as ShinyMethod, selectedGame)
  ) as ShinyMethod[];

  const oddsDenominator = calculateOdds(selectedMethod, selectedGame, hasShinyCharm);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPokemon) return;
    
    setIsLoading(true);

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      router.push("/login");
      return;
    }

    const { error } = await supabase.from("shiny_hunts").insert({
      user_id: user.id,
      pokemon_id: selectedPokemon.id,
      pokemon_name: selectedPokemon.name,
      hunt_name: `${selectedPokemon.name.split(' ').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ')} Hunt`,
      game: GAMES[selectedGame].displayName,
      method: METHODS[selectedMethod].displayName,
      odds_denominator: oddsDenominator,
      has_shiny_charm: hasShinyCharm,
      encounters: 0,
      is_caught: false,
    });

    if (error) {
      alert(error.message);
      setIsLoading(false);
    } else {
      router.push("/");
    }
  };

  return (
    <main className={styles.container}>
      <div className={styles.card}>
        <h1>Start New Hunt</h1>
        <form onSubmit={handleCreate} className={styles.form}>
          
          <div className={styles.field}>
            <label>Target Pokemon</label>
            {selectedPokemon ? (
              <div className={styles.selectedPokemon}>
                <img src={selectedPokemon.sprite} alt="" />
                <span>{selectedPokemon.name}</span>
                <button type="button" onClick={() => setSelectedPokemon(null)}>Change</button>
              </div>
            ) : (
              <>
                <input 
                  value={pokemonSearch} 
                  onChange={e => setPokemonSearch(e.target.value)} 
                  placeholder="Search pokemon..."
                  autoComplete="off"
                />
                {isSearching && <p className={styles.searching}>Searching...</p>}
                {pokemonResults.length !== 0 && (
                  <div className={styles.results}>
                    {pokemonResults.map(p => (
                      <button 
                        key={p.id} 
                        type="button" 
                        onClick={() => setSelectedPokemon(p)}
                        className={styles.resultItem}
                      >
                        <img src={p.sprite} alt="" />
                        <span>{p.name}</span>
                      </button>
                    ))}
                  </div>
                )}
              </>
            )}
          </div>

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
              <label htmlFor="charm">I have the Shiny Charm</label>
            </div>
          )}

          <div className={styles.oddsPreview}>
            <p>Calculated Odds: <strong>1 / {(oddsDenominator || 4096).toLocaleString()}</strong></p>
          </div>

          <button 
            type="submit" 
            disabled={isLoading || !selectedPokemon} 
            className={styles.submitBtn}
          >
            {isLoading ? "Creating..." : "Start Hunt"}
          </button>
        </form>
      </div>
    </main>
  );
}
