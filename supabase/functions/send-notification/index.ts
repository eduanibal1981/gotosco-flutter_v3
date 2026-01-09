// supabase/functions/send-notification/index.ts
// This Edge Function sends FCM push notifications to users
// Triggered by database changes or direct invocation



// Firebase Admin SDK for sending FCM messages
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") ?? "gotoscoai-ec5bd";

interface NotificationPayload {
  fcm_token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface FCMMessage {
  message: {
    token: string;
    notification: {
      title: string;
      body: string;
    };
    data?: Record<string, string>;
    android?: {
      priority: string;
      notification: {
        sound: string;
        channel_id: string;
      };
    };
    apns?: {
      payload: {
        aps: {
          sound: string;
        };
      };
    };
  };
}

// Get OAuth2 access token for FCM using service account
async function getAccessToken(): Promise<string> {
  const serviceAccountKey = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_KEY");
  if (!serviceAccountKey) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT_KEY not set");
  }

  const serviceAccount = JSON.parse(serviceAccountKey);

  // Create JWT for Google OAuth2
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };

  // Encode JWT parts
  const encoder = new TextEncoder();
  const headerB64 = btoa(JSON.stringify(header)).replace(/=/g, "");
  const payloadB64 = btoa(JSON.stringify(payload)).replace(/=/g, "");
  const unsignedToken = `${headerB64}.${payloadB64}`;

  // Sign with private key
  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToBinary(serviceAccount.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    encoder.encode(unsignedToken)
  );

  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");

  const jwt = `${unsignedToken}.${signatureB64}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

// Convert PEM to binary for crypto.subtle
function pemToBinary(pem: string): ArrayBuffer {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

// Send FCM notification
async function sendFCMNotification(payload: NotificationPayload): Promise<Response> {
  const accessToken = await getAccessToken();

  const fcmMessage: FCMMessage = {
    message: {
      token: payload.fcm_token,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channel_id: "gotosco_high_importance",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    },
  };

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(fcmMessage),
    }
  );

  return response;
}

Deno.serve(async (req) => {
  try {
    // Handle CORS preflight
    if (req.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
      });
    }

    const payload: NotificationPayload = await req.json();

    // Validate required fields
    if (!payload.fcm_token || !payload.title || !payload.body) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: fcm_token, title, body" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    const fcmResponse = await sendFCMNotification(payload);
    const fcmResult = await fcmResponse.json();

    if (!fcmResponse.ok) {
      console.error("FCM Error:", fcmResult);
      return new Response(
        JSON.stringify({ error: "Failed to send notification", details: fcmResult }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ success: true, message_id: fcmResult.name }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
