export interface DiscordAccountLink {
  user_id: string;
  discord_user_id: string;
  discord_username: string | null;
  discord_avatar_url: string | null;
}

export interface DiscordNotificationDestination {
  id: string;
  user_id: string;
  guild_id: string;
  guild_name: string | null;
  guild_icon_url: string | null;
  discord_channel_id: string | null;
  is_milestone_enabled: boolean;
  is_catch_enabled: boolean;
}
