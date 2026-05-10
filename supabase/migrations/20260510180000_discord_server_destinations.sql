-- Treat /here destinations as one posting channel per Discord server.

delete from public.discord_notification_destinations current_destination
using public.discord_notification_destinations newer_destination
where current_destination.discord_guild_id is not null
  and newer_destination.discord_guild_id = current_destination.discord_guild_id
  and (
      newer_destination.updated_at > current_destination.updated_at
      or (
          newer_destination.updated_at = current_destination.updated_at
          and newer_destination.id::text > current_destination.id::text
      )
  );

alter table public.discord_notification_destinations
    drop constraint if exists discord_notification_destinations_discord_guild_id_key;

alter table public.discord_notification_destinations
    add constraint discord_notification_destinations_discord_guild_id_key
    unique (discord_guild_id);
