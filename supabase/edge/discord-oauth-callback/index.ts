// supabase/functions/discord-oauth-callback/index.ts
// https://vdcpbqsnkivokroqxelq.supabase.co/functions/v1/discord-oauth-callback
// Discord OAuth2 callback handler for the "Join Discord" quest.
//
// Flow:
//   1. Client opens Discord OAuth URL with player_id in `state` param
//   2. User authorizes → Discord redirects here with ?code=X&state=player_id
//   3. This function exchanges the code for an access token
//   4. Gets the user's Discord ID via /users/@me
//   5. Checks guild membership via bot API
//   6. Marks the quest complete in player_quests if member
//   7. Returns an HTML page telling the user to return to the app
//
// Required secrets:
//   DISCORD_CLIENT_ID, DISCORD_CLIENT_SECRET,
//   DISCORD_BOT_TOKEN, DISCORD_GUILD_ID

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DISCORD_CLIENT_ID = Deno.env.get("CLIENT_ID") ?? "";
const DISCORD_CLIENT_SECRET = Deno.env.get("CLIENT_SECRET") ?? "";
const DISCORD_BOT_TOKEN = Deno.env.get("DISCORD_BOT_TOKEN") ?? "";
const DISCORD_GUILD_ID = Deno.env.get("DISCORD_GUILD_ID") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

// The redirect URI must match exactly what's registered in Discord Developer Portal
const REDIRECT_URI = `${SUPABASE_URL}/functions/v1/discord-oauth-callback`;

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);

  // ── Handle the OAuth callback (GET from Discord redirect) ────
  if (req.method === "GET") {
    const code = url.searchParams.get("code");
    const state = url.searchParams.get("state"); // player_id
    const error = url.searchParams.get("error");

    // User denied access
    if (error) {
      return resultRedirect(
        "Authorization Denied",
        "You declined the Discord authorization. You can close this window and try again from the app.",
        false,
      );
    }

    if (!code || !state) {
      return resultRedirect(
        "Invalid Request",
        "Missing authorization code or state parameter.",
        false,
      );
    }

    const playerId = state;

    // Validate player exists
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const { data: player } = await supabase
      .from("players")
      .select("id")
      .eq("id", playerId)
      .maybeSingle();

    if (!player) {
      return resultRedirect(
        "Invalid Player",
        "Could not verify your player account. Please try again from the app.",
        false,
      );
    }

    // ── Step 1: Exchange code for access token ─────────────────
    let accessToken: string;
    try {
      const tokenRes = await fetch("https://discord.com/api/v10/oauth2/token", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({
          client_id: DISCORD_CLIENT_ID,
          client_secret: DISCORD_CLIENT_SECRET,
          grant_type: "authorization_code",
          code,
          redirect_uri: REDIRECT_URI,
        }),
      });

      if (!tokenRes.ok) {
        const errBody = await tokenRes.text();
        console.error("Token exchange failed:", errBody);
        return resultRedirect(
          "Authorization Failed",
          "Could not complete Discord authorization. Please try again.",
          false,
        );
      }

      const tokenData = await tokenRes.json();
      accessToken = tokenData.access_token;
    } catch (err) {
      console.error("Token exchange error:", err);
      return resultRedirect(
        "Connection Error",
        "Could not reach Discord. Please try again later.",
        false,
      );
    }

    // ── Step 2: Get Discord user ID ────────────────────────────
    let discordUserId: string;
    let discordUsername: string;
    try {
      const userRes = await fetch("https://discord.com/api/v10/users/@me", {
        headers: { Authorization: `Bearer ${accessToken}` },
      });

      if (!userRes.ok) {
        return resultRedirect(
          "Discord Error",
          "Could not retrieve your Discord profile.",
          false,
        );
      }

      const userData = await userRes.json();
      discordUserId = userData.id;
      discordUsername = userData.username;
    } catch (err) {
      console.error("User fetch error:", err);
      return resultRedirect(
        "Connection Error",
        "Could not reach Discord. Please try again.",
        false,
      );
    }

    // ── Step 3: Check guild membership via bot API ─────────────
    let isMember = false;
    try {
      const memberRes = await fetch(
        `https://discord.com/api/v10/guilds/${DISCORD_GUILD_ID}/members/${discordUserId}`,
        { headers: { Authorization: `Bot ${DISCORD_BOT_TOKEN}` } },
      );

      if (memberRes.ok) {
        isMember = true;
      } else if (memberRes.status === 404) {
        isMember = false;
      } else {
        console.error("Guild check status:", memberRes.status);
        // Treat as not a member but don't error out
        isMember = false;
      }
    } catch (err) {
      console.error("Guild membership check error:", err);
      return resultRedirect(
        "Verification Error",
        "Could not check server membership. Please try again.",
        false,
      );
    }

    if (!isMember) {
      return resultRedirect(
        "Not a Member",
        "It looks like you haven't joined the Diggle Discord server yet. Please join at discord.gg/diggle first, then try verifying again.",
        false,
        discordUsername,
      );
    }

    // ── Step 4: Mark quest complete in DB ──────────────────────
    try {
      // Check if row exists (partial unique indexes don't work with upsert)
      const { data: existing } = await supabase
        .from("player_quests")
        .select("id")
        .eq("player_id", playerId)
        .eq("quest_id", "social_join_discord")
        .eq("category", "social")
        .maybeSingle();

      if (existing) {
        await supabase
          .from("player_quests")
          .update({
            progress: 1,
            completed: true,
            completed_at: new Date().toISOString(),
          })
          .eq("id", existing.id);
      } else {
        await supabase.from("player_quests").insert({
          player_id: playerId,
          quest_id: "social_join_discord",
          category: "social",
          progress: 1,
          target: 1,
          completed: true,
          reward_claimed: false,
          xp_reward: 100,
          points_reward: 50,
          completed_at: new Date().toISOString(),
        });
      }
    } catch (err) {
      console.error("DB update error:", err);
      // Non-fatal — the client will detect it wasn't marked and can retry
    }

    return resultRedirect(
      "Discord Verified!",
      "You're a confirmed member of the Diggle Discord server. Return to the app to claim your reward.",
      true,
      discordUsername,
    );
  }

  // ── Generate the OAuth URL (POST from client) ────────────────
  // Client calls this to get the authorization URL with proper params.
  if (req.method === "POST") {
    try {
      const { player_id } = await req.json();

      if (!player_id) {
        return new Response(
          JSON.stringify({ error: "Missing player_id" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      if (!DISCORD_CLIENT_ID) {
        return new Response(
          JSON.stringify({ error: "Discord OAuth not configured" }),
          { status: 503, headers: { ...corsHeaders, "Content-Type": "application/json" } },
        );
      }

      const params = new URLSearchParams({
        client_id: DISCORD_CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "identify",
        state: player_id,
        prompt: "consent",
      });

      const authUrl = `https://discord.com/oauth2/authorize?${params.toString()}`;

      return new Response(
        JSON.stringify({ auth_url: authUrl }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    } catch (err) {
      console.error("POST error:", err);
      return new Response(
        JSON.stringify({ error: "Internal error" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }
  }

  return new Response("Method not allowed", { status: 405 });
});

// ================================================================
// Redirect to static result page hosted in Supabase Storage.
// Supabase Edge Functions can't reliably serve HTML (Content-Type
// gets stripped by the proxy), so we redirect to a static file.
// ================================================================

function resultRedirect(title: string, message: string, success: boolean, username?: string) {
  const resultPageBase = `${SUPABASE_URL}/storage/v1/object/public/static/discord-result.html`;

  const params = new URLSearchParams({
    success: success ? "true" : "false",
    title,
    message,
  });
  if (username) params.set("username", username);

  const redirectUrl = `${resultPageBase}?${params.toString()}`;

  return new Response(null, {
    status: 302,
    headers: {
      ...corsHeaders,
      "Location": redirectUrl,
    },
  });
}

