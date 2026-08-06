-- Behavioural tests for claim_daily_streak.
-- Each case asserts with a raise exception on mismatch, so a clean run
-- means everything passed.

\set ON_ERROR_STOP on

create or replace function t_reset(
  p_streak int, p_last date, p_migrated boolean
) returns uuid language plpgsql as $$
declare v_id uuid;
begin
  delete from player_auth_accounts;
  delete from player_stats;
  delete from players;
  insert into players (device_id) values ('t') returning id into v_id;
  insert into player_stats (player_id, login_streak, last_claim_date, streak_migrated)
    values (v_id, p_streak, p_last, p_migrated);
  insert into player_auth_accounts values (v_id, '11111111-1111-1111-1111-111111111111');
  perform set_config('test.auth_role', 'authenticated', false);
  perform set_config('test.auth_uid', '11111111-1111-1111-1111-111111111111', false);
  return v_id;
end;
$$;

create or replace function t_assert(
  p_label text, p_got anyelement, p_want anyelement
) returns void language plpgsql as $$
begin
  if p_got is distinct from p_want then
    raise exception 'FAIL %: got % want %', p_label, p_got, p_want;
  end if;
  raise notice 'ok  %  (%)', p_label, p_got;
end;
$$;

do $$
declare
  v_id uuid;
  v_today date := (now() at time zone 'utc')::date;
  r record;
begin
  -- ── 1. Brand new player, no local history ────────────────
  v_id := t_reset(0, null, false);
  select * into r from claim_daily_streak(v_id, 0, null);
  perform t_assert('new player streak', r.new_streak, 1);
  perform t_assert('new player claimed', r.did_claim, true);
  perform t_assert('new player points', r.reward_points, 5);
  perform t_assert('new player persisted',
    (select login_streak from player_stats where player_id = v_id), 1);
  perform t_assert('new player migrated flag',
    (select streak_migrated from player_stats where player_id = v_id), true);

  -- ── 2. Same day again is a no-op ─────────────────────────
  select * into r from claim_daily_streak(v_id, 1, v_today::text::date);
  perform t_assert('second claim same day', r.did_claim, false);
  perform t_assert('second claim no reward', r.reward_points, 0);
  perform t_assert('second claim streak held', r.new_streak, 1);

  -- ── 3. Existing player migration: local run adopted ──────
  v_id := t_reset(0, null, false);
  select * into r from claim_daily_streak(v_id, 30, v_today - 1);
  perform t_assert('migration adopts local', r.new_streak, 31);
  perform t_assert('migration pays jackpot', r.reward_points, 120);

  -- ── 4. Migration only happens once (replay blocked) ──────
  update player_stats set last_claim_date = v_today - 1 where player_id = v_id;
  select * into r from claim_daily_streak(v_id, 9999, v_today - 1);
  perform t_assert('replay capped to elapsed', r.new_streak, 32);

  -- ── 5. Post-migration inflation attempt is capped ────────
  v_id := t_reset(5, v_today - 1, true);
  select * into r from claim_daily_streak(v_id, 9999, v_today - 1);
  perform t_assert('inflation capped', r.new_streak, 6);

  -- ── 6. Consecutive day increments normally ───────────────
  v_id := t_reset(3, v_today - 1, true);
  select * into r from claim_daily_streak(v_id, 0, null);
  perform t_assert('consecutive day', r.new_streak, 4);
  perform t_assert('consecutive reward xp', r.reward_xp, 85);

  -- ── 7. Broken streak resets to 1 ─────────────────────────
  v_id := t_reset(6, v_today - 5, true);
  select * into r from claim_daily_streak(v_id, 0, null);
  perform t_assert('gap resets', r.new_streak, 1);
  perform t_assert('gap reward', r.reward_points, 5);

  -- ── 8. Offline catch-up credited, bounded by elapsed days ─
  -- Server last saw them 5 days ago at streak 10; they played offline
  -- and their device says 4 with a claim yesterday.
  v_id := t_reset(10, v_today - 5, true);
  select * into r from claim_daily_streak(v_id, 3, v_today - 1);
  perform t_assert('offline catch-up', r.new_streak, 4);

  -- ── 9. Stale local run (lapsed) is ignored ───────────────
  v_id := t_reset(2, v_today - 1, true);
  select * into r from claim_daily_streak(v_id, 900, v_today - 30);
  perform t_assert('stale local ignored', r.new_streak, 3);

  -- ── 10. Day 7+ keeps paying the jackpot rung ─────────────
  v_id := t_reset(11, v_today - 1, true);
  select * into r from claim_daily_streak(v_id, 0, null);
  perform t_assert('past jackpot streak', r.new_streak, 12);
  perform t_assert('past jackpot reward', r.reward_points, 120);

  -- ── 11. Foreign caller is rejected ───────────────────────
  v_id := t_reset(1, v_today - 1, true);
  perform set_config('test.auth_uid', '22222222-2222-2222-2222-222222222222', false);
  begin
    select * into r from claim_daily_streak(v_id, 0, null);
    raise exception 'FAIL: foreign caller was allowed';
  exception when others then
    if sqlerrm like 'FAIL%' then raise; end if;
    raise notice 'ok  foreign caller rejected (%)', sqlerrm;
  end;

  -- ── 12. Unauthenticated caller is rejected ───────────────
  perform set_config('test.auth_uid', '', false);
  begin
    select * into r from claim_daily_streak(v_id, 0, null);
    raise exception 'FAIL: anonymous caller was allowed';
  exception when others then
    if sqlerrm like 'FAIL%' then raise; end if;
    raise notice 'ok  anonymous caller rejected (%)', sqlerrm;
  end;

  -- ── 13. Service role bypasses the ownership check ────────
  perform set_config('test.auth_role', 'service_role', false);
  select * into r from claim_daily_streak(v_id, 0, null);
  perform t_assert('service role allowed', r.did_claim, true);

  raise notice '=== ALL STREAK RPC TESTS PASSED ===';
end;
$$;
