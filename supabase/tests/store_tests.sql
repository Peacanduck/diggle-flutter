-- Behavioural tests for award_points v4 (retired store sources) and
-- the Miner's Pass RPCs. Each case raises on mismatch, so a clean run
-- means everything passed.

\set ON_ERROR_STOP on

create or replace function t_reset() returns uuid language plpgsql as $$
declare v_id uuid;
begin
  delete from miners_passes;
  delete from miners_pass_orders;
  delete from points_ledger;
  delete from player_auth_accounts;
  delete from player_stats;
  delete from players;
  insert into players (device_id) values ('t') returning id into v_id;
  insert into player_stats (player_id, points) values (v_id, 1000);
  insert into player_auth_accounts values (v_id, '11111111-1111-1111-1111-111111111111');
  perform t_as_player();
  return v_id;
end;
$$;

create or replace function t_as_player() returns void language plpgsql as $$
begin
  perform set_config('test.auth_role', 'authenticated', false);
  perform set_config('test.auth_uid', '11111111-1111-1111-1111-111111111111', false);
end;
$$;

create or replace function t_as_service() returns void language plpgsql as $$
begin
  perform set_config('test.auth_role', 'service_role', false);
  perform set_config('test.auth_uid', '', false);
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

-- Runs p_sql and asserts it raises an error whose message contains
-- p_expect. The failed statement's effects are rolled back.
create or replace function t_expect_error(
  p_label text, p_sql text, p_expect text
) returns void language plpgsql as $$
begin
  begin
    execute p_sql;
  exception when others then
    if position(p_expect in sqlerrm) = 0 then
      raise exception 'FAIL %: error "%" does not mention "%"',
        p_label, sqlerrm, p_expect;
    end if;
    raise notice 'ok  %  (raised: %)', p_label, sqlerrm;
    return;
  end;
  raise exception 'FAIL %: expected an error mentioning "%"', p_label, p_expect;
end;
$$;

create or replace function t_new_order(p_player uuid) returns uuid
language plpgsql as $$
declare v_id uuid;
begin
  insert into miners_pass_orders (player_id, network, buyer, amount_base)
  values (p_player, 'mainnet', 'BuyerWallet111', 100000000)
  returning id into v_id;
  return v_id;
end;
$$;

do $$
declare
  v_id uuid;
  v_order uuid;
  v_order2 uuid;
  v_week text;
  v_balance bigint;
begin
  -- ════ award_points v4: retired store sources ═══════════════

  -- ── 1. Client can no longer self-award a points pack ─────
  v_id := t_reset();
  perform t_expect_error('client pack_purchase rejected',
    format('select award_points(%L, 50000, %L)', v_id, 'pack_purchase'),
    'source pack_purchase is retired');
  perform t_assert('rejected pack left balance alone',
    (select points from player_stats where player_id = v_id), 1000::bigint);
  perform t_assert('rejected pack wrote no ledger row',
    (select count(*) from points_ledger where player_id = v_id), 0::bigint);

  -- ── 2. Same for the booster audit source ─────────────────
  perform t_expect_error('client booster_purchase rejected',
    format('select award_points(%L, 0, %L)', v_id, 'booster_purchase'),
    'source booster_purchase is retired');

  -- ── 3. Service role can still write it (admin correction) ─
  perform t_as_service();
  v_balance := award_points(v_id, 500, 'pack_purchase');
  perform t_assert('service pack_purchase allowed', v_balance, 1500::bigint);
  perform t_as_player();

  -- ── 4. Ordinary earn and spend sources still work ────────
  v_balance := award_points(v_id, 25, 'mining');
  perform t_assert('client mining award', v_balance, 1525::bigint);
  v_balance := award_points(v_id, -25, 'shop_spend');
  perform t_assert('client shop spend', v_balance, 1500::bigint);

  -- ── 5. Authorization unchanged: foreign caller rejected ──
  perform set_config('test.auth_uid', '22222222-2222-2222-2222-222222222222', false);
  perform t_expect_error('foreign caller rejected',
    format('select award_points(%L, 25, %L)', v_id, 'mining'),
    'not authorized for this player');
  perform t_as_player();

  -- ════ iso_week_key parity with QuestSystem.isoWeekKey ══════

  perform t_assert('week mid-year',
    iso_week_key('2026-09-29 12:00+00'), '2026-W40');
  perform t_assert('week 53 (Thursday)',
    iso_week_key('2026-12-31 12:00+00'), '2026-W53');
  perform t_assert('Jan 1 belongs to previous ISO year',
    iso_week_key('2027-01-01 12:00+00'), '2026-W53');
  perform t_assert('first ISO week of 2027',
    iso_week_key('2027-01-04 00:00+00'), '2027-W01');
  perform t_assert('UTC, not session time zone',
    iso_week_key('2027-01-03 23:30-05'), '2027-W01');
  perform t_assert('single-digit week is zero-padded',
    iso_week_key('2026-01-05 12:00+00'), '2026-W02');

  -- ════ fulfill_miners_pass_order ════════════════════════════

  -- ── 6. Clients cannot fulfil their own order ─────────────
  v_id := t_reset();
  v_order := t_new_order(v_id);
  perform t_expect_error('client cannot fulfil',
    format('select fulfill_miners_pass_order(%L, %L)', v_order, 'sigA'),
    'service role only');
  perform t_assert('client attempt left order pending',
    (select status from miners_pass_orders where id = v_order), 'pending');

  -- ── 7. Service role fulfils: pass granted for this week ──
  perform t_as_service();
  v_week := fulfill_miners_pass_order(v_order, 'sigA');
  perform t_assert('grants current week', v_week, iso_week_key(now()));
  perform t_assert('order marked paid',
    (select status from miners_pass_orders where id = v_order), 'paid');
  perform t_assert('order records signature',
    (select tx_signature from miners_pass_orders where id = v_order), 'sigA');
  perform t_assert('pass row created',
    (select count(*) from miners_passes
      where player_id = v_id and network = 'mainnet' and week_key = v_week),
    1::bigint);

  -- ── 8. Retrying /confirm is idempotent ───────────────────
  perform t_assert('re-fulfil same signature',
    fulfill_miners_pass_order(v_order, 'sigA'), v_week);
  perform t_assert('still one pass row',
    (select count(*) from miners_passes where player_id = v_id), 1::bigint);

  -- ── 9. A paid order cannot be re-pointed at another tx ───
  perform t_expect_error('paid order, different signature',
    format('select fulfill_miners_pass_order(%L, %L)', v_order, 'sigB'),
    'already paid by another transaction');

  -- ── 10. One transfer cannot pay two orders ───────────────
  v_order2 := t_new_order(v_id);
  perform t_expect_error('signature reuse rejected',
    format('select fulfill_miners_pass_order(%L, %L)', v_order2, 'sigA'),
    'duplicate key');
  perform t_assert('reused-signature order rolled back to pending',
    (select status from miners_pass_orders where id = v_order2), 'pending');

  -- ── 11. Failed orders stay failed ────────────────────────
  update miners_pass_orders set status = 'failed' where id = v_order2;
  perform t_expect_error('failed order rejected',
    format('select fulfill_miners_pass_order(%L, %L)', v_order2, 'sigC'),
    'is failed');

  -- ── 12. Unknown order ────────────────────────────────────
  perform t_expect_error('unknown order rejected',
    format('select fulfill_miners_pass_order(%L, %L)',
      '00000000-0000-0000-0000-000000000000', 'sigD'),
    'not found');

  -- ── 13. Second paid order in the same week: no duplicate pass
  v_order2 := t_new_order(v_id);
  perform t_assert('second order same week',
    fulfill_miners_pass_order(v_order2, 'sigE'), v_week);
  perform t_assert('pass not duplicated',
    (select count(*) from miners_passes where player_id = v_id), 1::bigint);

  -- ── 14. Devnet pass never counts as a mainnet pass ───────
  v_order2 := t_new_order(v_id);
  update miners_pass_orders set network = 'devnet' where id = v_order2;
  perform fulfill_miners_pass_order(v_order2, 'sigF');
  perform t_assert('devnet pass stored separately',
    (select count(*) from miners_passes
      where player_id = v_id and network = 'devnet'), 1::bigint);
  perform t_assert('mainnet pass count unchanged',
    (select count(*) from miners_passes
      where player_id = v_id and network = 'mainnet'), 1::bigint);

  -- ── 15. Prices are seeded inactive ───────────────────────
  perform t_assert('mainnet price seeded inactive',
    (select active from skr_prices
      where network = 'mainnet' and item = 'miners_pass'), false);

  raise notice '=== ALL STORE RPC TESTS PASSED ===';
end $$;
