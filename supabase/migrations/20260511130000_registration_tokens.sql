-- Table for storing registration tokens
create table if not exists public.registration_tokens (
    token text primary key,
    created_at timestamptz default now(),
    used_at timestamptz,
    used_by_user_id uuid,
    is_active boolean default true
);

-- Enable Row Level Security
alter table public.registration_tokens enable row level security;

-- Function to check token validity
create or replace function public.is_token_valid(input_token text)
returns boolean as $$
begin
    return exists (
        select 1 
        from public.registration_tokens 
        where token = input_token 
          and used_by_user_id is null 
          and is_active = true
    );
end;
$$ language plpgsql security definer;

-- Trigger function to validate and consume token on user creation
create or replace function public.handle_registration_token()
returns trigger as $$
declare
    reg_token text;
begin
    -- Retrieve token from user metadata
    reg_token := new.raw_user_meta_data->>'registration_token';
    
    if reg_token is null then
        raise exception 'Registration token required';
    end if;

    -- Validate token availability
    if not exists (
        select 1 
        from public.registration_tokens 
        where token = reg_token 
          and used_by_user_id is null 
          and is_active = true
    ) then
        raise exception 'Invalid or consumed registration token';
    end if;

    -- Update token status
    update public.registration_tokens
    set used_at = now(),
        used_by_user_id = new.id
    where token = reg_token;

    return new;
end;
$$ language plpgsql security definer;

-- Bind trigger to auth.users table
drop trigger if exists on_auth_user_created_token_check on auth.users;

create trigger on_auth_user_created_token_check
    after insert on auth.users
    for each row execute procedure public.handle_registration_token();

-- Seed initial secure registration tokens
insert into public.registration_tokens (token)
values 
('H7W-K9Q-X2P'), ('B4V-R8M-L5S'), ('Z3N-G6T-D9J'), ('P1X-Y4K-W7Q'), ('C9M-S2L-V5H'),
('F8R-N3B-J6T'), ('G2K-Q9W-P4X'), ('D5H-V7M-S8L'), ('W1Q-X4P-Y9K'), ('J6T-B3N-G8R'),
('L5S-V2M-C9H'), ('K4Y-W1Q-X7P'), ('M8L-D5H-V2S'), ('N3B-F8R-J6T'), ('Q9W-G2K-P4X'),
('R8M-B4V-L5S'), ('S7L-H2P-V9M'), ('T6G-J3N-B8R'), ('V5H-C9M-S2L'), ('X4P-K1Y-W9Q')
on conflict (token) do nothing;
