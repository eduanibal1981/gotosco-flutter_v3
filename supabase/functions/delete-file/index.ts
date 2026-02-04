// supabase/functions/delete-file/index.ts
// Delete file from R2

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { deleteObject } from "../_shared/r2-client.ts";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const { key } = await req.json();

        if (!key) {
            throw new Error("Missing 'key' in request body");
        }

        console.log(`Deleting file: ${key}`);

        // Delete from R2
        await deleteObject(key);

        return new Response(
            JSON.stringify({ success: true, message: "File deleted successfully" }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 200,
            }
        );
    } catch (error) {
        console.error("Delete error:", error);
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 400,
            }
        );
    }
});
