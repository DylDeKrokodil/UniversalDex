"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/features/auth/AuthProvider";
import { LayoutDashboard, Settings, LogOut, PlusSquare, Users } from "lucide-react";
import styles from "./Sidebar.module.css";

export default function Sidebar() {
  const pathname = usePathname();
  const { user, signOut } = useAuth();
  const router = useRouter();

  const handleSignOut = async () => {
    await signOut();
    router.push("/login");
  };

  if (!user) return null;

  return (
    <aside className={styles.sidebar}>
      <div className={styles.brand}>
        <img src="/logo.png" alt="" className={styles.brandImg} />
        <Link href="/" className={styles.logo}>
          UniversalDex
        </Link>
      </div>

      <nav className={styles.nav}>
        <div className={styles.section}>
          <p className={styles.sectionTitle}>Main</p>
          <Link 
            href="/" 
            className={`${styles.link} ${pathname === "/" ? styles.active : ""}`}
          >
            <LayoutDashboard size={20} />
            <span>Dashboard</span>
          </Link>
          <Link 
            href="/new" 
            className={`${styles.link} ${pathname === "/new" ? styles.active : ""}`}
          >
            <PlusSquare size={20} />
            <span>New Hunt</span>
          </Link>
        </div>

        <div className={styles.section}>
          <p className={styles.sectionTitle}>Preferences</p>
          <Link 
            href="/settings" 
            className={`${styles.link} ${pathname === "/settings" ? styles.active : ""}`}
          >
            <Settings size={20} />
            <span>Settings</span>
          </Link>
        </div>

        <div className={styles.section}>
          <p className={styles.sectionTitle}>Community</p>
          <a 
            href="https://discord.gg/QcTZ4sCGTr" 
            target="_blank" 
            rel="noopener noreferrer"
            className={styles.link}
          >
            <Users size={20} />
            <span>Join Discord</span>
          </a>
        </div>
      </nav>

      <div className={styles.footer}>
        <div className={styles.userBox}>
          <p className={styles.userEmail}>{user.email}</p>
          <button onClick={handleSignOut} className={styles.logoutBtn}>
            <LogOut size={18} />
            <span>Sign Out</span>
          </button>
        </div>
      </div>
    </aside>
  );
}
