import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

type ShinyHuntRecord = {
  id: string;
  user_id: string;
  pokemon_id: number | null;
  pokemon_form_id: number | null;
  pokemon_name: string;
  hunt_name: string;
  game: string;
  method: string;
  odds_denominator: number;
  encounters: number;
  elapsed_time: number;
  is_caught: boolean;
  caught_at: string | null;
  completion_nickname: string | null;
  completion_ball: string | null;
  completion_encounters: number | null;
  completion_elapsed_time: number | null;
  completion_is_failed: boolean;
};

type DatabaseWebhookPayload = {
  type?: string;
  table?: string;
  record?: ShinyHuntRecord;
  old_record?: ShinyHuntRecord | null;
};

type NotificationDestination = {
  id: string;
  user_id: string;
  discord_user_id: string | null;
  discord_guild_id: string | null;
  discord_channel_id: string | null;
  display_name: string;
  webhook_url: string | null;
  catch_notifications_enabled: boolean;
  milestone_notifications_enabled: boolean;
};

type DiscordAccountLink = {
  discord_user_id: string;
  discord_username: string | null;
};

type Notification =
  | { type: "milestone"; milestoneValue: number }
  | { type: "caught"; milestoneValue: 0 };

const SUPABASE_URL = requireEnv("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
const FUNCTION_SECRET = requireEnv("UNIVERSALDEX_DISCORD_BOT_SECRET");
const DISCORD_BOT_TOKEN = Deno.env.get("DISCORD_BOT_TOKEN");
const MILESTONE_VALUES = parseMilestones(
  Deno.env.get("SHINY_HUNT_MILESTONES") ?? "100,500,1000,2000,5000,10000",
);

serve(async (request) => {
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  if (!isAuthorized(request)) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  const payload = await request.json() as DatabaseWebhookPayload;
  const record = payload.record;
  const oldRecord = payload.old_record ?? null;
  const eventType = payload.type?.toUpperCase();

  if (!record?.id || !record.user_id) {
    return jsonResponse(
      { error: "Expected a shiny_hunts webhook payload" },
      400,
    );
  }

  const notifications = notificationsFor(record, oldRecord, eventType);

  if (notifications.length === 0) {
    return jsonResponse({ ok: true, posted: 0, skipped: 0 });
  }

  const accountLink = await fetchDiscordAccountLink(record.user_id);

  if (!accountLink) {
    return jsonResponse({ ok: true, posted: 0, skipped: notifications.length });
  }

  const destinations = await fetchServerDestinations();
  console.log(
    `Discord shiny bot: hunt=${record.id} user=${record.user_id} notifications=${notifications.length} server_destinations=${destinations.length}`,
  );

  const membershipCache = new Map<string, boolean>();
  let posted = 0;
  let skipped = 0;
  let failed = 0;

  for (const destination of destinations) {
    if (!destination.discord_guild_id) {
      skipped += notifications.length;
      continue;
    }

    const isMember = await cachedMembershipCheck(
      membershipCache,
      destination.discord_guild_id,
      accountLink.discord_user_id,
    );

    if (!isMember) {
      skipped += notifications.length;
      continue;
    }

    const targetDestination = destinationForLinkedUser(
      destination,
      accountLink,
    );

    for (const notification of notifications) {
      if (!destinationAllows(targetDestination, notification)) {
        skipped += 1;
        continue;
      }

      const logID = await createNotificationLog(
        record,
        targetDestination,
        notification,
      );

      if (!logID) {
        skipped += 1;
        continue;
      }

      const result = await postToDiscord(
        targetDestination,
        record,
        notification,
      );

      if (result.ok) {
        posted += 1;
        await updateNotificationLog(logID, {
          status: "posted",
          posted_at: new Date().toISOString(),
          discord_message_id: result.messageID,
          discord_response: result.responseBody,
          error_message: null,
        });
      } else {
        failed += 1;
        await updateNotificationLog(logID, {
          status: "failed",
          error_message: result.errorMessage,
          discord_response: result.responseBody,
        });
      }
    }
  }

  return jsonResponse({ ok: true, posted, skipped, failed });
});

function notificationsFor(
  record: ShinyHuntRecord,
  oldRecord: ShinyHuntRecord | null,
  eventType: string | undefined,
): Notification[] {
  const notifications: Notification[] = [];

  if (!oldRecord) {
    if (eventType !== "UPDATE") {
      return notifications;
    }

    for (const milestoneValue of exactMilestones(record.encounters ?? 0)) {
      notifications.push({ type: "milestone", milestoneValue });
    }

    if (record.is_caught) {
      notifications.push({ type: "caught", milestoneValue: 0 });
    }

    return notifications;
  }

  const oldEncounters = oldRecord.encounters ?? 0;
  const newEncounters = record.encounters ?? 0;

  for (
    const milestoneValue of crossedMilestones(oldEncounters, newEncounters)
  ) {
    notifications.push({ type: "milestone", milestoneValue });
  }

  if (record.is_caught && oldRecord.is_caught !== true) {
    notifications.push({ type: "caught", milestoneValue: 0 });
  }

  return notifications;
}

function exactMilestones(encounters: number): number[] {
  if (MILESTONE_VALUES.includes(encounters)) {
    return [encounters];
  }

  if (encounters >= 15000 && encounters % 5000 === 0) {
    return [encounters];
  }

  return [];
}

function crossedMilestones(
  oldEncounters: number,
  newEncounters: number,
): number[] {
  if (newEncounters <= oldEncounters) {
    return [];
  }

  const configuredMilestones = MILESTONE_VALUES.filter((value) =>
    oldEncounters < value && value <= newEncounters
  );

  const extraMilestones: number[] = [];
  const firstExtraMilestone = 15000;

  for (
    let value = Math.max(
      firstExtraMilestone,
      nextMultiple(oldEncounters + 1, 5000),
    );
    value <= newEncounters;
    value += 5000
  ) {
    extraMilestones.push(value);
  }

  return [...new Set([...configuredMilestones, ...extraMilestones])].sort((
    a,
    b,
  ) => a - b);
}

function nextMultiple(value: number, multiple: number): number {
  return Math.ceil(value / multiple) * multiple;
}

function destinationAllows(
  destination: NotificationDestination,
  notification: Notification,
): boolean {
  if (notification.type === "caught") {
    return destination.catch_notifications_enabled;
  }

  return destination.milestone_notifications_enabled;
}

async function fetchServerDestinations(): Promise<NotificationDestination[]> {
  const url = new URL(
    `${SUPABASE_URL}/rest/v1/discord_notification_destinations`,
  );

  url.searchParams.set("is_enabled", "eq.true");
  url.searchParams.set("discord_channel_id", "not.is.null");
  url.searchParams.set("discord_guild_id", "not.is.null");
  url.searchParams.set(
    "select",
    "id,user_id,discord_user_id,discord_guild_id,discord_channel_id,display_name,webhook_url,catch_notifications_enabled,milestone_notifications_enabled",
  );

  const response = await supabaseFetch(url, { method: "GET" });

  if (!response.ok) {
    throw new Error(
      `Could not fetch Discord server destinations: ${await response.text()}`,
    );
  }

  return await response.json() as NotificationDestination[];
}

async function fetchDiscordAccountLink(
  userID: string,
): Promise<DiscordAccountLink | null> {
  const url = new URL(`${SUPABASE_URL}/rest/v1/discord_account_links`);

  url.searchParams.set("user_id", `eq.${userID}`);
  url.searchParams.set("select", "discord_user_id,discord_username");
  url.searchParams.set("limit", "1");

  const response = await supabaseFetch(url, { method: "GET" });

  if (!response.ok) {
    throw new Error(
      `Could not fetch Discord account link: ${await response.text()}`,
    );
  }

  const rows = await response.json() as DiscordAccountLink[];
  return rows[0] ?? null;
}

async function cachedMembershipCheck(
  cache: Map<string, boolean>,
  guildID: string,
  discordUserID: string,
): Promise<boolean> {
  const cacheKey = `${guildID}:${discordUserID}`;
  const cachedValue = cache.get(cacheKey);

  if (cachedValue !== undefined) {
    return cachedValue;
  }

  const isMember = await isDiscordUserInGuild(guildID, discordUserID);
  cache.set(cacheKey, isMember);
  return isMember;
}

async function isDiscordUserInGuild(
  guildID: string,
  discordUserID: string,
): Promise<boolean> {
  if (!DISCORD_BOT_TOKEN) {
    return false;
  }

  const response = await fetch(
    `https://discord.com/api/v10/guilds/${guildID}/members/${discordUserID}`,
    {
      headers: {
        authorization: `Bot ${DISCORD_BOT_TOKEN}`,
      },
    },
  );

  if (response.ok) {
    return true;
  }

  if (response.status === 404) {
    console.log(
      `Discord shiny bot: linked Discord user ${discordUserID} is not in guild ${guildID}`,
    );
    return false;
  }

  console.error(
    `Discord shiny bot: could not verify guild membership for user ${discordUserID} in guild ${guildID}; status=${response.status}; body=${await response
      .text()}`,
  );
  return false;
}

function destinationForLinkedUser(
  destination: NotificationDestination,
  accountLink: DiscordAccountLink,
): NotificationDestination {
  return {
    ...destination,
    discord_user_id: accountLink.discord_user_id,
    display_name: accountLink.discord_username ?? "UniversalDex",
  };
}

async function createNotificationLog(
  record: ShinyHuntRecord,
  destination: NotificationDestination,
  notification: Notification,
): Promise<string | null> {
  const url = new URL(
    `${SUPABASE_URL}/rest/v1/shiny_hunt_discord_notifications`,
  );

  url.searchParams.set(
    "on_conflict",
    "hunt_id,destination_id,notification_type,milestone_value",
  );

  const response = await supabaseFetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Prefer": "resolution=ignore-duplicates,return=representation",
    },
    body: JSON.stringify({
      user_id: record.user_id,
      hunt_id: record.id,
      destination_id: destination.id,
      notification_type: notification.type,
      milestone_value: notification.milestoneValue,
      status: "pending",
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Could not create notification log: ${await response.text()}`,
    );
  }

  const rows = await response.json() as Array<{ id: string }>;
  return rows[0]?.id ?? null;
}

async function updateNotificationLog(
  id: string,
  values: Record<string, unknown>,
): Promise<void> {
  const url = new URL(
    `${SUPABASE_URL}/rest/v1/shiny_hunt_discord_notifications`,
  );

  url.searchParams.set("id", `eq.${id}`);

  const response = await supabaseFetch(url, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "Prefer": "return=minimal",
    },
    body: JSON.stringify(values),
  });

  if (!response.ok) {
    throw new Error(
      `Could not update notification log: ${await response.text()}`,
    );
  }
}

async function postToDiscord(
  destination: NotificationDestination,
  record: ShinyHuntRecord,
  notification: Notification,
): Promise<
  | { ok: true; messageID: string | null; responseBody: unknown }
  | { ok: false; errorMessage: string; responseBody: unknown }
> {
  if (destination.discord_channel_id) {
    return await postToDiscordChannel(destination, record, notification);
  }

  if (!destination.webhook_url) {
    return {
      ok: false,
      errorMessage:
        "Discord destination does not have a channel ID or webhook URL.",
      responseBody: null,
    };
  }

  return await postToDiscordWebhook(destination, record, notification);
}

async function postToDiscordWebhook(
  destination: NotificationDestination,
  record: ShinyHuntRecord,
  notification: Notification,
): Promise<
  | { ok: true; messageID: string | null; responseBody: unknown }
  | { ok: false; errorMessage: string; responseBody: unknown }
> {
  const response = await fetch(`${destination.webhook_url}?wait=true`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(discordPayload(destination, record, notification)),
  });

  const responseText = await response.text();
  const responseBody = safeJSON(responseText) ?? responseText;

  if (!response.ok) {
    return {
      ok: false,
      errorMessage: `Discord returned ${response.status}`,
      responseBody,
    };
  }

  return {
    ok: true,
    messageID: typeof responseBody === "object" && responseBody !== null &&
        "id" in responseBody
      ? String(responseBody.id)
      : null,
    responseBody,
  };
}

async function postToDiscordChannel(
  destination: NotificationDestination,
  record: ShinyHuntRecord,
  notification: Notification,
): Promise<
  | { ok: true; messageID: string | null; responseBody: unknown }
  | { ok: false; errorMessage: string; responseBody: unknown }
> {
  if (!DISCORD_BOT_TOKEN) {
    return {
      ok: false,
      errorMessage: "DISCORD_BOT_TOKEN is not configured.",
      responseBody: null,
    };
  }

  const response = await fetch(
    `https://discord.com/api/v10/channels/${destination.discord_channel_id}/messages`,
    {
      method: "POST",
      headers: {
        "Authorization": `Bot ${DISCORD_BOT_TOKEN}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(discordPayload(destination, record, notification)),
    },
  );

  const responseText = await response.text();
  const responseBody = safeJSON(responseText) ?? responseText;

  if (!response.ok) {
    return {
      ok: false,
      errorMessage: `Discord bot API returned ${response.status}`,
      responseBody,
    };
  }

  return {
    ok: true,
    messageID: typeof responseBody === "object" && responseBody !== null &&
        "id" in responseBody
      ? String(responseBody.id)
      : null,
    responseBody,
  };
}

function discordPayload(
  destination: NotificationDestination,
  record: ShinyHuntRecord,
  notification: Notification,
) {
  const title = displayTitle(record);
  const authorName = destination.display_name.trim() || "UniversalDex";

  if (notification.type === "caught") {
    const encounters = record.completion_encounters ?? record.encounters;
    const isFailed = record.completion_is_failed;

    return {
      username: "UniversalDex",
      content: mentionText(destination),
      embeds: [{
        author: { name: authorName },
        title: isFailed ? `${title} hunt ended` : `${title} was caught`,
        description: caughtDescription(record, encounters),
        color: isFailed ? 0x737373 : 0xf5c542,
        thumbnail: pokemonThumbnail(record),
        fields: commonFields(record, encounters),
        timestamp: record.caught_at ?? new Date().toISOString(),
      }],
      allowed_mentions: allowedMentions(destination),
    };
  }

  return {
    username: "UniversalDex",
    content: mentionText(destination),
    embeds: [{
      author: { name: authorName },
      title: `${title} hit ${
        formatNumber(notification.milestoneValue)
      } encounters`,
      description: `${
        pokemonDisplayName(record)
      } is still out there. Keep going.`,
      color: 0x5b8def,
      thumbnail: pokemonThumbnail(record),
      fields: commonFields(record, notification.milestoneValue),
      timestamp: new Date().toISOString(),
    }],
    allowed_mentions: allowedMentions(destination),
  };
}

function mentionText(destination: NotificationDestination): string | undefined {
  if (!destination.discord_user_id) {
    return undefined;
  }

  return `<@${destination.discord_user_id}>`;
}

function allowedMentions(destination: NotificationDestination) {
  if (!destination.discord_user_id) {
    return { parse: [] };
  }

  return { users: [destination.discord_user_id], parse: [] };
}

function caughtDescription(
  record: ShinyHuntRecord,
  encounters: number,
): string {
  const nickname = record.completion_nickname?.trim();
  const pokemonName = pokemonDisplayName(record);
  const suffix = nickname ? ` Nickname: ${nickname}.` : "";

  if (record.completion_is_failed) {
    return `${pokemonName} closed at ${
      formatNumber(encounters)
    } encounters.${suffix}`;
  }

  return `${pokemonName} sparkled after ${
    formatNumber(encounters)
  } encounters.${suffix}`;
}

function commonFields(record: ShinyHuntRecord, encounters: number) {
  const fields = [
    { name: "Game", value: gameName(record.game), inline: true },
    { name: "Method", value: methodName(record.method), inline: true },
    {
      name: "Odds",
      value: `1/${formatNumber(record.odds_denominator)}`,
      inline: true,
    },
    { name: "Encounters", value: formatNumber(encounters), inline: true },
  ];

  if (record.completion_ball) {
    fields.push({
      name: "Ball",
      value: ballName(record.completion_ball),
      inline: true,
    });
  }

  return fields;
}

function displayTitle(record: ShinyHuntRecord): string {
  const huntName = record.hunt_name?.trim();
  return huntName || pokemonDisplayName(record);
}

function pokemonDisplayName(record: ShinyHuntRecord): string {
  return titleCase(record.pokemon_name.replaceAll("-", " "));
}

function pokemonThumbnail(record: ShinyHuntRecord) {
  const spriteID = record.pokemon_form_id ?? record.pokemon_id;

  if (!spriteID) {
    return undefined;
  }

  return {
    url:
      `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/${spriteID}.png`,
  };
}

function parseMilestones(value: string): number[] {
  return [
    ...new Set(
      value
        .split(",")
        .map((item) => Number.parseInt(item.trim(), 10))
        .filter((item) => Number.isFinite(item) && item > 0),
    ),
  ].sort((a, b) => a - b);
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);

  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function isAuthorized(request: Request): boolean {
  const authorization = request.headers.get("authorization") ?? "";
  const headerSecret = request.headers.get("x-universaldex-bot-secret") ?? "";

  return authorization === `Bearer ${FUNCTION_SECRET}` ||
    headerSecret === FUNCTION_SECRET;
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

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function safeJSON(value: string): unknown | null {
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}

function formatNumber(value: number): string {
  return value.toLocaleString("en-US");
}

function titleCase(value: string): string {
  return value
    .split(" ")
    .filter(Boolean)
    .map((word) => `${word.charAt(0).toUpperCase()}${word.slice(1)}`)
    .join(" ");
}

function gameName(value: string): string {
  const names: Record<string, string> = {
    gold: "Gold",
    silver: "Silver",
    crystal: "Crystal",
    ruby: "Ruby",
    sapphire: "Sapphire",
    emerald: "Emerald",
    fireRed: "FireRed",
    leafGreen: "LeafGreen",
    diamond: "Diamond",
    pearl: "Pearl",
    platinum: "Platinum",
    heartGold: "HeartGold",
    soulSilver: "SoulSilver",
    black: "Black",
    white: "White",
    black2: "Black 2",
    white2: "White 2",
    x: "X",
    y: "Y",
    omegaRuby: "Omega Ruby",
    alphaSapphire: "Alpha Sapphire",
    sun: "Sun",
    moon: "Moon",
    ultraSun: "Ultra Sun",
    ultraMoon: "Ultra Moon",
    letsGoPikachu: "Let's Go, Pikachu!",
    letsGoEevee: "Let's Go, Eevee!",
    sword: "Sword",
    shield: "Shield",
    brilliantDiamond: "Brilliant Diamond",
    shiningPearl: "Shining Pearl",
    legendsArceus: "Legends: Arceus",
    scarlet: "Scarlet",
    violet: "Violet",
  };

  return names[value] ?? titleCase(value);
}

function methodName(value: string): string {
  const names: Record<string, string> = {
    randomEncounter: "Random encounter",
    shinyCharm: "Shiny Charm",
    masuda: "Masuda Method",
    masudaCharm: "Masuda + Charm",
    pokeRadarChain40: "Poke Radar chain 40",
    chainFishing: "Chain fishing",
    friendSafari: "Friend Safari",
    dexNav: "DexNav",
    sosBattle: "SOS chain",
    catchCombo31: "Catch combo 31+",
    dynamaxAdventure: "Dynamax Adventure",
    massOutbreak: "Mass outbreak",
    massiveMassOutbreak: "Massive mass outbreak",
    sandwichCharmOutbreak: "Sparkling + Charm + Outbreak",
    customOdds: "Custom odds",
  };

  return names[value] ?? titleCase(value);
}

function ballName(value: string): string {
  return titleCase(value.replaceAll("-", " "));
}
