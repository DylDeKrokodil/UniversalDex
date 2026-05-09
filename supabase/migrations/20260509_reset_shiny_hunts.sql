-- UniversalDex shiny hunt schema reset
-- Development-only: this drops existing hunt data and recreates the tables.

create extension if not exists pgcrypto;

drop table if exists public.shiny_encounter_events cascade;
drop table if exists public.shiny_hunts cascade;

create table public.shiny_hunts (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,

    pokemon_id integer,
    pokemon_form_id integer,
    pokemon_name text not null,
    hunt_name text not null default '',
    game text not null,
    method text not null,
    tracking_metric text not null default 'encounters'
        check (tracking_metric in ('encounters', 'time', 'both')),
    has_shiny_charm boolean not null default false,
    odds_denominator integer not null check (odds_denominator > 0),

    encounters integer not null default 0 check (encounters >= 0),
    encounter_increment integer not null default 1 check (encounter_increment > 0),
    started_at timestamptz,
    elapsed_time double precision not null default 0 check (elapsed_time >= 0),
    timer_started_at timestamptz,

    is_caught boolean not null default false,
    caught_at timestamptz,

    completion_nickname text,
    completion_ball text,
    completion_encounters integer check (completion_encounters is null or completion_encounters >= 0),
    completion_elapsed_time double precision check (completion_elapsed_time is null or completion_elapsed_time >= 0),
    completion_is_failed boolean not null default false,

    created_at timestamptz not null default now()
);

create table public.shiny_encounter_events (
    id uuid primary key default gen_random_uuid(),
    hunt_id uuid not null references public.shiny_hunts(id) on delete cascade,
    user_id uuid not null references auth.users(id) on delete cascade,
    recorded_at timestamptz not null default now(),
    delta integer not null,
    kind text not null check (kind in ('increment', 'decrement', 'adjustment'))
);

create index shiny_hunts_user_id_created_at_idx
    on public.shiny_hunts (user_id, created_at desc);

create index shiny_hunts_user_id_is_caught_idx
    on public.shiny_hunts (user_id, is_caught);

create index shiny_encounter_events_user_id_recorded_at_idx
    on public.shiny_encounter_events (user_id, recorded_at);

create index shiny_encounter_events_hunt_id_recorded_at_idx
    on public.shiny_encounter_events (hunt_id, recorded_at);

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.shiny_hunts to authenticated;
grant select, insert, update, delete on public.shiny_encounter_events to authenticated;

alter table public.shiny_hunts enable row level security;
alter table public.shiny_encounter_events enable row level security;

create policy "Users can read their shiny hunts"
on public.shiny_hunts
for select
using (auth.uid() = user_id);

create policy "Users can insert their shiny hunts"
on public.shiny_hunts
for insert
with check (auth.uid() = user_id);

create policy "Users can update their shiny hunts"
on public.shiny_hunts
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their shiny hunts"
on public.shiny_hunts
for delete
using (auth.uid() = user_id);

create policy "Users can read their shiny encounter events"
on public.shiny_encounter_events
for select
using (auth.uid() = user_id);

create policy "Users can insert their shiny encounter events"
on public.shiny_encounter_events
for insert
with check (
    auth.uid() = user_id
    and exists (
        select 1
        from public.shiny_hunts
        where shiny_hunts.id = hunt_id
          and shiny_hunts.user_id = auth.uid()
    )
);

create policy "Users can update their shiny encounter events"
on public.shiny_encounter_events
for update
using (auth.uid() = user_id)
with check (
    auth.uid() = user_id
    and exists (
        select 1
        from public.shiny_hunts
        where shiny_hunts.id = hunt_id
          and shiny_hunts.user_id = auth.uid()
    )
);

create policy "Users can delete their shiny encounter events"
on public.shiny_encounter_events
for delete
using (auth.uid() = user_id);
