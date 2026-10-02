-- ============================================================
-- Retire the Diggle Mart ledger sources (award_points v4)
--
-- The Diggle Mart program is closed (2026-09-29): points packs and
-- on-chain boosters can no longer be bought. Until now award_points
-- accepted source 'pack_purchase' from any client, skipped every rate
-- check for it, and never verified the tx signature — so a modified
-- client could self-award up to the hard cap per call, straight into
-- total_points_earned.
--
-- v4 = v3 (20260711_anti_farming_layer2.sql) unchanged, plus one check:
-- non-service-role callers can no longer use 'pack_purchase' or
-- 'booster_purchase'. The service role still can (admin corrections).
-- Historical rows are untouched, and the rolling-window exclusions of
-- 'pack_purchase' stay so real paid packs never trip rate flags.
--
-- Apply AFTER the on-chain store is set inactive, so no in-flight
-- legitimate pack award from an old client is rejected.
-- ============================================================

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

  -- ── Retired sources (Diggle Mart closed 2026-09-29) ───────
  if auth.role() is distinct from 'service_role'
     and p_source in ('pack_purchase', 'booster_purchase') then
    raise exception 'source % is retired', p_source;
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
