export type OverlayLayout = "horizontal" | "vertical";
export type OverlaySize = "compact" | "standard" | "large";
export type OverlayTheme = "dark" | "light" | "transparent";

export interface OverlayOptions {
  layout: OverlayLayout;
  size: OverlaySize;
  theme: OverlayTheme;
  showName: boolean;
  showGame: boolean;
  showSprite: boolean;
  showLabel: boolean;
}

export const DEFAULT_OVERLAY_OPTIONS: OverlayOptions = {
  layout: "horizontal",
  size: "standard",
  theme: "dark",
  showName: true,
  showGame: false,
  showSprite: true,
  showLabel: true,
};

type SearchParamsInput = Record<string, string | string[] | undefined>;

export function parseOverlayOptions(searchParams: SearchParamsInput): OverlayOptions {
  return {
    layout: parseOption(searchParams.layout, ["horizontal", "vertical"], DEFAULT_OVERLAY_OPTIONS.layout),
    size: parseOption(searchParams.size, ["compact", "standard", "large"], DEFAULT_OVERLAY_OPTIONS.size),
    theme: parseOption(searchParams.theme, ["dark", "light", "transparent"], DEFAULT_OVERLAY_OPTIONS.theme),
    showName: parseBoolean(searchParams.name, DEFAULT_OVERLAY_OPTIONS.showName),
    showGame: parseBoolean(searchParams.game, DEFAULT_OVERLAY_OPTIONS.showGame),
    showSprite: parseBoolean(searchParams.sprite, DEFAULT_OVERLAY_OPTIONS.showSprite),
    showLabel: parseBoolean(searchParams.label, DEFAULT_OVERLAY_OPTIONS.showLabel),
  };
}

export function overlayOptionsToSearchParams(options: OverlayOptions): URLSearchParams {
  const params = new URLSearchParams();

  params.set("layout", options.layout);
  params.set("size", options.size);
  params.set("theme", options.theme);
  params.set("name", booleanToParam(options.showName));
  params.set("game", booleanToParam(options.showGame));
  params.set("sprite", booleanToParam(options.showSprite));
  params.set("label", booleanToParam(options.showLabel));

  return params;
}

export function buildOverlayPath(token: string, options: OverlayOptions): string {
  return `/overlay/${token}?${overlayOptionsToSearchParams(options).toString()}`;
}

function parseOption<T extends string>(
  value: string | string[] | undefined,
  allowedValues: readonly T[],
  fallback: T,
): T {
  const normalizedValue = Array.isArray(value) ? value[0] : value;

  return allowedValues.includes(normalizedValue as T) ? (normalizedValue as T) : fallback;
}

function parseBoolean(value: string | string[] | undefined, fallback: boolean): boolean {
  const normalizedValue = Array.isArray(value) ? value[0] : value;

  if (normalizedValue === "1" || normalizedValue === "true") {
    return true;
  }

  if (normalizedValue === "0" || normalizedValue === "false") {
    return false;
  }

  return fallback;
}

function booleanToParam(value: boolean): string {
  return value ? "1" : "0";
}
