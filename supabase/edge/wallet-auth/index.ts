/// wallet-auth/index.ts
/// Supabase Edge Function for Sign In With Solana (SIWS).
/// https://vdcpbqsnkivokroqxelq.supabase.co/functions/v1/wallet-auth
/// Routes:
///   POST /nonce   — Generate a sign-in message with nonce
///   POST /verify  — Verify wallet signature → return session creds + player_id
///   POST /link    — Link a wallet identity to an existing player
///
/// Key fix vs previous version:
///   The slow-path recovery no longer calls signInWithPassword via the anon
///   client. It uses admin.auth.admin.getUserByEmail() instead. This avoids
///   Supabase's rate-limiter which fires when the edge fn signs in and then
///   the Dart client immediately signs in with the same credentials.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { ed25519 } from "https://esm.sh/@noble/curves@1.8.1/ed25519";
import bs58 from "https://esm.sh/bs58@5.0.0";

// ── CORS ──────────────────────────────────────────────────────────

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ error: message }, status);
}

// ── Config ────────────────────────────────────────────────────────

const NONCE_TTL_MINUTES = 5;

function getAdminClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
}

// getAnonClient is only needed in /link for caller session validation.
// It is NOT used in /verify — using it there causes rate-limit issues.
function getAnonClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );
}

function generateNonce(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}

async function deriveWalletPassword(walletAddress: string): Promise<string> {
  const secret = Deno.env.get("JWT_SECRET")!;
  const data = new TextEncoder().encode(
    `diggle-wallet-auth:${secret}:${walletAddress}`,
  );
  const hash = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function walletEmail(walletAddress: string): string {
  return `${walletAddress.toLowerCase()}@wallet.diggle.app`;
}

// ── Signature verification ────────────────────────────────────────

async function verifyEd25519(
  walletAddress: string,
  signatureB64: string,
  message: string,
): Promise<boolean> {
  const messageBytes   = new TextEncoder().encode(message);
  const signatureBytes = Uint8Array.from(atob(signatureB64), (c) => c.charCodeAt(0));
  const publicKeyBytes = bs58.decode(walletAddress);
  return ed25519.verify(signatureBytes, messageBytes, publicKeyBytes);
}

// ── Nonce validation ──────────────────────────────────────────────

async function validateAndConsumeNonce(
  admin: ReturnType<typeof getAdminClient>,
  walletAddress: string,
  message: string,
): Promise<Response | null> {
  const { data: nonceRow, error } = await admin
    .from("wallet_nonces")
    .select("nonce, created_at")
    .eq("wallet_address", walletAddress)
    .single();

  if (error || !nonceRow) {
    return errorResponse("No pending sign-in for this wallet. Request a new nonce.");
  }

  const age = Date.now() - new Date(nonceRow.created_at).getTime();
  if (age > NONCE_TTL_MINUTES * 60 * 1000) {
    await admin.from("wallet_nonces").delete().eq("wallet_address", walletAddress);
    return errorResponse("Nonce expired. Request a new one.");
  }

  if (!message.includes(nonceRow.nonce)) {
    return errorResponse("Message does not contain the expected nonce.");
  }

  await admin.from("wallet_nonces").delete().eq("wallet_address", walletAddress);
  return null;
}

// ── Get or create wallet auth user ───────────────────────────────
//
// Uses admin APIs ONLY — never calls signInWithPassword.
// This is critical: if the edge fn signs in and the Dart client immediately
// signs in with the same credentials, Supabase's rate-limiter fires and
// returns "invalid username or password" even though the password is correct.
//
// Flow:
//   1. Try admin createUser (new wallet)
//   2. If "already exists", use admin getUserByEmail (no rate limit)
//
// Returns { userId, isNew } or an error Response.

async function getOrCreateWalletAuthUser(
  admin: ReturnType<typeof getAdminClient>,
  walletAddress: string,
): Promise<{ userId: string; isNew: boolean } | Response> {
  const email    = walletEmail(walletAddress);
  const password = await deriveWalletPassword(walletAddress);

  const { data: newUser, error: createError } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { wallet_address: walletAddress, auth_provider: "solana_wallet" },
  });

  if (!createError && newUser?.user) {
    console.log(`[auth] Created new wallet auth user for ${walletAddress.slice(0, 8)}...`);
    return { userId: newUser.user.id, isNew: true };
  }

  const isAlreadyExists =
    createError?.message?.toLowerCase().includes("already") ||
    (createError as any)?.code === "user_already_exists";

  if (!isAlreadyExists) {
    console.error("[auth] Unexpected createUser error:", createError);
    return errorResponse("Failed to create auth account.", 500);
  }

  // User already exists in auth.users — query it directly via the auth schema.
  // The service role key has full access to auth.users with no rate limits.
  const { data: existingAuthUser, error: fetchError } = await admin
    .schema("auth")
    .from("users")
    .select("id")
    .eq("email", email)
    .single();

  if (fetchError || !existingAuthUser?.id) {
    console.error("[auth] Failed to fetch existing auth user:", fetchError);
    return errorResponse("Failed to locate existing auth account.", 500);
  }

  console.log(`[auth] Found existing wallet auth user for ${walletAddress.slice(0, 8)}...`);
  return { userId: existingAuthUser.id, isNew: false };
}

// ── Main handler ──────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const path = new URL(req.url).pathname.split("/").pop();

  try {
    switch (path) {
      case "nonce":  return await handleNonce(req);
      case "verify": return await handleVerify(req);
      case "link":   return await handleLink(req);
      default:
        return errorResponse("Unknown route. Use /nonce, /verify, or /link.", 404);
    }
  } catch (err) {
    console.error("Wallet auth error:", err);
    return errorResponse("Internal server error.", 500);
  }
});

// ── POST /nonce ───────────────────────────────────────────────────

async function handleNonce(req: Request): Promise<Response> {
  const { wallet_address } = await req.json();
  if (!wallet_address || typeof wallet_address !== "string") {
    return errorResponse("Missing wallet_address.");
  }

  const admin = getAdminClient();

  await admin
    .from("wallet_nonces")
    .delete()
    .lt("created_at", new Date(Date.now() - NONCE_TTL_MINUTES * 60 * 1000).toISOString());

  const nonce = generateNonce();
  const { error } = await admin.from("wallet_nonces").upsert({
    wallet_address,
    nonce,
    created_at: new Date().toISOString(),
  });

  if (error) {
    console.error("Error storing nonce:", error);
    return errorResponse("Failed to generate sign-in challenge.", 500);
  }

  const message =
    `Diggle Sign-In\n\n` +
    `Wallet: ${wallet_address}\n` +
    `Nonce: ${nonce}\n` +
    `Issued: ${new Date().toISOString()}`;

  console.log(`[nonce] Generated for ${wallet_address.slice(0, 8)}...`);
  return jsonResponse({ message, nonce });
}

// ── POST /verify ──────────────────────────────────────────────────
//
// Returns { email, password, player_id }
//   email + password  → client calls signInWithPassword() with these
//   player_id         → canonical player UUID (always use this, not auth uid)
//
// Optional body param: existing_player_id
//   Pass when adding wallet sign-in to an existing account (guest upgrade,
//   email user adding wallet). The wallet auth user is mapped to that player.

async function handleVerify(req: Request): Promise<Response> {
  const body = await req.json();
  const { wallet_address, signature, message } = body;
  const existing_player_id: string | null = body.existing_player_id ?? null;

  if (!wallet_address || !signature || !message) {
    return errorResponse("Missing wallet_address, signature, or message.");
  }

  const admin = getAdminClient();

  const nonceError = await validateAndConsumeNonce(admin, wallet_address, message);
  if (nonceError) return nonceError;

  try {
    if (!await verifyEd25519(wallet_address, signature, message)) {
      return errorResponse("Invalid signature.", 401);
    }
  } catch (err) {
    console.error("Signature verification error:", err);
    return errorResponse("Signature verification failed.", 401);
  }

  const email    = walletEmail(wallet_address);
  const password = await deriveWalletPassword(wallet_address);

  let walletAuthUserId: string;
  let player_id: string | null = null;

  // ── Fast path: check player_auth_accounts by identifier ──────────
  // Handles all returning wallet users without touching auth.users at all.
  // Also self-heals old accounts that previously had NULL identifiers
  // (the SQL fix script populates them, but this catches any stragglers).

  const { data: idMapping } = await admin
    .from("player_auth_accounts")
    .select("auth_user_id, player_id")
    .eq("identifier", wallet_address)
    .maybeSingle();

  if (idMapping) {
    walletAuthUserId = idMapping.auth_user_id;
    player_id        = idMapping.player_id;

    if (existing_player_id && existing_player_id !== player_id) {
      return errorResponse("This wallet is already linked to a different account.", 409);
    }

    console.log(`[verify] Fast path: player ${player_id!.slice(0, 8)} for ${wallet_address.slice(0, 8)}...`);
    await admin.from("players").update({ wallet_address }).eq("id", player_id!);
    return jsonResponse({ email, password, player_id });
  }

  // ── Slow path: create or fetch the wallet auth user ───────────────
  // Only reached for genuinely new wallets or old accounts where identifier
  // was NULL and the SQL fix script hasn't run yet.

  const authResult = await getOrCreateWalletAuthUser(admin, wallet_address);
  if (authResult instanceof Response) return authResult;
  ({ userId: walletAuthUserId } = authResult);

  // Check for existing mapping via auth_user_id (catches old NULL-identifier accounts)
  const { data: authUserMapping } = await admin
    .from("player_auth_accounts")
    .select("player_id")
    .eq("auth_user_id", walletAuthUserId)
    .maybeSingle();

  if (authUserMapping) {
    player_id = authUserMapping.player_id;

    if (existing_player_id && existing_player_id !== player_id) {
      return errorResponse("This wallet is already linked to a different account.", 409);
    }

    // Patch the identifier so future lookups hit the fast path
    await admin
      .from("player_auth_accounts")
      .update({ identifier: wallet_address })
      .eq("auth_user_id", walletAuthUserId);

    console.log(`[verify] Slow path: player ${player_id!.slice(0, 8)}, patched identifier`);
    await admin.from("players").update({ wallet_address }).eq("id", player_id!);
    return jsonResponse({ email, password, player_id });
  }

  // ── No existing player — create or link ──────────────────────────

  if (existing_player_id) {
    const { error: linkError } = await admin
      .from("player_auth_accounts")
      .insert({
        auth_user_id: walletAuthUserId,
        player_id:    existing_player_id,
        auth_method:  "wallet",
        identifier:   wallet_address,
      });

    if (linkError) {
      console.error("Error linking wallet auth to player:", linkError);
      return errorResponse("Failed to link wallet to player.", 500);
    }

    player_id = existing_player_id;
    console.log(`[verify] Linked wallet → existing player ${player_id.slice(0, 8)}`);

  } else {
    const { data: newPlayerId, error: rpcError } = await admin.rpc("create_player_with_stats", {
      p_auth_user_id: walletAuthUserId,
      p_auth_method:  "wallet",
    });

    if (rpcError || !newPlayerId) {
      console.error("Error creating player:", rpcError);
      return errorResponse("Failed to create player account.", 500);
    }

    player_id = newPlayerId as string;

    // RPC inserts the player_auth_accounts row but doesn't know the wallet
    // address — patch identifier now so the fast path works next time
    await admin
      .from("player_auth_accounts")
      .update({ identifier: wallet_address })
      .eq("auth_user_id", walletAuthUserId);

    console.log(`[verify] Created new player ${player_id.slice(0, 8)}`);
  }

  await admin.from("players").update({ wallet_address }).eq("id", player_id!);
  return jsonResponse({ email, password, player_id });
}

// ── POST /link ────────────────────────────────────────────────────
//
// Links a wallet identity to an authenticated player.
// Requires: Authorization header (caller's session token)
//           player_id in request body
//
// 409 if the wallet is already linked to a different player.

async function handleLink(req: Request): Promise<Response> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return errorResponse("Missing authorization token.", 401);
  }

  const body = await req.json();
  const { wallet_address, signature, message, player_id } = body;

  if (!wallet_address || !signature || !message || !player_id) {
    return errorResponse("Missing wallet_address, signature, message, or player_id.");
  }

  const admin = getAdminClient();

  const nonceError = await validateAndConsumeNonce(admin, wallet_address, message);
  if (nonceError) return nonceError;

  try {
    if (!await verifyEd25519(wallet_address, signature, message)) {
      return errorResponse("Invalid signature.", 401);
    }
  } catch {
    return errorResponse("Signature verification failed.", 401);
  }

  // Verify the caller's session token maps to the claimed player_id
  const token = authHeader.replace("Bearer ", "");
  const { data: { user }, error: userError } = await admin.auth.getUser(token);
  if (userError || !user) return errorResponse("Invalid session token.", 401);

  const { data: callerMapping } = await admin
    .from("player_auth_accounts")
    .select("player_id")
    .eq("auth_user_id", user.id)
    .maybeSingle();

  if (!callerMapping || callerMapping.player_id !== player_id) {
    return errorResponse("Session token does not match the provided player_id.", 403);
  }

  // ── Fast path: check if wallet already mapped ─────────────────────

  const { data: idMapping } = await admin
    .from("player_auth_accounts")
    .select("auth_user_id, player_id")
    .eq("identifier", wallet_address)
    .maybeSingle();

  if (idMapping) {
    if (idMapping.player_id !== player_id) {
      return errorResponse("This wallet is already linked to a different account.", 409);
    }
    // Already correctly linked — idempotent success
    console.log(`[link] Already linked: wallet → player ${player_id.slice(0, 8)}`);
    await admin.from("players").update({ wallet_address }).eq("id", player_id);
    return jsonResponse({ success: true, wallet_address, player_id });
  }

  // ── Get or create the wallet auth user ────────────────────────────

  const authResult = await getOrCreateWalletAuthUser(admin, wallet_address);
  if (authResult instanceof Response) return authResult;
  const { userId: walletAuthUserId } = authResult;

  // Check via auth_user_id in case identifier was NULL on an old account
  const { data: authUserMapping } = await admin
    .from("player_auth_accounts")
    .select("player_id")
    .eq("auth_user_id", walletAuthUserId)
    .maybeSingle();

  if (authUserMapping) {
    if (authUserMapping.player_id !== player_id) {
      return errorResponse("This wallet is already linked to a different account.", 409);
    }
    // Patch the missing identifier and return
    await admin
      .from("player_auth_accounts")
      .update({ identifier: wallet_address })
      .eq("auth_user_id", walletAuthUserId);

    await admin.from("players").update({ wallet_address }).eq("id", player_id);
    return jsonResponse({ success: true, wallet_address, player_id });
  }

  // Insert the new mapping
  const { error: insertError } = await admin
    .from("player_auth_accounts")
    .insert({
      auth_user_id: walletAuthUserId,
      player_id,
      auth_method: "wallet",
      identifier:  wallet_address,
    });

  if (insertError) {
    console.error("Error inserting player_auth_accounts:", insertError);
    return errorResponse("Failed to link wallet to player.", 500);
  }

  await admin.from("players").update({ wallet_address }).eq("id", player_id);

  console.log(`[link] ${wallet_address.slice(0, 8)}... → player ${player_id.slice(0, 8)}`);
  return jsonResponse({ success: true, wallet_address, player_id });
}