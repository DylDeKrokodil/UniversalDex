import type { Metadata } from "next";
import "./globals.css";
import Providers from "./providers";
import { AuthProvider } from "@/features/auth/AuthProvider";
import ThemeProvider from "@/components/ThemeProvider";

export const metadata: Metadata = {
  title: "UniversalDex",
  description: "Your ultimate shiny hunting companion",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <Providers>
          <AuthProvider>
            <ThemeProvider>
              {children}
            </ThemeProvider>
          </AuthProvider>
        </Providers>
      </body>
    </html>
  );
}
