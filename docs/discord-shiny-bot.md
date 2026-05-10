# Discord Shiny Bot

This is the first backend-driven version of the UniversalDex Discord shiny hunt integration.

The iOS app keeps writing shiny hunts to Supabase. Supabase then calls the `discord-shiny-bot` Edge Function whenever a row in `public.shiny_hunts` changes. The function checks whether the hunt crossed a configured encounter milestone or became caught, deduplicates the event, and posts a Discord embed through the UniversalDex bot.

## What It Supports

- Encounter milestone posts at `100`, `500`, `1000`, `2000`, `5000`, `10000`, then every `5000` after that.
- Catch posts when `is_caught` changes from false to true.
- Per-user Discord account link records.
- Discord OAuth account linking with the `identify` scope.
- Server-level Discord bot channel destinations configured by `/here`.
- Per-destination toggles for milestone and catch notifications.
- Delivery logs so the same milestone is not posted twice.

## Tables

The migration `supabase/migrations/20260510140000_discord_shiny_bot.sql` adds:

- `discord_account_links`
- `discord_notification_destinations`
- `shiny_hunt_discord_notifications`

The migration `supabase/migrations/20260510153000_discord_service_role_grants.sql` grants the Edge Function's service role access to these tables through PostgREST.

The migration `supabase/migrations/20260510160000_discord_oauth_states.sql` adds temporary OAuth state records for Discord account linking.

The migration `supabase/migrations/20260510170000_discord_bot_destinations.sql` lets destinations use `discord_channel_id` without storing a webhook URL.

The migration `supabase/migrations/20260510180000_discord_server_destinations.sql` makes `/here` destinations one posting channel per Discord server.

## Discord App Setup

In the Discord Developer Portal, create or open the UniversalDex application:

- OAuth2 redirect URL: `https://<project-ref>.functions.supabase.co/discord-oauth-callback`
- Scopes used for account linking: `identify`
- Bot invite permissions: `19456` (`View Channels`, `Send Messages`, `Embed Links`)
- Bot invite scopes: `bot applications.commands`
- Interactions endpoint URL: `https://<project-ref>.functions.supabase.co/discord-interactions`

Discord's OAuth token endpoint expects `application/x-www-form-urlencoded` requests. `/users/@me` returns the linked user's basic profile, `GET /guilds/{guild.id}/members/{user.id}` verifies that a linked Discord account belongs to a configured server, `POST /channels/{channel.id}/messages` posts the shiny hunt embed, and Discord Interactions call `discord-interactions` when a server admin runs `/here`.

The production bot invite URL must include scopes and permissions:

```text
https://discord.com/oauth2/authorize?client_id=<discord-client-id>&permissions=19456&scope=bot%20applications.commands
```

## Edge Function Environment

Set these secrets for the Supabase function:

```bash
supabase secrets set DISCORD_CLIENT_ID=...
supabase secrets set DISCORD_CLIENT_SECRET=...
supabase secrets set DISCORD_REDIRECT_URI=https://<project-ref>.functions.supabase.co/discord-oauth-callback
supabase secrets set DISCORD_BOT_TOKEN=...
supabase secrets set DISCORD_PUBLIC_KEY=...
supabase secrets set UNIVERSALDEX_DISCORD_BOT_SECRET=...
```

Do not set `SUPABASE_SERVICE_ROLE_KEY` yourself. Supabase provides `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` to Edge Functions automatically. Secret names starting with `SUPABASE_` are reserved by Supabase.

Optional:

```bash
supabase secrets set SHINY_HUNT_MILESTONES=100,500,1000,2000,5000,10000
```

`SUPABASE_URL` is provided by the Supabase Edge Function runtime.

## Deploy

```bash
supabase functions deploy discord-shiny-bot --no-verify-jwt
supabase functions deploy discord-oauth-start --no-verify-jwt
supabase functions deploy discord-oauth-callback --no-verify-jwt
supabase functions deploy discord-interactions --no-verify-jwt
```

The repo config disables Supabase JWT verification for these functions. The shiny bot webhook uses `UNIVERSALDEX_DISCORD_BOT_SECRET`; the OAuth start function validates the signed-in Supabase session manually; the OAuth callback is called by Discord; the Discord interactions function validates Discord's Ed25519 request signature with `DISCORD_PUBLIC_KEY`.

## Register The `/here` Command

After deploying `discord-interactions`, set the Interactions Endpoint URL in Discord's Developer Portal, then register the slash command:

```bash
curl -X PUT "https://discord.com/api/v10/applications/<discord-client-id>/commands" \
  -H "Authorization: Bot <discord-bot-token>" \
  -H "Content-Type: application/json" \
  -d '[{"name":"here","description":"Send my UniversalDex shiny hunt posts to this channel","type":1,"default_member_permissions":"32","contexts":[0],"integration_types":[0]}]'
```

`default_member_permissions: "32"` limits the command to members with Manage Server permission. A server admin can run `/here` in the target channel after inviting the bot; the function saves that channel as the posting destination for the Discord server.

## Wire The Database Webhook

In Supabase, create a database webhook:

- Table: `public.shiny_hunts`
- Events: `UPDATE`
- Method: `POST`
- URL: `https://<project-ref>.functions.supabase.co/discord-shiny-bot`
- Header: `Authorization: Bearer <UNIVERSALDEX_DISCORD_BOT_SECRET>`

The function expects the standard Supabase payload shape with `record` and `old_record`. It intentionally ignores payloads without `old_record`, which prevents imported or first-sync hunts from posting stale milestones.

## Configure A Destination

In UniversalDex Settings:

1. Connect Discord.
2. Invite the UniversalDex bot to a server.
3. Run `/here` in the Discord channel that should receive shiny hunt posts.
4. Refresh Discord settings.

Then update a shiny hunt from `999` to `1000` encounters. The Edge Function should post the milestone through the bot once for each configured Discord server where the linked Discord user is a member, and create one row in `shiny_hunt_discord_notifications`.

## Next App Work

The next app-facing piece is a small "send test message" action and per-destination toggles for catch and milestone posts.

Keep Discord bot tokens on the backend. The iOS app should never ship Discord secrets.
