-- ============================================================
-- Server-owned login streak
--
-- Moves the daily streak from device-local SharedPreferences to the
-- server, so `player_stats.login_streak` is finally populated and the
-- drip distributor's streak_factor stops computing as 1.0 for everyone.
--
-- Scope note: this RPC owns the STREAK STATE only (login_streak,
-- last_claim_date). It deliberately does NOT award the XP/points
-- itself — StatsService._syncStats writes absolute xp/points values
-- computed from local state, so a server-side award would be silently
-- overwritten by the next client sync. Instead the RPC returns the
-- reward and the client applies it through the existing
-- XPStatsBridge.awardBonus path (local update + award_points ledger
-- entry + anti-farm checks). The value that needed protecting is the
-- streak day, and that is now server-computed.
--
-- Backwards compatibility:
--   * Every schema change is additive. Old app builds never call the
--     RPC and keep claiming against local prefs — nothing breaks.
--   * `last_claim_date` already exists (20260705_v2_overhaul).
--   * Existing players carry a streak the server has never seen. The
--     first server claim adopts it (see one-shot migration below) so
--     loyal players are not reset to day 1.
-- ============================================================

-- ── Schema (additive) ───────────────────────────────────────

alter table player_stats
  add column if not exists streak_migrated boolean default false;

comment on column player_stats.streak_migrated is
  'True once the pre-server device-local streak has been adopted. '
  'Gates the one-shot trust of client-supplied streak history in '
  'claim_daily_streak() so it can never be replayed to inflate.';

-- Reward ladder, server-authoritative and tunable without a release.
-- Mirrors StreakSystem.rewardLadder in the client (used there for
-- display and offline claims).
create table if not exists streak_rewards (
  day int primary key,
  xp int not null,
  points int not null
);

insert into streak_rewards (day, xp, points) values
  (1,  25,   5),
  (2,  40,  10),
  (3,  60,  15),
  (4,  85,  25),
  (5, 115,  35),
  (6, 150,  50),
  (7, 300, 120)   -- jackpot; the highest day repeats for day 7+
on conflict (day) do nothing;

alter table streak_rewards enable row level security;

-- Readable by clients (it is literally the ladder shown in the UI),
-- writable only by the service role.
drop policy if exists streak_rewards_read on streak_rewards;
create policy streak_rewards_read on streak_rewards
  for select using (true);

grant select on streak_rewards to anon, authenticated;

-- ── claim_daily_streak ──────────────────────────────────────
--
-- The client sends the state it holds locally (streak count + last
-- claim date) so pre-server history and offline days can be honored.
-- Client input is never trusted beyond what the calendar allows:
--
--   * before migration — adopt the local run once (existing players)
--   * after migration  — cap at server_streak + days actually elapsed,
--                        so a modified client cannot mint streak days
--
-- Day boundaries are computed from the SERVER clock in UTC, matching
-- the client's existing UTC-day logic and QuestSystem's daily reset.

create or replace function public.claim_daily_streak(
  p_player_id uuid,
  p_local_streak int default 0,
  p_local_last_claim date default null
)
returns table (
  new_streak int,
  did_claim boolean,
  reward_xp int,
  reward_points int,
  claim_date date,
  was_migrated boolean
)
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_today date := (now() at time zone 'utc')::date;
  v_streak int;
  v_last date;
  v_migrated boolean;
  v_server_next int;
  v_client_next int := 0;
  v_cap int;
  v_new int;
  v_max_day int;
begin
  -- ── Authorization (same posture as award_points) ───────────
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

  -- Lock the row: two devices claiming at once must not both award.
  select s.login_streak, s.last_claim_date, coalesce(s.streak_migrated, false)
    into v_streak, v_last, v_migrated
    from player_stats s
   where s.player_id = p_player_id
     for update;

  if not found then
    raise exception 'no stats row for player %', p_player_id;
  end if;

  v_streak := coalesce(v_streak, 0);

  -- ── Already claimed today: idempotent no-op ────────────────
  if v_last = v_today then
    return query select v_streak, false, 0, 0, v_last, v_migrated;
    return;
  end if;

  -- What the server can justify on its own record alone.
  v_server_next := case
    when v_last = v_today - 1 then v_streak + 1
    else 1
  end;

  -- What the client asserts. Only meaningful when its run actually
  -- reaches into today; an older local claim is a broken streak.
  if p_local_last_claim = v_today then
    -- Client already claimed locally today (offline), so its count
    -- already includes today.
    v_client_next := greatest(coalesce(p_local_streak, 0), 0);
  elsif p_local_last_claim = v_today - 1 then
    v_client_next := greatest(coalesce(p_local_streak, 0), 0) + 1;
  end if;

  if not v_migrated then
    -- One-shot: adopt the device-local history of an existing player.
    v_cap := v_client_next;
  else
    -- Steady state: you cannot have claimed more days than have
    -- passed since the server last saw you.
    v_cap := v_streak + coalesce(v_today - v_last, 1);
  end if;

  v_new := greatest(v_server_next, least(v_client_next, v_cap), 1);

  update player_stats
     set login_streak = v_new,
         last_claim_date = v_today,
         streak_migrated = true,
         updated_at = now()
   where player_id = p_player_id;

  -- Day 7+ repeats the top rung.
  select max(r.day) into v_max_day from streak_rewards r;

  return query
    select v_new, true, r.xp, r.points, v_today, v_migrated
      from streak_rewards r
     where r.day = least(v_new, v_max_day);
end;
$function$;

revoke execute on function public.claim_daily_streak(uuid, int, date)
  from anon, public;
grant execute on function public.claim_daily_streak(uuid, int, date)
  to authenticated, service_role;

-- ── Admin view: streak health / drip input sanity ───────────

create or replace view streak_review as
select
  p.id as player_id,
  p.display_name,
  p.wallet_address,
  s.login_streak,
  s.last_claim_date,
  s.streak_migrated,
  case
    when s.last_claim_date is null then 'never claimed'
    when s.last_claim_date = (now() at time zone 'utc')::date then 'claimed today'
    when s.last_claim_date = (now() at time zone 'utc')::date - 1 then 'due today'
    else 'lapsed'
  end as streak_state,
  s.flagged
from players p
join player_stats s on s.player_id = p.id
where coalesce(s.login_streak, 0) > 0
order by s.login_streak desc;

revoke all on streak_review from anon, public, authenticated;
grant select on streak_review to service_role;
