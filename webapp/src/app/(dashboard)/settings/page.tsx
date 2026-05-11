"use client";

import { useAuth } from "@/features/auth/AuthProvider";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { supabase } from "@/lib/supabase";
import { DiscordAccountLink, DiscordNotificationDestination } from "@/features/settings/types";
import { useThemeStore } from "@/store/themeStore";
import { useSettingsStore } from "@/store/settingsStore";
import { Sun, Moon, Monitor, Keyboard } from "lucide-react";
import styles from "./Settings.module.css";

export default function SettingsPage() {
  const { user, isLoading: authLoading, signOut } = useAuth();
  const { theme, setTheme } = useThemeStore();
  const { shortcuts, setShortcuts } = useSettingsStore();
  const router = useRouter();
  const [discordLink, setDiscordLink] = useState<DiscordAccountLink | null>(null);
  const [destinations, setDestinations] = useState<DiscordNotificationDestination[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const [activeShortcutField, setActiveShortcutField] = useState<'increment' | 'decrement' | null>(null);

  useEffect(() => {
    const handleGlobalKeyDown = (e: KeyboardEvent) => {
      if (activeShortcutField) {
        e.preventDefault();
        setShortcuts({
          ...shortcuts,
          [activeShortcutField]: e.key
        });
        setActiveShortcutField(null);
      }
    };

    if (activeShortcutField) {
      window.addEventListener('keydown', handleGlobalKeyDown);
    }
    return () => window.removeEventListener('keydown', handleGlobalKeyDown);
  }, [activeShortcutField, shortcuts, setShortcuts]);

  useEffect(() => {
    if (!authLoading && !user) {
      router.push("/login");
    }
  }, [user, authLoading, router]);

  useEffect(() => {
    if (user) {
      fetchDiscordSettings();
    }
  }, [user]);

  const fetchDiscordSettings = async () => {
    setIsLoading(true);
    
    const [linkRes, destRes] = await Promise.all([
      supabase.from("discord_account_links").select("*").single(),
      supabase.from("discord_notification_destinations").select("*")
    ]);

    if (linkRes.data) setDiscordLink(linkRes.data);
    if (destRes.data) setDestinations(destRes.data);
    
    setIsLoading(false);
  };

  const handleSignOut = async () => {
    await signOut();
    router.push("/");
  };

  if (authLoading || isLoading) {
    return (
      <main className={styles.loading}>
        <p>Loading your settings...</p>
      </main>
    );
  }

  if (!user) return null;

  return (
    <main className={styles.container}>
      <h1>Settings</h1>

      <section className={styles.section}>
        <h2>Appearance</h2>
        <div className={styles.themeCard}>
          <button 
            className={`${styles.themeOption} ${theme === 'light' ? styles.active : ''}`}
            onClick={() => setTheme('light')}
          >
            <Sun size={20} />
            <span>Light</span>
          </button>
          <button 
            className={`${styles.themeOption} ${theme === 'dark' ? styles.active : ''}`}
            onClick={() => setTheme('dark')}
          >
            <Moon size={20} />
            <span>Dark</span>
          </button>
          <button 
            className={`${styles.themeOption} ${theme === 'system' ? styles.active : ''}`}
            onClick={() => setTheme('system')}
          >
            <Monitor size={20} />
            <span>System</span>
          </button>
        </div>
      </section>

      <section className={styles.section}>
        <h2>Keyboard Shortcuts</h2>
        <p className={styles.description}>
          Customise keys to quickly update your counters.
        </p>
        <div className={styles.shortcutGrid}>
          <div className={styles.shortcutItem}>
            <span>Increment Counter</span>
            <button 
              className={`${styles.shortcutKey} ${activeShortcutField === 'increment' ? styles.recording : ''}`}
              onClick={() => setActiveShortcutField('increment')}
            >
              {activeShortcutField === 'increment' ? 'Press any key...' : shortcuts.increment}
            </button>
          </div>
          <div className={styles.shortcutItem}>
            <span>Decrement Counter</span>
            <button 
              className={`${styles.shortcutKey} ${activeShortcutField === 'decrement' ? styles.recording : ''}`}
              onClick={() => setActiveShortcutField('decrement')}
            >
              {activeShortcutField === 'decrement' ? 'Press any key...' : shortcuts.decrement}
            </button>
          </div>
        </div>
        {activeShortcutField && (
          <p className={styles.shortcutHint}>Recording... Press the key you want to use.</p>
        )}
      </section>
      
      <section className={styles.section}>
        <h2>Account</h2>
        <div className={styles.accountCard}>
          <div className={styles.userInfo}>
            <p><strong>Email:</strong> {user.email}</p>
          </div>
          <button onClick={handleSignOut} className={styles.signOutBtn}>
            Sign Out
          </button>
        </div>
      </section>

      <section className={styles.section}>
        <h2>Discord Integration</h2>
        <p className={styles.description}>
          Connect your Discord account to post your shiny hunt milestones to your servers.
        </p>
        
        {discordLink ? (
          <div className={styles.discordCard}>
            <div className={styles.discordUser}>
              {discordLink.discord_avatar_url && (
                <img src={discordLink.discord_avatar_url} alt="" className={styles.avatar} />
              )}
              <div>
                <p className={styles.username}>{discordLink.discord_username || "Discord Connected"}</p>
                <p className={styles.userId}>ID: {discordLink.discord_user_id}</p>
              </div>
            </div>
            <button className={styles.disconnectBtn}>Disconnect</button>
          </div>
        ) : (
          <button className={styles.connectBtn}>Connect Discord</button>
        )}
      </section>

      {destinations.length > 0 && (
        <section className={styles.section}>
          <h2>Notification Destinations</h2>
          <div className={styles.destinations}>
            {destinations.map(dest => (
              <div key={dest.id} className={styles.destCard}>
                <div className={styles.destHeader}>
                  <h3>{dest.guild_name || "Unknown Server"}</h3>
                  <span className={styles.channel}>#{dest.discord_channel_id || "no-channel"}</span>
                </div>
                <div className={styles.toggles}>
                  <label>
                    <input type="checkbox" checked={dest.is_milestone_enabled} readOnly />
                    Milestones
                  </label>
                  <label>
                    <input type="checkbox" checked={dest.is_catch_enabled} readOnly />
                    Catches
                  </label>
                </div>
              </div>
            ))}
          </div>
        </section>
      )}
    </main>
  );
}
