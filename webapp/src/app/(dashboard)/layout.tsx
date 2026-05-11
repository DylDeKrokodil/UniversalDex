"use client";

import Sidebar from "@/components/Sidebar";
import { useUIStore } from "@/store/uiStore";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { sidebarCollapsed } = useUIStore();

  return (
    <div style={{ display: "flex", minHeight: "100vh" }}>
      <Sidebar />
      <div style={{ 
        flex: 1, 
        marginLeft: sidebarCollapsed ? "80px" : "260px",
        transition: "margin-left 0.3s cubic-bezier(0.4, 0, 0.2, 1)"
      }}>
        {children}
      </div>
    </div>
  );
}
