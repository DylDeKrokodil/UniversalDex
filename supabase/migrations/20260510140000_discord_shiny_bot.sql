-- UniversalDex Discord shiny hunt integration
-- Stores linked Discord accounts, opt-in notification destinations, and
-- deduplicated notification delivery records for backend-driven posting.

create extension if not exists pgcrypto;

create table public.discord_account_links (
    user_id uuid primary key references auth.users(id) on delete cascade,
    discord_user_id text not null unique,
    discord_username text,
    discord_avatar_url text,
    linked_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.discord_notification_destinations (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    discord_user_id text,
    discord_guild_id text,
    discord_channel_id text,
    display_name text not null default '',
    webhook_url text,
    check (
        (
            webhook_url is not null
            and webhook_url ~ '^https://(canary\.)?discord(app)?\.com/api/webhooks/'
        )
        or discord_channel_id is not null
    ),
    is_enabled boolean not null default true,
    catch_notifications_enabled boolean not null default true,
    milestone_notifications_enabled boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.shiny_hunt_discord_notifications (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    hunt_id uuid not null references public.shiny_hunts(id) on delete cascade,
    destination_id uuid not null references public.discord_notification_destinations(id) on delete cascade,
    notification_type text not null check (notification_type in ('milestone', 'caught')),
    milestone_value integer not null default 0 check (milestone_value >= 0),
    status text not null default 'pending' check (status in ('pending', 'posted', 'failed')),
    discord_message_id text,
    discord_response jsonb,
    error_message text,
    created_at timestamptz not null default now(),
    posted_at timestamptz,

    unique (hunt_id, destination_id, notification_type, milestone_value)
);

create index discord_notification_destinations_user_id_idx
    on public.discord_notification_destinations (user_id);

create index discord_notification_destinations_user_id_enabled_idx
    on public.discord_notification_destinations (user_id, is_enabled);

create index discord_notification_destinations_channel_id_idx
    on public.discord_notification_destinations (discord_channel_id);

create index shiny_hunt_discord_notifications_user_id_created_at_idx
    on public.shiny_hunt_discord_notifications (user_id, created_at desc);

create index shiny_hunt_discord_notifications_hunt_id_idx
    on public.shiny_hunt_discord_notifications (hunt_id);

grant select, insert, update, delete on public.discord_account_links to authenticated;
grant select, insert, update, delete on public.discord_notification_destinations to authenticated;
grant select on public.shiny_hunt_discord_notifications to authenticated;

alter table public.discord_account_links enable row level security;
alter table public.discord_notification_destinations enable row level security;
alter table public.shiny_hunt_discord_notifications enable row level security;

create policy "Users can read their Discord account link"
on public.discord_account_links
for select
using (auth.uid() = user_id);

create policy "Users can create their Discord account link"
on public.discord_account_links
for insert
with check (auth.uid() = user_id);

create policy "Users can update their Discord account link"
on public.discord_account_links
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their Discord account link"
on public.discord_account_links
for delete
using (auth.uid() = user_id);

create policy "Users can read their Discord notification destinations"
on public.discord_notification_destinations
for select
using (auth.uid() = user_id);

create policy "Users can create their Discord notification destinations"
on public.discord_notification_destinations
for insert
with check (auth.uid() = user_id);

create policy "Users can update their Discord notification destinations"
on public.discord_notification_destinations
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their Discord notification destinations"
on public.discord_notification_destinations
for delete
using (auth.uid() = user_id);

create policy "Users can read their Discord notification log"
on public.shiny_hunt_discord_notifications
for select
using (auth.uid() = user_id);
