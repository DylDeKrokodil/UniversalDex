-- Allow Discord destinations to use bot channel posting instead of webhooks.

alter table public.discord_notification_destinations
    alter column webhook_url drop not null;

alter table public.discord_notification_destinations
    drop constraint if exists discord_notification_destinations_webhook_url_check;

alter table public.discord_notification_destinations
    drop constraint if exists discord_notification_destinations_delivery_target_check;

alter table public.discord_notification_destinations
    add constraint discord_notification_destinations_delivery_target_check
    check (
        (
            webhook_url is not null
            and webhook_url ~ '^https://(canary\.)?discord(app)?\.com/api/webhooks/'
        )
        or discord_channel_id is not null
    );

create index if not exists discord_notification_destinations_channel_id_idx
    on public.discord_notification_destinations (discord_channel_id);
