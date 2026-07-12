// supabase/functions/validate-social-quest/index.ts
// https://vdcpbqsnkivokroqxelq.supabase.co/functions/v1/validate-social-quest
// Validates social quest completion:
//   - social_post_tweet: Verifies tweet exists via X oEmbed API
//     and contains required mention (@DiggleOnSol)
//   - social_follow_twitter: Trust-based (no free API for this)
//   - social_join_discord: Can validate via Discord bot API if configured
//
// POST body: { player_id, quest_id, tweet_url? }
// Returns:  { valid: boolean, reason?: string }

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Required text fragments the tweet must contain (at least one).
const REQUIRED_MENTIONS = ["@DiggleOnSol", "#DiggleOnSol"];

// Discord bot token + guild ID — set these as Edge Function secrets
// if you want Discord membership validation.
const DISCORD_BOT_TOKEN = Deno.env.get("DISCORD_BOT_TOKEN") ?? "";
const DISCORD_GUILD_ID = Deno.env.get("DISCORD_GUILD_ID") ?? "";

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  try {
    const { player_id, quest_id, tweet_url, discord_user_id } =
      await req.json();

    if (!player_id || !quest_id) {
      return jsonResponse(
        { valid: false, reason: "Missing player_id or quest_id" },
        400
      );
    }

    // ── Route by quest type ──────────────────────────────────
    let result: { valid: boolean; reason?: string };

    switch (quest_id) {
      case "social_post_tweet":
        result = await validateTweet(tweet_url);
        break;

      case "social_join_discord":
        result = await validateDiscordMembership(discord_user_id);
        break;

      case "social_follow_twitter":
        // No free API to verify follows — trust-based
        result = { valid: true, reason: "Trust-based verification" };
        break;

      default:
        result = { valid: false, reason: `Unknown quest: ${quest_id}` };
    }

    // ── If valid, mark quest completed in DB ─────────────────
    if (result.valid) {
      await markQuestCompleted(req, player_id, quest_id);
    }

    return jsonResponse(result, 200);
  } catch (err) {
    console.error("validate-social-quest error:", err);
    return jsonResponse(
      { valid: false, reason: "Internal server error" },
      500
    );
  }
});

// ================================================================
// TWEET VALIDATION (oEmbed — free, no auth required)
// ================================================================

async function validateTweet(
  tweetUrl?: string
): Promise<{ valid: boolean; reason?: string }> {
  if (!tweetUrl) {
    return { valid: false, reason: "No tweet URL provided" };
  }

  // Normalize URL
  const normalized = tweetUrl.trim();

  // Basic URL format check
  const tweetPattern =
    /^https?:\/\/(x\.com|twitter\.com)\/\w+\/status\/\d+/i;
  if (!tweetPattern.test(normalized)) {
    return {
      valid: false,
      reason: "Invalid tweet URL format. Please paste the full URL to your tweet.",
    };
  }

  try {
    // Use X/Twitter oEmbed API (free, no auth)
    const oembedUrl = `https://publish.twitter.com/oembed?url=${encodeURIComponent(normalized)}&omit_script=true`;

    const response = await fetch(oembedUrl, {
      headers: { "User-Agent": "DiggleOnSol/1.0" },
    });

    if (!response.ok) {
      if (response.status === 404) {
        return {
          valid: false,
          reason: "Tweet not found. Make sure you posted it publicly.",
        };
      }
      return {
        valid: false,
        reason: `Could not verify tweet (status ${response.status})`,
      };
    }

    const data = await response.json();
    const html: string = (data.html ?? "").toLowerCase();

    // Check that the tweet mentions @DiggleOnSol or #DiggleOnSol
    const hasMention = REQUIRED_MENTIONS.some((mention) =>
      html.includes(mention.toLowerCase())
    );

    if (!hasMention) {
      return {
        valid: false,
        reason:
          "Tweet doesn't mention @DiggleOnSol. Please use the share button to post with the pre-filled text.",
      };
    }

    // Check tweet is recent (within 7 days) by looking at the URL's tweet ID.
    // Twitter snowflake IDs encode timestamps — epoch is 1288834974657.
    const tweetIdMatch = normalized.match(/\/status\/(\d+)/);
    if (tweetIdMatch) {
      const tweetId = BigInt(tweetIdMatch[1]);
      const tweetTimestamp =
        Number(tweetId >> BigInt(22)) + 1288834974657;
      const tweetDate = new Date(tweetTimestamp);
      const now = new Date();
      const daysSinceTweet =
        (now.getTime() - tweetDate.getTime()) / (1000 * 60 * 60 * 24);

      if (daysSinceTweet > 7) {
        return {
          valid: false,
          reason:
            "Tweet is older than 7 days. Please post a new tweet to complete this quest.",
        };
      }
    }

    return { valid: true };
  } catch (err) {
    console.error("oEmbed fetch error:", err);
    return {
      valid: false,
      reason: "Could not reach Twitter/X to verify. Try again later.",
    };
  }
}

// ================================================================
// DISCORD MEMBERSHIP VALIDATION (requires bot token + guild ID)
// ================================================================

async function validateDiscordMembership(
  discordUserId?: string
): Promise<{ valid: boolean; reason?: string }> {
  // If no bot configured, fall back to trust-based
  if (!DISCORD_BOT_TOKEN || !DISCORD_GUILD_ID) {
    return { valid: true, reason: "Trust-based verification (no bot configured)" };
  }

  if (!discordUserId) {
    return {
      valid: false,
      reason: "Discord user ID required for verification",
    };
  }

  try {
    const response = await fetch(
      `https://discord.com/api/v10/guilds/${DISCORD_GUILD_ID}/members/${discordUserId}`,
      {
        headers: {
          Authorization: `Bot ${DISCORD_BOT_TOKEN}`,
        },
      }
    );

    if (response.ok) {
      return { valid: true };
    }

    if (response.status === 404) {
      return {
        valid: false,
        reason: "You don't appear to be a member of the Diggle Discord server.",
      };
    }

    return {
      valid: false,
      reason: `Discord verification failed (status ${response.status})`,
    };
  } catch (err) {
    console.error("Discord API error:", err);
    return {
      valid: false,
      reason: "Could not reach Discord API. Try again later.",
    };
  }
}

// ================================================================
// MARK QUEST COMPLETED IN DB
// ================================================================

async function markQuestCompleted(
  req: Request,
  playerId: string,
  questId: string
) {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceKey);

    // Check if row exists (partial unique indexes don't work with upsert)
    const { data: existing } = await supabase
      .from("player_quests")
      .select("id")
      .eq("player_id", playerId)
      .eq("quest_id", questId)
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
        quest_id: questId,
        category: "social",
        progress: 1,
        target: 1,
        completed: true,
        completed_at: new Date().toISOString(),
      });
    }
  } catch (err) {
    // Non-fatal — client will still mark locally
    console.error("Failed to mark quest in DB:", err);
  }
}

// ================================================================
// HELPERS
// ================================================================

function jsonResponse(body: Record<string, unknown>, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}