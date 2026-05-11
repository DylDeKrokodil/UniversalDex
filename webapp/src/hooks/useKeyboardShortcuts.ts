import { useEffect } from 'react';
import { useSettingsStore } from '@/store/settingsStore';

export function useKeyboardShortcuts(onIncrement: (delta: number) => void, targetWindow?: Window) {
  const { shortcuts } = useSettingsStore();

  useEffect(() => {
    const win = targetWindow || window;
    const handleKeyDown = (event: KeyboardEvent) => {
      // Ignore if typing in an input
      const doc = win.document;
      if (
        doc.activeElement?.tagName === 'INPUT' ||
        doc.activeElement?.tagName === 'TEXTAREA'
      ) {
        return;
      }

      if (event.key === shortcuts.increment) {
        onIncrement(1);
      } else if (event.key === shortcuts.decrement) {
        onIncrement(-1);
      }
    };

    win.addEventListener('keydown', handleKeyDown);
    return () => win.removeEventListener('keydown', handleKeyDown);
  }, [shortcuts, onIncrement, targetWindow]);
}
