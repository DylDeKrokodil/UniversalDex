"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useAuth } from "@/features/auth/AuthProvider";
import { LayoutDashboard, Settings, LogOut, Users, ChevronLeft, ChevronRight } from "lucide-react";
import styles from "./Sidebar.module.css";
import { useUIStore } from "@/store/uiStore";

export default function Sidebar() {
  const pathname = usePathname();
  const { user, signOut } = useAuth();
  const router = useRouter();
  const { sidebarCollapsed, toggleSidebar } = useUIStore();

  const handleSignOut = async () => {
    await signOut();
    router.push("/login");
  };

  if (!user) return null;

  return (
    <aside className={`${styles.sidebar} ${sidebarCollapsed ? styles.collapsed : ""}`}>
      <div className={styles.inner}>
        <div className={styles.brand}>
          <img src="/logo.png" alt="" className={styles.brandImg} />
          {!sidebarCollapsed && (
            <Link href="/" className={styles.logo}>
              UniversalDex
            </Link>
          )}
        </div>

        <nav className={styles.nav}>
          <div className={styles.section}>
            {!sidebarCollapsed && <p className={styles.sectionTitle}>Main</p>}
            <Link 
              href="/" 
              className={`${styles.link} ${pathname === "/" ? styles.active : ""}`}
              title={sidebarCollapsed ? "Dashboard" : ""}
            >
              <LayoutDashboard size={20} />
              {!sidebarCollapsed && <span>Dashboard</span>}
            </Link>
          </div>

          <div className={styles.section}>
            {!sidebarCollapsed && <p className={styles.sectionTitle}>Preferences</p>}
            <Link 
              href="/settings" 
              className={`${styles.link} ${pathname === "/settings" ? styles.active : ""}`}
              title={sidebarCollapsed ? "Settings" : ""}
            >
              <Settings size={20} />
              {!sidebarCollapsed && <span>Settings</span>}
            </Link>
          </div>

          <div className={styles.section}>
            {!sidebarCollapsed && <p className={styles.sectionTitle}>Community</p>}
            <a 
              href="https://discord.gg/QcTZ4sCGTr" 
              target="_blank" 
              rel="noopener noreferrer"
              className={styles.link}
              title={sidebarCollapsed ? "Join Discord" : ""}
            >
              <Users size={20} />
              {!sidebarCollapsed && <span>Join Discord</span>}
            </a>
          </div>
        </nav>

        <div className={styles.footer}>
          <div className={styles.userBox}>
            {!sidebarCollapsed && <p className={styles.userEmail}>{user.email}</p>}
            <button onClick={handleSignOut} className={styles.logoutBtn} title={sidebarCollapsed ? "Sign Out" : ""}>
              <LogOut size={18} />
              {!sidebarCollapsed && <span>Sign Out</span>}
            </button>
          </div>
        </div>
      </div>

      <button className={styles.toggleBtn} onClick={toggleSidebar}>
        {sidebarCollapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
      </button>
    </aside>
  );
}
