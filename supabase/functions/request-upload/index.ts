// supabase/functions/request-upload/index.ts
// Generate pre-signed PUT URL for uploading media to R2

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.3";
import {
  getPresignedPutUrl,
  generateR2Key,
  getAssetPathInfo,
} from "../_shared/r2-client.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestUploadBody {
  asset_type: "avatar" | "license" | "mulkia" | "child_photo" | "adv_photo" | "vehicle_photo";
  content_type?: string;
  file_size?: number;
  original_filename?: string;
  metadata?: Record<string, unknown>;
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
    const body: RequestUploadBody = await req.json();
    const { asset_type, content_type, file_size, original_filename, metadata } = body;

    // Validate asset_type
    const validTypes = ["avatar", "license", "mulkia", "child_photo", "adv_photo", "vehicle_photo"];
    if (!asset_type || !validTypes.includes(asset_type)) {
      return new Response(
        JSON.stringify({ error: `Invalid asset_type. Must be one of: ${validTypes.join(", ")}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate file size limits
    const maxSizes: Record<string, number> = {
      avatar: 5 * 1024 * 1024,      // 5MB
      license: 10 * 1024 * 1024,    // 10MB
      mulkia: 10 * 1024 * 1024,     // 10MB
      child_photo: 5 * 1024 * 1024, // 5MB
      adv_photo: 10 * 1024 * 1024,  // 10MB
      vehicle_photo: 10 * 1024 * 1024, // 10MB
    };

    if (file_size && file_size > maxSizes[asset_type]) {
      return new Response(
        JSON.stringify({
          error: `File too large. Maximum size for ${asset_type}: ${maxSizes[asset_type] / 1024 / 1024}MB`
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Validate content type
    const allowedContentTypes = ["image/jpeg", "image/png", "image/webp", "image/heic"];
    const finalContentType = content_type || "image/jpeg";
    if (!allowedContentTypes.includes(finalContentType)) {
      return new Response(
        JSON.stringify({ error: `Invalid content type. Allowed: ${allowedContentTypes.join(", ")}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Generate R2 key and get path info
    const pathInfo = getAssetPathInfo(asset_type);
    const extension = finalContentType.split("/")[1] === "jpeg" ? "jpg" : finalContentType.split("/")[1];
    const r2Key = generateR2Key(asset_type, user.id, extension);

    // Create pending media_asset record using service role
    const supabaseService = createClient(supabaseUrl, supabaseServiceKey);

    const { data: asset, error: insertError } = await supabaseService
      .from("media_assets")
      .insert({
        owner_id: user.id,
        r2_key: r2Key,
        visibility: pathInfo.visibility,
        asset_type: asset_type,
        mime_type: finalContentType,
        file_size: file_size || null,
        original_filename: original_filename || null,
        legacy_column: pathInfo.legacyColumn,
        status: "pending",
        expires_at: new Date(Date.now() + 15 * 60 * 1000).toISOString(), // 15 minutes
        metadata: metadata || {},
      })
      .select()
      .single();

    if (insertError) {
      console.error("Error creating media_asset:", insertError);
      return new Response(
        JSON.stringify({ error: "Failed to create upload request" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Generate pre-signed PUT URL
    const { uploadUrl, expiresIn } = await getPresignedPutUrl({
      key: r2Key,
      contentType: finalContentType,
      contentLength: file_size,
      expiresIn: 300, // 5 minutes
    });

    return new Response(
      JSON.stringify({
        asset_id: asset.id,
        upload_url: uploadUrl,
        r2_key: r2Key,
        visibility: pathInfo.visibility,
        expires_in: expiresIn,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in request-upload:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
