-- Add gender column to shiny_hunts table

alter table public.shiny_hunts
add column gender text not null default 'male'
check (gender in ('male', 'female', 'genderless'));
