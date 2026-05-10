# Discord Shiny Bot

This is the first backend-driven version of the UniversalDex Discord shiny hunt integration.

The iOS app keeps writing shiny hunts to Supabase. Supabase then calls the `discord-shiny-bot` Edge Function whenever a row in `public.shiny_hunts` changes. The function checks whether the hunt crossed a configured encounter milestone or became caught, deduplicates the event, and posts a Discord webhook embed.

## What It Supports

- Encounter milestone posts at `100`, `500`, `1000`, `2000`, `5000`, `10000`, then every `5000` after that.
- Catch posts when `is_caught` changes from false to true.
- Per-user Discord account link records.
- Per-user Discord webhook destinations.
- Per-destination toggles for milestone and catch notifications.
- Delivery logs so the same milestone is not posted twice.

## Tables

The migration `supabase/migrations/20260510_discord_shiny_bot.sql` adds:

- `discord_account_links`
- `discord_notification_destinations`
- `shiny_hunt_discord_notifications`

The migration `supabase/migrations/20260510153000_discord_service_role_grants.sql` grants the Edge Function's service role access to these tables through PostgREST.

The destination table stores Discord webhook URLs. Treat these as secrets: only insert them after a user explicitly connects a destination, and avoid exposing them in UI once saved.

## Edge Function Environment

Set these secrets for the Supabase function:

```bash
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
```

The repo config disables Supabase JWT verification for this function because database webhooks use the `UNIVERSALDEX_DISCORD_BOT_SECRET` header instead.

## Wire The Database Webhook

In Supabase, create a database webhook:

- Table: `public.shiny_hunts`
- Events: `UPDATE`
- Method: `POST`
- URL: `https://<project-ref>.functions.supabase.co/discord-shiny-bot`
- Header: `Authorization: Bearer <UNIVERSALDEX_DISCORD_BOT_SECRET>`

The function expects the standard Supabase payload shape with `record` and `old_record`. It intentionally ignores payloads without `old_record`, which prevents imported or first-sync hunts from posting stale milestones.

## Add A Test Destination

After a UniversalDex user has a Discord webhook URL, insert a destination:

```sql
insert into public.discord_notification_destinations (
    user_id,
    discord_user_id,
    discord_guild_id,
    discord_channel_id,
    display_name,
    webhook_url
) values (
    '<supabase-user-id>',
    '<discord-user-id>',
    '<guild-id>',
    '<channel-id>',
    'Dylan',
    'https://discord.com/api/webhooks/...'
);
```

Then update a shiny hunt from `999` to `1000` encounters. The Edge Function should post the milestone once and create one row in `shiny_hunt_discord_notifications`.

## Next App Work

The next app-facing piece is a Discord settings screen:

- "Connect Discord" account link.
- "Add Discord channel" destination setup.
- Toggles for catch posts and milestone posts.
- A small "send test message" action.

Keep Discord bot tokens and webhook management on the backend. The iOS app should never ship Discord secrets.
