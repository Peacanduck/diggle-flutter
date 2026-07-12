-- ============================================================
-- Diggle v2.0 overhaul — Supabase schema changes
-- Apply in the Supabase SQL editor (or via supabase db push).
-- Covers: Phase 1 (streaks/ledger sources), Phase 2 (prestige,
-- leaderboards, weekly challenge), Phase 3 (NFT gear verification).
-- ============================================================

-- ── player_stats: new columns ───────────────────────────────

alter table player_stats
  add column if not exists prestige_level int default 0,
  add column if not exists login_streak int default 0,
  add column if not exists last_claim_date date,
  add column if not exists flagged boolean default false,
  add column if not exists total_cash_earned bigint default 0;

comment on column player_stats.flagged is
  'Set by anti-cheat checks. Flagged players are excluded from '
  'leaderboards and any future token allocation snapshot.';

-- ── daily_claims: server-side login streak audit ────────────
-- Prevents clock-rollback streak farming: one claim per UTC day.

create table if not exists daily_claims (
  player_id uuid references players(id) on delete cascade,
  claim_date date not null,
  streak int not null,
  created_at timestamptz default now(),
  primary key (player_id, claim_date)
);

alter table daily_claims enable row level security;

create policy "daily_claims_own" on daily_claims
  for all using (player_id = auth.uid());

-- ── weekly_scores: weekly challenge runs ────────────────────

create table if not exists weekly_scores (
  player_id uuid references players(id) on delete cascade,
  week text not null,                 -- ISO week key, e.g. '2026-W27'
  depth int not null default 0,
  cash_earned bigint not null default 0,
  updated_at timestamptz default now(),
  primary key (player_id, week)
);

alter table weekly_scores enable row level security;

-- Players may read all weekly scores (public leaderboard),
-- but writes only happen through the RPC below.
create policy "weekly_scores_read" on weekly_scores
  for select using (true);

-- Best-score-wins submission. SECURITY DEFINER so the table itself
-- needs no insert/update policy for clients.
create or replace function submit_weekly_score(
  p_week text,
  p_depth int,
  p_cash_earned bigint
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- Basic sanity caps (world floor ~450; cash capped generously).
  if p_depth < 0 or p_depth > 460 or p_cash_earned < 0
     or p_cash_earned > 10000000 then
    raise exception 'score out of range';
  end if;

  insert into weekly_scores (player_id, week, depth, cash_earned, updated_at)
  values (auth.uid(), p_week, p_depth, p_cash_earned, now())
  on conflict (player_id, week) do update
    set depth = greatest(weekly_scores.depth, excluded.depth),
        cash_earned = greatest(weekly_scores.cash_earned,
                               excluded.cash_earned),
        updated_at = now();
end;
$$;

-- ── Leaderboard views ───────────────────────────────────────
-- Views run as owner, so clients can read them without RLS holes.
-- Only non-flagged players appear.

create or replace view leaderboard_global
with (security_invoker = off) as
select
  coalesce(p.display_name, 'Anonymous Miner') as display_name,
  s.max_depth_reached,
  s.total_points_earned,
  s.total_cash_earned,
  s.prestige_level
from player_stats s
join players p on p.id = s.player_id
where not coalesce(s.flagged, false);

create or replace view leaderboard_weekly
with (security_invoker = off) as
select
  coalesce(p.display_name, 'Anonymous Miner') as display_name,
  w.week,
  w.depth,
  w.cash_earned
from weekly_scores w
join players p on p.id = w.player_id
left join player_stats s on s.player_id = w.player_id
where not coalesce(s.flagged, false);

grant select on leaderboard_global to anon, authenticated;
grant select on leaderboard_weekly to anon, authenticated;

-- ── player_gear: Phase 3 NFT gear verification ──────────────
-- Client-side detection is enough for offline play; this table is
-- the server-side truth used by leaderboards / token snapshots.

create table if not exists player_gear (
  player_id uuid references players(id) on delete cascade,
  mint_address text not null,
  traits jsonb,
  verified boolean default false,     -- set by verify-gear edge function
  equipped_at timestamptz default now(),
  primary key (player_id, mint_address)
);

alter table player_gear enable row level security;

create policy "player_gear_own" on player_gear
  for all using (player_id = auth.uid());

-- ── points_ledger: source whitelist note ────────────────────
-- Phase 1 uses 'achievement' (already whitelisted) with
-- metadata.bonus_type in ('loot_crate','artifact','collection',
-- 'achievement','streak') — no whitelist change required.
-- If award_points() validates sources, confirm 'achievement' passes.
