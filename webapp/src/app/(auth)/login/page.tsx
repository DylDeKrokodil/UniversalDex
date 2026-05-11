"use client";

import { useState } from "react";
import { supabase } from "@/lib/supabase";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Users } from "lucide-react";
import styles from "./Login.module.css";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError(error.message);
      setIsLoading(false);
    } else {
      router.push("/");
    }
  };

  return (
    <main className={styles.container}>
      <div className={styles.card}>
        <h1>Welcome Back</h1>
        <p>Sign in to your UniversalDex account</p>

        <form onSubmit={handleLogin} className={styles.form}>
          <div className={styles.field}>
            <label htmlFor="email">Email Address</label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="name@example.com"
            />
          </div>

          <div className={styles.field}>
            <label htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="••••••••"
            />
          </div>

          {error && <p className={styles.error}>{error}</p>}

          <button type="submit" disabled={isLoading} className={styles.submitBtn}>
            {isLoading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        <Link href="/register" className={styles.registerLink}>
          Have an invite token? <strong>Register here</strong>
        </Link>

        <div className={styles.infoBox}>
          <p>UniversalDex is currently in <strong>invite-only alpha</strong>. Tokens are distributed through our Discord community.</p>
        </div>

        <div className={styles.divider}>
          <span>or</span>
        </div>

        <a 
          href="https://discord.gg/QcTZ4sCGTr" 
          target="_blank" 
          rel="noopener noreferrer"
          className={styles.discordLink}
        >
          <Users size={20} />
          <span>Join our Discord Community</span>
        </a>
      </div>
    </main>
  );
}
