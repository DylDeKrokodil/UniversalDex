create extension if not exists pgcrypto;

alter table public.shiny_hunts
add column if not exists overlay_token uuid not null default gen_random_uuid();

create unique index if not exists shiny_hunts_overlay_token_idx
    on public.shiny_hunts (overlay_token);
