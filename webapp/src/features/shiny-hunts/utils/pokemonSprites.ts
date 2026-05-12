const POKEAPI_SPRITES_BASE_URL =
  "https://raw.githubusercontent.com/PokeAPI/sprites/master";

export const POKEMON_EGG_IMAGE_SRC = "/pokemon-egg.png";

export function shinyHomeSpriteUrl(
  pokemonId: number | string | null | undefined,
  gender?: "female" | string | null,
): string | undefined {
  if (pokemonId === null || pokemonId === undefined) {
    return undefined;
  }

  const path = gender === "female" ? `female/${pokemonId}.png` : `${pokemonId}.png`;

  return `${POKEAPI_SPRITES_BASE_URL}/sprites/pokemon/other/home/shiny/${path}`;
}
