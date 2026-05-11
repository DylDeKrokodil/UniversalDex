import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface ShortcutSettings {
  increment: string;
  decrement: string;
}

interface SettingsState {
  shortcuts: ShortcutSettings;
  setShortcuts: (shortcuts: ShortcutSettings) => void;
  lastHuntId: string | null;
  setLastHuntId: (id: string | null) => void;
}

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      shortcuts: {
        increment: '>',
        decrement: '<',
      },
      setShortcuts: (shortcuts) => set({ shortcuts }),
      lastHuntId: null,
      setLastHuntId: (id) => set({ lastHuntId: id }),
    }),
    {
      name: 'universal-dex-settings',
    }
  )
);
