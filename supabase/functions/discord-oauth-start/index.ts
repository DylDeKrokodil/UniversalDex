import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const SUPABASE_URL = requireEnv("SUPABASE_URL");
const SUPABASE_ANON_KEY = requireEnv("SUPABASE_ANON_KEY");
const SUPABASE_SERVICE_ROLE_KEY = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
const DISCORD_CLIENT_ID = requireEnv("DISCORD_CLIENT_ID");
const DISCORD_REDIRECT_URI = requireEnv("DISCORD_REDIRECT_URI");

type SupabaseUserResponse = {
  id: string;
};

serve(async (request) => {
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const accessToken = bearerToken(request);

  if (!accessToken) {
    return jsonResponse({ error: "Missing Supabase session token" }, 401);
  }

  const user = await fetchSupabaseUser(accessToken);
  const state = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();

  await insertOAuthState(state, user.id, expiresAt);

  const authorizationURL = new URL("https://discord.com/oauth2/authorize");
  authorizationURL.searchParams.set("client_id", DISCORD_CLIENT_ID);
  authorizationURL.searchParams.set("redirect_uri", DISCORD_REDIRECT_URI);
  authorizationURL.searchParams.set("response_type", "code");
  authorizationURL.searchParams.set("scope", "identify");
  authorizationURL.searchParams.set("state", state);
  authorizationURL.searchParams.set("prompt", "consent");

  return jsonResponse({ authorization_url: authorizationURL.toString() });
});

async function fetchSupabaseUser(
  accessToken: string,
): Promise<SupabaseUserResponse> {
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    throw new Error(
      `Could not validate Supabase session: ${await response.text()}`,
    );
  }

  return await response.json() as SupabaseUserResponse;
}

async function insertOAuthState(
  state: string,
  userID: string,
  expiresAt: string,
): Promise<void> {
  const response = await supabaseFetch("/rest/v1/discord_oauth_states", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Prefer": "return=minimal",
    },
    body: JSON.stringify({
      state,
      user_id: userID,
      expires_at: expiresAt,
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Could not create Discord OAuth state: ${await response.text()}`,
    );
  }
}

function bearerToken(request: Request): string | null {
  const authorization = request.headers.get("authorization") ?? "";
  const [scheme, token] = authorization.split(" ");

  if (scheme?.toLowerCase() !== "bearer" || !token) {
    return null;
  }

  return token;
}

function supabaseFetch(
  path: string,
  init: RequestInit & { headers?: Record<string, string> },
) {
  return fetch(`${SUPABASE_URL}${path}`, {
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

function jsonResponse(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
