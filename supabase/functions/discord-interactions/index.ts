import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const SUPABASE_URL = requireEnv("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
const DISCORD_PUBLIC_KEY = requireEnv("DISCORD_PUBLIC_KEY");

const EPHEMERAL_FLAG = 64;
const ADMINISTRATOR_PERMISSION = 0x8n;
const MANAGE_GUILD_PERMISSION = 0x20n;

type DiscordInteraction = {
  type: number;
  data?: {
    name?: string;
  };
  guild_id?: string;
  channel_id?: string;
  channel?: {
    name?: string;
  };
  member?: {
    permissions?: string;
    user?: {
      id: string;
      username?: string;
      global_name?: string | null;
    };
  };
  user?: {
    id: string;
    username?: string;
    global_name?: string | null;
  };
};

type DiscordAccountLink = {
  user_id: string;
  discord_user_id: string;
  discord_username: string | null;
};

serve(async (request) => {
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const body = await request.text();
  const signature = request.headers.get("x-signature-ed25519");
  const timestamp = request.headers.get("x-signature-timestamp");

  if (!signature || !timestamp) {
    return new Response("Missing Discord signature headers", { status: 401 });
  }

  const isVerified = await verifyDiscordSignature(signature, timestamp, body);

  if (!isVerified) {
    return new Response("Invalid Discord signature", { status: 401 });
  }

  const interaction = JSON.parse(body) as DiscordInteraction;

  if (interaction.type === 1) {
    return discordResponse({ type: 1 });
  }

  if (interaction.type !== 2 || interaction.data?.name !== "here") {
    return ephemeralResponse("UniversalDex does not handle that command yet.");
  }

  try {
    return await handleHereCommand(interaction);
  } catch (error) {
    console.error(error);
    return ephemeralResponse(
      error instanceof Error
        ? error.message
        : "Could not save this Discord channel.",
    );
  }
});

async function handleHereCommand(
  interaction: DiscordInteraction,
): Promise<Response> {
  const guildID = interaction.guild_id;
  const channelID = interaction.channel_id;
  const discordUserID = interaction.member?.user?.id ?? interaction.user?.id;

  if (!guildID || !channelID) {
    return ephemeralResponse("Run /here inside a server channel.");
  }

  if (!discordUserID) {
    return ephemeralResponse("Discord did not include your user ID.");
  }

  if (!memberCanManageServer(interaction.member?.permissions)) {
    return ephemeralResponse(
      "You need Manage Server permission to choose the UniversalDex posting channel.",
    );
  }

  const accountLink = await fetchDiscordAccountLink(discordUserID);

  if (!accountLink) {
    return ephemeralResponse(
      "Connect this Discord account in UniversalDex first, then run /here again.",
    );
  }

  const channelName = interaction.channel?.name?.trim();
  const displayName = channelName ? `#${channelName}` : `Channel ${channelID}`;

  await upsertDestination({
    userID: accountLink.user_id,
    discordUserID,
    guildID,
    channelID,
    displayName,
  });

  return ephemeralResponse(
    `Saved ${displayName} as this server's UniversalDex shiny post channel.`,
  );
}

function memberCanManageServer(permissionsValue: string | undefined): boolean {
  if (!permissionsValue) {
    return false;
  }

  const permissions = BigInt(permissionsValue);

  return (permissions & ADMINISTRATOR_PERMISSION) ===
      ADMINISTRATOR_PERMISSION ||
    (permissions & MANAGE_GUILD_PERMISSION) === MANAGE_GUILD_PERMISSION;
}

async function fetchDiscordAccountLink(
  discordUserID: string,
): Promise<DiscordAccountLink | null> {
  const url = new URL(`${SUPABASE_URL}/rest/v1/discord_account_links`);

  url.searchParams.set("discord_user_id", `eq.${discordUserID}`);
  url.searchParams.set("select", "user_id,discord_user_id,discord_username");
  url.searchParams.set("limit", "1");

  const response = await supabaseFetch(url, { method: "GET" });

  if (!response.ok) {
    throw new Error(
      `Could not read Discord account link: ${await response.text()}`,
    );
  }

  const rows = await response.json() as DiscordAccountLink[];
  return rows[0] ?? null;
}

async function upsertDestination(
  destination: {
    userID: string;
    discordUserID: string;
    guildID: string;
    channelID: string;
    displayName: string;
  },
): Promise<void> {
  const url = new URL(
    `${SUPABASE_URL}/rest/v1/discord_notification_destinations`,
  );

  url.searchParams.set("on_conflict", "discord_guild_id");

  const response = await supabaseFetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Prefer": "resolution=merge-duplicates,return=minimal",
    },
    body: JSON.stringify({
      user_id: destination.userID,
      discord_user_id: destination.discordUserID,
      discord_guild_id: destination.guildID,
      discord_channel_id: destination.channelID,
      display_name: destination.displayName,
      webhook_url: null,
      is_enabled: true,
      milestone_notifications_enabled: true,
      catch_notifications_enabled: true,
      updated_at: new Date().toISOString(),
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Could not save Discord destination: ${await response.text()}`,
    );
  }
}

async function verifyDiscordSignature(
  signatureHex: string,
  timestamp: string,
  body: string,
): Promise<boolean> {
  const publicKey = await crypto.subtle.importKey(
    "raw",
    hexToBytes(DISCORD_PUBLIC_KEY),
    "Ed25519",
    false,
    ["verify"],
  );

  return await crypto.subtle.verify(
    "Ed25519",
    publicKey,
    hexToBytes(signatureHex),
    new TextEncoder().encode(`${timestamp}${body}`),
  );
}

function hexToBytes(hex: string): Uint8Array<ArrayBuffer> {
  const normalizedHex = hex.trim();

  if (normalizedHex.length % 2 !== 0) {
    throw new Error("Hex value must have an even length.");
  }

  const bytes = new Uint8Array(new ArrayBuffer(normalizedHex.length / 2));

  for (let index = 0; index < bytes.length; index += 1) {
    bytes[index] = Number.parseInt(
      normalizedHex.slice(index * 2, index * 2 + 2),
      16,
    );
  }

  return bytes;
}

function supabaseFetch(
  url: URL,
  init: RequestInit & { headers?: Record<string, string> },
): Promise<Response> {
  return fetch(url, {
    ...init,
    headers: {
      apikey: SUPABASE_SERVICE_ROLE_KEY,
      authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      ...(init.headers ?? {}),
    },
  });
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function ephemeralResponse(content: string): Response {
  return discordResponse({
    type: 4,
    data: {
      content,
      flags: EPHEMERAL_FLAG,
    },
  });
}

function discordResponse(body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), {
    headers: { "Content-Type": "application/json" },
  });
}
