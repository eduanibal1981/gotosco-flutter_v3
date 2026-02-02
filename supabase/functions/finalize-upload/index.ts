// supabase/functions/finalize-upload/index.ts
// Confirm upload completion and update database

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import { objectExists, config } from "../_shared/r2-client.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface FinalizeUploadBody {
  asset_id: string;
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
    const body: FinalizeUploadBody = await req.json();
    const { asset_id } = body;

    if (!asset_id) {
      return new Response(
        JSON.stringify({ error: "Missing asset_id" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Use service role for database operations
    const supabaseService = createClient(supabaseUrl, supabaseServiceKey);

    // Get the asset record
    const { data: asset, error: fetchError } = await supabaseService
      .from("media_assets")
      .select("*")
      .eq("id", asset_id)
      .single();

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

    // Check if asset is still pending
    if (asset.status !== "pending") {
      return new Response(
        JSON.stringify({
          error: `Asset is not pending. Current status: ${asset.status}`,
          asset: {
            id: asset.id,
            status: asset.status,
            url: asset.status === "uploaded" ? `${config.publicUrl}/${asset.r2_key}` : null,
          },
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verify the file exists in R2
    const { exists, size } = await objectExists(asset.r2_key);
    if (!exists) {
      // Mark as failed
      await supabaseService
        .from("media_assets")
        .update({
          status: "failed",
          metadata: { ...asset.metadata, failure_reason: "File not found in R2" },
        })
        .eq("id", asset_id);

      return new Response(
        JSON.stringify({ error: "File not found in storage. Upload may have failed." }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Call the database function to finalize
    const { data: result, error: finalizeError } = await supabaseService.rpc(
      "finalize_media_upload",
      {
        p_asset_id: asset_id,
        p_file_size: size || null,
      }
    );

    if (finalizeError) {
      console.error("Error finalizing upload:", finalizeError);
      return new Response(
        JSON.stringify({ error: "Failed to finalize upload" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!result.success) {
      return new Response(
        JSON.stringify({ error: result.error }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        url: result.url,
        asset_id: result.asset_id,
        r2_key: result.r2_key,
        visibility: result.visibility,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in finalize-upload:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
