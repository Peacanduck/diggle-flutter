# SQL tests

Behavioural tests for the security-definer RPCs, run against stock
Postgres in Docker. No Supabase project or network needed — the fixture
stubs the handful of Supabase-provided pieces (`auth.role()`,
`auth.uid()`, the `anon`/`authenticated`/`service_role` roles, and the
subset of tables the function touches).

## Run

```bash
docker run -d --name diggle-pgtest -e POSTGRES_PASSWORD=test postgres:16-alpine
```

Then, from the repo root:

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/tests/streak_fixture.sql
```

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/migrations/20260806_server_streak.sql
```

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/tests/streak_tests.sql
```

The last command prints one `ok …` line per assertion and ends with
`=== ALL STREAK RPC TESTS PASSED ===`. Any mismatch raises and stops the
run (`ON_ERROR_STOP=1`), so a clean exit means everything passed.

Tear down with:

```bash
docker rm -f diggle-pgtest
```

## What `streak_tests.sql` covers

Reward ladder progression, same-day idempotency, the one-shot adoption
of a pre-server device-local streak, replay/inflation attempts being
capped at the days that actually elapsed, broken-streak resets, bounded
offline catch-up, day-7+ jackpot repetition, and the authorization
rules (foreign caller, unauthenticated caller, service-role bypass).

The fixture is deliberately minimal — it is NOT a copy of the
production schema. When a function under test starts touching new
columns, add just those columns here.

## Store tests (`store_tests.sql`)

`award_points` v4 (retired Diggle Mart sources) and the SKR Miner's
Pass RPCs. Use a fresh container (the fixture creates the same base
tables as the streak one), then from the repo root:

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/tests/store_fixture.sql
```

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/migrations/20260711_anti_farming_layer2.sql
```

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/migrations/20260929_retire_store_sources.sql
```

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/migrations/20260929_skr_miners_pass.sql
```

```bash
docker exec -i diggle-pgtest psql -U postgres -v ON_ERROR_STOP=1 -q < supabase/tests/store_tests.sql
```

It ends with `=== ALL STORE RPC TESTS PASSED ===`. Covered: client
`pack_purchase` / `booster_purchase` refused while the service role and
ordinary sources still work; `iso_week_key` agreeing with the client's
`QuestSystem.isoWeekKey` across year boundaries; and
`fulfill_miners_pass_order` being service-role only, idempotent on
retry, refusing to reuse a signature or re-point a paid order, and
keeping devnet passes apart from mainnet.
