-- ============================================================
-- Miner's Pass paid in SKR (Seeker token)
--
-- The weekly Miner's Pass used to cost 300 points. It now costs SKR,
-- paid as a plain SPL transferChecked into the treasury wallet — no
-- on-chain program. The miners-pass edge function builds the transfer,
-- verifies it on-chain, and records the pass here with the service
-- role. Clients never touch these tables directly.
--
-- Rows are keyed by network so devnet rehearsals (dummy SKR mint) can
-- never grant a mainnet pass.
--
-- Everything here is additive: old app builds keep buying the pass
-- with points and never call the edge function.
-- ============================================================

-- ── Prices (tunable without a release) ──────────────────────

create table if not exists skr_prices (
  network text not null check (network in ('mainnet', 'devnet')),
  item text not null,
  amount_base bigint not null check (amount_base > 0), -- SKR base units (6 decimals)
  active boolean not null default false,
  updated_at timestamptz default now(),
  primary key (network, item)
);

-- Placeholder: 100 SKR. Inactive until a real price is set, so the
-- pass stays hidden in the app until then.
insert into skr_prices (network, item, amount_base, active) values
  ('mainnet', 'miners_pass', 100000000, false),
  ('devnet',  'miners_pass', 100000000, false)
on conflict (network, item) do nothing;

alter table skr_prices enable row level security;
-- No client policies: the edge function reads prices with the service role.

-- ── Orders (audit trail of every payment attempt) ───────────

create table if not exists miners_pass_orders (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references players(id) on delete cascade,
  network text not null check (network in ('mainnet', 'devnet')),
  buyer text not null,                     -- wallet that signs the transfer
  amount_base bigint not null,             -- price at build time
  status text not null default 'pending'
    check (status in ('pending', 'paid', 'failed')),
  tx_signature text unique,                -- a transfer can pay one order only
  week_key text,                           -- ISO week granted (set when paid)
  created_at timestamptz default now(),
  paid_at timestamptz
);

create index if not exists idx_miners_pass_orders_player
  on miners_pass_orders(player_id, created_at desc);

alter table miners_pass_orders enable row level security;

-- ── Passes (one per player, network and ISO week) ───────────

create table if not exists miners_passes (
  player_id uuid not null references players(id) on delete cascade,
  network text not null check (network in ('mainnet', 'devnet')),
  week_key text not null,
  order_id uuid references miners_pass_orders(id),
  created_at timestamptz default now(),
  primary key (player_id, network, week_key)
);

alter table miners_passes enable row level security;

-- ── ISO week key ────────────────────────────────────────────
-- Must produce exactly what QuestSystem.isoWeekKey does in the client
-- ('2026-W40': ISO year, ISO week, UTC), or a paid pass would land on
-- a week the client never looks up.

create or replace function public.iso_week_key(p_ts timestamptz)
returns text
language sql
stable
as $$
  select to_char(p_ts at time zone 'utc', 'IYYY-"W"IW');
$$;

-- ── fulfill_miners_pass_order ───────────────────────────────
-- Called by the edge function AFTER it has verified the transfer
-- on-chain. Grants the pass for the week the payment was verified in.
-- Idempotent: re-fulfilling a paid order with the same signature
-- returns the same week, so a client retrying /confirm is harmless.

create or replace function public.fulfill_miners_pass_order(
  p_order_id uuid,
  p_signature text
)
returns text
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_order miners_pass_orders%rowtype;
  v_week text;
begin
  if auth.role() is distinct from 'service_role' then
    raise exception 'service role only';
  end if;

  select * into v_order
    from miners_pass_orders
   where id = p_order_id
     for update;

  if not found then
    raise exception 'order % not found', p_order_id;
  end if;

  if v_order.status = 'paid' then
    if v_order.tx_signature = p_signature then
      return v_order.week_key;
    end if;
    raise exception 'order % already paid by another transaction', p_order_id;
  end if;

  if v_order.status <> 'pending' then
    raise exception 'order % is %', p_order_id, v_order.status;
  end if;

  v_week := iso_week_key(now());

  -- tx_signature is unique: reusing a transfer for a second order
  -- fails here and rolls the whole call back.
  update miners_pass_orders
     set status = 'paid',
         tx_signature = p_signature,
         week_key = v_week,
         paid_at = now()
   where id = p_order_id;

  insert into miners_passes (player_id, network, week_key, order_id)
  values (v_order.player_id, v_order.network, v_week, p_order_id)
  on conflict (player_id, network, week_key) do nothing;

  return v_week;
end;
$function$;

revoke execute on function public.fulfill_miners_pass_order(uuid, text)
  from anon, authenticated, public;
grant execute on function public.fulfill_miners_pass_order(uuid, text)
  to service_role;
