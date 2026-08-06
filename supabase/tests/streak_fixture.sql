-- Minimal stand-in for the Supabase pieces claim_daily_streak depends on,
-- so the real migration can run unmodified against stock Postgres.

-- Roles Supabase provides out of the box.
do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    create role service_role nologin;
  end if;
end $$;

create schema if not exists auth;

-- Tests flip these via set_config.
create or replace function auth.role() returns text language sql stable as $$
  select coalesce(current_setting('test.auth_role', true), 'authenticated');
$$;

create or replace function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('test.auth_uid', true), '')::uuid;
$$;

create table players (
  id uuid primary key default gen_random_uuid(),
  wallet_address text unique,
  device_id text unique,
  display_name text,
  created_at timestamptz default now()
);

create table player_stats (
  player_id uuid primary key references players(id) on delete cascade,
  xp bigint default 0,
  points bigint default 0,
  level int default 1,
  total_points_earned bigint default 0,
  total_play_time_seconds bigint default 0,
  prestige_level int default 0,
  login_streak int default 0,
  last_claim_date date,
  flagged boolean default false,
  updated_at timestamptz default now()
);

create table player_auth_accounts (
  player_id uuid references players(id) on delete cascade,
  auth_user_id uuid,
  primary key (player_id, auth_user_id)
);
