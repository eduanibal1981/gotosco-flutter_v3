// supabase/functions/get-signed-url/index.ts
// Generate time-limited signed GET URL for private files

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { getPresignedGetUrl, config } from "../_shared/r2-client.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface GetSignedUrlBody {
  asset_id?: string;
  r2_key?: string;
  expires_in?: number; // seconds, default 3600 (1 hour)
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Get Supabase URL and keys from environment
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

    // Get authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Extract the JWT token
    const token = authHeader.replace("Bearer ", "");

    // Create client with anon key for auth verification
    const supabaseAuth = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: `Bearer ${token}` } },
      auth: { persistSession: false },
    });

    // Verify the token and get the user
    const { data: { user }, error: authError } = await supabaseAuth.auth.getUser(token);

    if (authError) {
      console.error("Auth error:", authError);
      return new Response(
        JSON.stringify({ error: `Authentication failed: ${authError.message}` }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!user) {
      return new Response(
        JSON.stringify({ error: "User not found" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parse request body
    const body: GetSignedUrlBody = await req.json();
    const { asset_id, r2_key, expires_in } = body;

    if (!asset_id && !r2_key) {
      return new Response(
        JSON.stringify({ error: "Missing asset_id or r2_key" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate expires_in
    const maxExpiresIn = 7 * 24 * 60 * 60; // 7 days max
    const finalExpiresIn = Math.min(expires_in || 3600, maxExpiresIn);

    // Use service role for database operations
    const supabaseService = createClient(supabaseUrl, supabaseServiceKey);

    // Get the asset record
    let query = supabaseService.from("media_assets").select("*");
    if (asset_id) {
      query = query.eq("id", asset_id);
    } else {
      query = query.eq("r2_key", r2_key);
    }

    const { data: asset, error: fetchError } = await query.single();

    if (fetchError || !asset) {
      return new Response(
        JSON.stringify({ error: "Asset not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verify ownership
    if (asset.owner_id !== user.id) {
      return new Response(
        JSON.stringify({ error: "Unauthorized - you don't own this asset" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Check if asset is uploaded
    if (asset.status !== "uploaded") {
      return new Response(
        JSON.stringify({ error: `Asset is not available. Status: ${asset.status}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // For public assets, return direct URL
    if (asset.visibility === "public") {
      return new Response(
        JSON.stringify({
          url: `${config.publicUrl}/${asset.r2_key}`,
          expires_in: null, // Never expires
          is_public: true,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // For private assets, generate signed URL
    const signedUrl = await getPresignedGetUrl(asset.r2_key, finalExpiresIn);

    return new Response(
      JSON.stringify({
        url: signedUrl,
        expires_in: finalExpiresIn,
        is_public: false,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in get-signed-url:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
