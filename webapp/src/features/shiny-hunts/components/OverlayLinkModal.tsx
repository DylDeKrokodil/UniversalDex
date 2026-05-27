"use client";

import { Check, Copy, X } from "lucide-react";
import { useMemo, useState } from "react";
import { ShinyHunt } from "../types";
import {
  buildOverlayPath,
  DEFAULT_OVERLAY_OPTIONS,
  OverlayLayout,
  OverlayOptions,
  OverlaySize,
  OverlayTheme,
} from "../utils/overlayOptions";
import styles from "./OverlayLinkModal.module.css";

interface Props {
  hunt: ShinyHunt;
  isOpen: boolean;
  onClose: () => void;
}

const layoutOptions: Array<{ value: OverlayLayout; label: string }> = [
  { value: "horizontal", label: "Horizontal" },
  { value: "vertical", label: "Vertical" },
];

const sizeOptions: Array<{ value: OverlaySize; label: string }> = [
  { value: "compact", label: "Compact" },
  { value: "standard", label: "Standard" },
  { value: "large", label: "Large" },
];

const themeOptions: Array<{ value: OverlayTheme; label: string }> = [
  { value: "dark", label: "Dark" },
  { value: "light", label: "Light" },
  { value: "transparent", label: "Clear" },
];

export default function OverlayLinkModal({ hunt, isOpen, onClose }: Props) {
  const [options, setOptions] = useState<OverlayOptions>(DEFAULT_OVERLAY_OPTIONS);
  const [hasCopied, setHasCopied] = useState(false);

  const overlayUrl = useMemo(() => {
    if (typeof window === "undefined") {
      return "";
    }

    return `${window.location.origin}${buildOverlayPath(hunt.overlay_token, options)}`;
  }, [hunt.overlay_token, options]);

  if (!isOpen) return null;

  const copyOverlayUrl = async () => {
    await navigator.clipboard.writeText(overlayUrl);
    setHasCopied(true);
    window.setTimeout(() => setHasCopied(false), 1800);
  };

  return (
    <div className={styles.backdrop} onClick={onClose}>
      <div className={styles.modal} onClick={(event) => event.stopPropagation()}>
        <div className={styles.header}>
          <div>
            <h2>OBS Overlay</h2>
            <p>{hunt.hunt_name || hunt.pokemon_name}</p>
          </div>
          <button className={styles.iconButton} onClick={onClose} aria-label="Close overlay options">
            <X size={18} />
          </button>
        </div>

        <div className={styles.field}>
          <span className={styles.label}>Layout</span>
          <SegmentedControl
            options={layoutOptions}
            value={options.layout}
            onChange={(layout) => setOptions((current) => ({ ...current, layout }))}
          />
        </div>

        <div className={styles.field}>
          <span className={styles.label}>Size</span>
          <SegmentedControl
            options={sizeOptions}
            value={options.size}
            onChange={(size) => setOptions((current) => ({ ...current, size }))}
          />
        </div>

        <div className={styles.field}>
          <span className={styles.label}>Theme</span>
          <SegmentedControl
            options={themeOptions}
            value={options.theme}
            onChange={(theme) => setOptions((current) => ({ ...current, theme }))}
          />
        </div>

        <div className={styles.toggles}>
          <Toggle
            label="Pokemon"
            checked={options.showSprite}
            onChange={(showSprite) => setOptions((current) => ({ ...current, showSprite }))}
          />
          <Toggle
            label="Name"
            checked={options.showName}
            onChange={(showName) => setOptions((current) => ({ ...current, showName }))}
          />
          <Toggle
            label="Label"
            checked={options.showLabel}
            onChange={(showLabel) => setOptions((current) => ({ ...current, showLabel }))}
          />
          <Toggle
            label="Game"
            checked={options.showGame}
            onChange={(showGame) => setOptions((current) => ({ ...current, showGame }))}
          />
        </div>

        <div className={styles.urlBox}>{overlayUrl}</div>

        <button className={styles.copyButton} onClick={copyOverlayUrl}>
          {hasCopied ? <Check size={18} /> : <Copy size={18} />}
          {hasCopied ? "Copied" : "Copy OBS Link"}
        </button>
      </div>
    </div>
  );
}

function SegmentedControl<T extends string>({
  options,
  value,
  onChange,
}: {
  options: Array<{ value: T; label: string }>;
  value: T;
  onChange: (value: T) => void;
}) {
  return (
    <div className={styles.segmented}>
      {options.map((option) => (
        <button
          key={option.value}
          className={option.value === value ? styles.segmentActive : ""}
          onClick={() => onChange(option.value)}
          type="button"
        >
          {option.label}
        </button>
      ))}
    </div>
  );
}

function Toggle({
  label,
  checked,
  onChange,
}: {
  label: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
}) {
  return (
    <label className={styles.toggle}>
      <input
        type="checkbox"
        checked={checked}
        onChange={(event) => onChange(event.target.checked)}
      />
      <span>{label}</span>
    </label>
  );
}
