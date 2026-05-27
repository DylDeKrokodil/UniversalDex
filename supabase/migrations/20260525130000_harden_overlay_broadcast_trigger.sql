create or replace function public.broadcast_shiny_hunt_overlay_update()
returns trigger
security definer
set search_path = ''
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
exception
    when others then
        raise warning 'Could not broadcast shiny hunt overlay update for hunt %: %', new.id, sqlerrm;
        return null;
end;
$$;
