create or replace function public.broadcast_shiny_hunt_overlay_update()
returns trigger
security definer
set search_path = public, realtime
language plpgsql
as $$
begin
    perform realtime.send(
        jsonb_build_object(
            'pokemon_id', new.pokemon_id,
            'pokemon_form_id', new.pokemon_form_id,
            'pokemon_name', new.pokemon_name,
            'hunt_name', new.hunt_name,
            'gender', new.gender,
            'game', new.game,
            'encounters', new.encounters,
            'encounter_increment', new.encounter_increment,
            'tracking_metric', new.tracking_metric,
            'is_caught', new.is_caught
        ),
        'overlay-update',
        'overlay:' || new.overlay_token::text,
        false
    );

    return null;
end;
$$;

drop trigger if exists broadcast_shiny_hunt_overlay_update_trigger on public.shiny_hunts;

create trigger broadcast_shiny_hunt_overlay_update_trigger
after update of
    pokemon_id,
    pokemon_form_id,
    pokemon_name,
    hunt_name,
    gender,
    game,
    encounters,
    encounter_increment,
    tracking_metric,
    is_caught
on public.shiny_hunts
for each row
when (
    old.pokemon_id is distinct from new.pokemon_id
    or old.pokemon_form_id is distinct from new.pokemon_form_id
    or old.pokemon_name is distinct from new.pokemon_name
    or old.hunt_name is distinct from new.hunt_name
    or old.gender is distinct from new.gender
    or old.game is distinct from new.game
    or old.encounters is distinct from new.encounters
    or old.encounter_increment is distinct from new.encounter_increment
    or old.tracking_metric is distinct from new.tracking_metric
    or old.is_caught is distinct from new.is_caught
)
execute function public.broadcast_shiny_hunt_overlay_update();
