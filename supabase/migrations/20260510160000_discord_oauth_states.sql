-- Temporary Discord OAuth state records for linking Discord accounts.

create table public.discord_oauth_states (
    state text primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    expires_at timestamptz not null,
    consumed_at timestamptz
);

create index discord_oauth_states_user_id_idx
    on public.discord_oauth_states (user_id);

create index discord_oauth_states_expires_at_idx
    on public.discord_oauth_states (expires_at);

alter table public.discord_oauth_states enable row level security;

grant select, insert, update, delete on public.discord_oauth_states to service_role;
