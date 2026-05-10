import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const SUPABASE_URL = requireEnv("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
const DISCORD_CLIENT_ID = requireEnv("DISCORD_CLIENT_ID");
const DISCORD_CLIENT_SECRET = requireEnv("DISCORD_CLIENT_SECRET");
const DISCORD_REDIRECT_URI = requireEnv("DISCORD_REDIRECT_URI");

type OAuthStateRow = {
  state: string;
  user_id: string;
  expires_at: string;
  consumed_at: string | null;
};

type DiscordTokenResponse = {
  access_token: string;
  token_type: string;
};

type DiscordUser = {
  id: string;
  username: string;
  global_name?: string | null;
  avatar?: string | null;
};

serve(async (request) => {
  if (request.method !== "GET") {
    return htmlResponse("Method not allowed", 405);
  }

  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  const error = url.searchParams.get("error");

  if (error) {
    return htmlPage(
      "Discord connection cancelled",
      "Discord did not authorize UniversalDex.",
    );
  }

  if (!code || !state) {
    return htmlPage(
      "Discord connection failed",
      "The Discord callback was missing required data.",
      400,
    );
  }

  const stateRow = await fetchOAuthState(state);

  if (
    !stateRow || stateRow.consumed_at ||
    new Date(stateRow.expires_at) <= new Date()
  ) {
    return htmlPage(
      "Discord connection expired",
      "Start the Discord connection again from UniversalDex.",
      400,
    );
  }

  const token = await exchangeCode(code);
  const discordUser = await fetchDiscordUser(token.access_token);

  await upsertDiscordAccountLink(stateRow.user_id, discordUser);
  await consumeOAuthState(state);

  return htmlPage(
    "Discord connected",
    "You can close this tab and return to UniversalDex.",
  );
});

async function fetchOAuthState(state: string): Promise<OAuthStateRow | null> {
  const url = new URL(`${SUPABASE_URL}/rest/v1/discord_oauth_states`);

  url.searchParams.set("state", `eq.${state}`);
  url.searchParams.set("select", "state,user_id,expires_at,consumed_at");
  url.searchParams.set("limit", "1");

  const response = await supabaseFetch(url, { method: "GET" });

  if (!response.ok) {
    throw new Error(
      `Could not read Discord OAuth state: ${await response.text()}`,
    );
  }

  const rows = await response.json() as OAuthStateRow[];
  return rows[0] ?? null;
}

async function exchangeCode(code: string): Promise<DiscordTokenResponse> {
  const body = new URLSearchParams();

  body.set("client_id", DISCORD_CLIENT_ID);
  body.set("client_secret", DISCORD_CLIENT_SECRET);
  body.set("grant_type", "authorization_code");
  body.set("code", code);
  body.set("redirect_uri", DISCORD_REDIRECT_URI);

  const response = await fetch("https://discord.com/api/oauth2/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body,
  });

  if (!response.ok) {
    throw new Error(
      `Could not exchange Discord OAuth code: ${await response.text()}`,
    );
  }

  return await response.json() as DiscordTokenResponse;
}

async function fetchDiscordUser(accessToken: string): Promise<DiscordUser> {
  const response = await fetch("https://discord.com/api/users/@me", {
    headers: {
      authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    throw new Error(`Could not fetch Discord user: ${await response.text()}`);
  }

  return await response.json() as DiscordUser;
}

async function upsertDiscordAccountLink(
  userID: string,
  discordUser: DiscordUser,
): Promise<void> {
  const response = await supabaseFetch(
    new URL(`${SUPABASE_URL}/rest/v1/discord_account_links`),
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates,return=minimal",
      },
      body: JSON.stringify({
        user_id: userID,
        discord_user_id: discordUser.id,
        discord_username: discordUser.global_name ?? discordUser.username,
        discord_avatar_url: avatarURL(discordUser),
        updated_at: new Date().toISOString(),
      }),
    },
  );

  if (!response.ok) {
    throw new Error(
      `Could not save Discord account link: ${await response.text()}`,
    );
  }
}

async function consumeOAuthState(state: string): Promise<void> {
  const url = new URL(`${SUPABASE_URL}/rest/v1/discord_oauth_states`);

  url.searchParams.set("state", `eq.${state}`);

  const response = await supabaseFetch(url, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      "Prefer": "return=minimal",
    },
    body: JSON.stringify({
      consumed_at: new Date().toISOString(),
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Could not consume Discord OAuth state: ${await response.text()}`,
    );
  }
}

function avatarURL(user: DiscordUser): string | null {
  if (!user.avatar) {
    return null;
  }

  return `https://cdn.discordapp.com/avatars/${user.id}/${user.avatar}.png?size=128`;
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

function htmlPage(title: string, message: string, status = 200): Response {
  return htmlResponse(`${title}\n\n${message}`, status);
}

function htmlResponse(body: string, status = 200): Response {
  return new Response(body, {
    status,
    headers: { "Content-Type": "text/plain; charset=utf-8" },
  });
}
