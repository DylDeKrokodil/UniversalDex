"use client";

import { useEffect, useState } from "react";
import { POKEMON_EGG_IMAGE_SRC, shinyHomeSpriteUrl } from "../utils/pokemonSprites";

interface Props {
  pokemonId: number | string | null | undefined;
  gender?: "female" | string | null;
  alt: string;
  className?: string;
}

export default function ShinySpriteImage({ pokemonId, gender, alt, className }: Props) {
  const [src, setSrc] = useState(POKEMON_EGG_IMAGE_SRC);

  useEffect(() => {
    const spriteUrl = shinyHomeSpriteUrl(pokemonId, gender);

    if (!spriteUrl) {
      setSrc(POKEMON_EGG_IMAGE_SRC);
      return;
    }

    let isActive = true;
    setSrc(POKEMON_EGG_IMAGE_SRC);

    const image = new Image();
    image.onload = () => {
      if (isActive) {
        setSrc(spriteUrl);
      }
    };
    image.onerror = () => {
      if (isActive) {
        setSrc(POKEMON_EGG_IMAGE_SRC);
      }
    };
    image.src = spriteUrl;

    return () => {
      isActive = false;
    };
  }, [pokemonId, gender]);

  return <img src={src} alt={alt} className={className} />;
}
