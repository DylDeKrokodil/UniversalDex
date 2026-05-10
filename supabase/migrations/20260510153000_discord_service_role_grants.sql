-- Allow the Discord Edge Function to read destinations and write delivery logs
-- through PostgREST using Supabase's service role key.

grant select, insert, update, delete on public.discord_account_links to service_role;
grant select, insert, update, delete on public.discord_notification_destinations to service_role;
grant select, insert, update, delete on public.shiny_hunt_discord_notifications to service_role;
