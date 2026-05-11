"use client";

import { useState } from "react";
import { supabase } from "@/lib/supabase";
import { useRouter } from "next/navigation";
import Link from "next/link";
import styles from "./Register.module.css";

export default function RegisterPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [token, setToken] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError(null);

    // 1. Check if token is valid via our RPC function
    const { data: isValid, error: tokenError } = await supabase.rpc('is_token_valid', {
      input_token: token.trim()
    });

    if (tokenError) {
      setError("Failed to validate token. Please try again.");
      setIsLoading(false);
      return;
    }

    if (!isValid) {
      setError("Invalid or already used registration token.");
      setIsLoading(false);
      return;
    }

    // 2. Perform sign up with token in metadata
    const { error: signUpError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          registration_token: token.trim()
        }
      }
    });

    if (signUpError) {
      setError(signUpError.message);
      setIsLoading(false);
    } else {
      // Success - Supabase handles redirection if email confirmation is off, 
      // or we might need to show a "Check your email" message.
      // For now, let's assume it works or redirects.
      router.push("/");
    }
  };

  return (
    <main className={styles.container}>
      <div className={styles.card}>
        <h1>Join the Deck</h1>
        <p>Enter your details and registration token</p>

        <form onSubmit={handleRegister} className={styles.form}>
          <div className={styles.infoBox}>
            <p>Registration requires a <strong>one-time use token</strong>. Check the <code>#alpha-invites</code> channel in Discord to get one.</p>
          </div>

          <div className={styles.field}>
            <label htmlFor="token">Registration Token</label>
            <input
              id="token"
              type="text"
              value={token}
              onChange={(e) => setToken(e.target.value)}
              required
              placeholder="XXX-XXX-XXX"
            />
          </div>

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
              minLength={6}
            />
          </div>

          {error && <p className={styles.error}>{error}</p>}

          <button type="submit" disabled={isLoading} className={styles.submitBtn}>
            {isLoading ? "Creating Account..." : "Register"}
          </button>
        </form>

        <Link href="/login" className={styles.loginLink}>
          Already have an account? <strong>Sign In</strong>
        </Link>
      </div>
    </main>
  );
}
