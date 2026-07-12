/**
 * ./cors.ts
 * CORS headers and config constants shared across edge functions.
 */

export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
};

/** Return a CORS-preflight response for OPTIONS requests */
export function handleCors(req: Request): Response | null {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  return null;
}

/** JSON response helper — handles BigInt serialization */
export function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data, bigIntReplacer), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

/** JSON.stringify replacer that converts BigInt to Number */
function bigIntReplacer(_key: string, value: unknown): unknown {
  if (typeof value === 'bigint') {
    // Safe for values under Number.MAX_SAFE_INTEGER (9 quadrillion)
    return Number(value);
  }
  return value;
}

/** Error response helper */
export function errorResponse(message: string, status = 500): Response {
  return jsonResponse({ error: message }, status);
}