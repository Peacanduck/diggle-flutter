-- ============================================================
-- Anti-farming Layer 2 — server-side earn-rate validation
-- Launch gate #1 for the token plan (see Tokenomics.md §7).
--
-- Philosophy: NEVER reject a legitimate award (false positives on a
-- paying player are worse than a farmer slipping one epoch). Awards
-- are always recorded; abusers get FLAGGED for review instead.
-- flagged=true already excludes players from leaderboards and the
-- future allocation snapshot. Admin can unflag after review — the
-- ledger history stays intact either way.
--
-- Threshold grounding (endgame ceilings, don't lower blindly):
--   * One full 50-slot diamond cargo sale = 500k cash -> 50k base
--     points x ~2.6 max multipliers ~= 131k points in ONE award.
--   * A superhuman 6 diamond-runs/hour ~= 810k points/hour.
--   Defaults sit above those ceilings; tune DOWN in anti_farm_config
--   as telemetry accumulates (no redeploy needed).
-- ============================================================

-- ── Config (tunable without redeploys) ──────────────────────

create table if not exists anti_farm_config (
  key text primary key,
  value bigint not null,
  updated_at timestamptz default now()
);

insert into anti_farm_config (key, value) values
  ('hard_cap_per_call',      250000),   -- reject above this (impossible)
  ('review_award_size',      200000),   -- single award: flag for review
  ('hourly_flag_threshold',  900000),   -- rolling 60m earned points
  ('daily_flag_threshold',  5000000)    -- rolling 24h earned points
on conflict (key) do nothing;

-- ── Flag audit trail ────────────────────────────────────────

create table if not exists player_flags (
  id uuid primary key default gen_random_uuid(),
  player_id uuid references players(id) on delete cascade,
  reason text not null,                 -- 'hourly_rate' | 'daily_rate' | 'large_award' | 'manual'
  details jsonb,
  resolved boolean default false,       -- true after admin review/unflag
  created_at timestamptz default now()
);

create index if not exists idx_player_flags_player
  on player_flags(player_id, created_at desc);

alter table player_flags enable row level security;
-- No client policies: flags are server/admin-only (service role bypasses RLS).

-- ── award_points v3 ─────────────────────────────────────────
-- Adds to v2 (auth binding, done 2026-07-06):
--   * hard cap raised 100k -> 250k (legit diamond-haul awards ~131k)
--   * rolling-rate checks that AUTO-FLAG instead of rejecting

create or replace function public.award_points(
  p_player_id uuid,
  p_amount bigint,
  p_source text,
  p_metadata jsonb default null::jsonb,
  p_tx_signature text default null::text
)
returns bigint
language plpgsql
security definer
set search_path = public
as $function$
declare
  new_balance bigint;
  v_hard_cap bigint;
  v_review_size bigint;
  v_hourly bigint;
  v_daily bigint;
  v_earned_1h bigint;
  v_earned_24h bigint;
  v_already_flagged boolean;
begin
  -- ── Authorization (Layer 1) ────────────────────────────────
  if auth.role() is distinct from 'service_role' then
    if auth.uid() is null then
      raise exception 'not authenticated';
    end if;
    if not exists (
      select 1 from player_auth_accounts
      where player_id = p_player_id
        and auth_user_id = auth.uid()
    ) then
      raise exception 'not authorized for this player';
    end if;
  end if;

  -- ── Hard sanity bound ──────────────────────────────────────
  select value into v_hard_cap
    from anti_farm_config where key = 'hard_cap_per_call';
  v_hard_cap := coalesce(v_hard_cap, 250000);
  if p_amount > v_hard_cap or p_amount < -v_hard_cap then
    raise exception 'amount out of range';
  end if;

  -- ── Original accounting, unchanged ─────────────────────────
  update player_stats
  set
    points = points + p_amount,
    total_points_earned = case when p_amount > 0 then total_points_earned + p_amount else total_points_earned end,
    total_points_spent = case when p_amount < 0 and p_source != 'spl_redemption' then total_points_spent + abs(p_amount) else total_points_spent end,
    total_points_redeemed = case when p_source = 'spl_redemption' then total_points_redeemed + abs(p_amount) else total_points_redeemed end,
    updated_at = now()
  where player_id = p_player_id
  returning points into new_balance;

  if new_balance < 0 then
    raise exception 'Insufficient points balance';
  end if;

  insert into points_ledger (player_id, amount, balance_after, source, metadata, tx_signature)
  values (p_player_id, p_amount, new_balance, p_source, p_metadata, p_tx_signature);

  -- ── Layer 2: rate checks -> auto-flag (never reject) ───────
  -- Only earn events count; pack purchases are paid SOL, not farmable.
  if p_amount > 0 and p_source != 'pack_purchase' then
    select flagged into v_already_flagged
      from player_stats where player_id = p_player_id;

    if not coalesce(v_already_flagged, false) then
      select value into v_review_size
        from anti_farm_config where key = 'review_award_size';
      select value into v_hourly
        from anti_farm_config where key = 'hourly_flag_threshold';
      select value into v_daily
        from anti_farm_config where key = 'daily_flag_threshold';

      -- Single suspiciously large award
      if p_amount >= coalesce(v_review_size, 200000) then
        insert into player_flags (player_id, reason, details)
        values (p_player_id, 'large_award',
                jsonb_build_object('amount', p_amount, 'source', p_source));
        update player_stats set flagged = true
          where player_id = p_player_id;
      else
        -- Rolling windows (uses idx_ledger_player)
        select coalesce(sum(amount), 0) into v_earned_1h
          from points_ledger
          where player_id = p_player_id
            and amount > 0
            and source != 'pack_purchase'
            and created_at > now() - interval '1 hour';

        if v_earned_1h >= coalesce(v_hourly, 900000) then
          insert into player_flags (player_id, reason, details)
          values (p_player_id, 'hourly_rate',
                  jsonb_build_object('earned_1h', v_earned_1h));
          update player_stats set flagged = true
            where player_id = p_player_id;
        else
          select coalesce(sum(amount), 0) into v_earned_24h
            from points_ledger
            where player_id = p_player_id
              and amount > 0
              and source != 'pack_purchase'
              and created_at > now() - interval '24 hours';

          if v_earned_24h >= coalesce(v_daily, 5000000) then
            insert into player_flags (player_id, reason, details)
            values (p_player_id, 'daily_rate',
                    jsonb_build_object('earned_24h', v_earned_24h));
            update player_stats set flagged = true
              where player_id = p_player_id;
          end if;
        end if;
      end if;
    end if;
  end if;

  return new_balance;
end;
$function$;

revoke execute on function public.award_points(uuid, bigint, text, jsonb, text) from anon, public;
grant execute on function public.award_points(uuid, bigint, text, jsonb, text) to authenticated, service_role;

-- ── Admin review helpers (run as service role / dashboard) ──

-- Everything an admin needs to judge a flag in one row.
create or replace view flag_review as
select
  f.id as flag_id,
  f.player_id,
  p.display_name,
  p.wallet_address,
  f.reason,
  f.details,
  f.resolved,
  f.created_at as flagged_at,
  s.points,
  s.total_points_earned,
  s.total_play_time_seconds,
  s.max_depth_reached,
  (select count(*) from points_ledger l
    where l.player_id = f.player_id
      and l.created_at > now() - interval '24 hours') as ledger_entries_24h
from player_flags f
join players p on p.id = f.player_id
join player_stats s on s.player_id = f.player_id
order by f.created_at desc;

-- Clear a false positive: unflag + mark the player's flags resolved.
create or replace function public.unflag_player(p_player_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() is distinct from 'service_role' then
    raise exception 'admin only';
  end if;
  update player_stats set flagged = false where player_id = p_player_id;
  update player_flags set resolved = true
    where player_id = p_player_id and not resolved;
end;
$$;

revoke execute on function public.unflag_player(uuid) from anon, public, authenticated;
grant execute on function public.unflag_player(uuid) to service_role;
