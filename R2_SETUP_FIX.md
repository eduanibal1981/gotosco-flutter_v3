# R2 & Supabase Troubleshooting Guide

## 1. Addressing "Invalid JWT" (401)
The error `FunctionException(status: 401, details: {code: 401, message: Invalid JWT})` means the **Supabase Authentication Token** sent by the app was rejected by the Supabase Edge Function.

**Common Causes:**
1.  **Time Sync Issue (CRITICAL)**: You mentioned your system time is **2026**. Real-world Supabase servers are in **2025**. Any token issued by the server "expires in 1 hour" (e.g., 2025-02-02 01:00). Your device thinks it is 2026, so it treats the token as **expired 1 year ago**.
    *   **Fix**: Please set your testing device/emulator to **Automatic Date & Time** so it matches the real world.
2.  **Session Stale**: The user session might just be old.
    *   **Fix**: Log out and Log back in (you already tried this).

## 2. Setting Up Cloudflare R2 Credentials
You asked about your token: `z5EjaWwMxvtded4Ev_gokoXcdHk5XT-lGHpnG_Gg`.
This looks like a **Cloudflare API Token**, but for file uploads (S3 API), we need **Access Keys**.

### Step 1: Generate S3 Keys in Cloudflare
1.  Log in to [Cloudflare Dashboard](https://dash.cloudflare.com-).
2.  Go to **R2** > **Manage R2 API Tokens** (right sidebar).
3.  Click **Create API Token**.
4.  **Permissions**: Select **Object Read & Write**.
5.  **Specific Bucket**: Select `gotosco-media` (or your bucket).
6.  **TTL**: "Forever" or as needed.
7.  Click **Create API Token**.

### Step 2: Get the Keys
Cloudflare will show you a screen with:
*   **Token**: (The long string you have, `z5E...`) - *We usually don't use this for S3.*
*   **Access Key ID**: (e.g., `8f8287...`) - **REQUIRED**
*   **Secret Access Key**: (e.g., `823908...` - usually 64 hex chars) - **REQUIRED**

### Step 3: Update Supabase Secrets
1.  Go to your [Supabase Dashboard](https://supabase.com/dashboard) > Project > Settings > Edge Functions.
2.  Add/Update these secrets:
    *   `R2_ACCOUNT_ID`: Your Cloudflare Account ID (from R2 overview).
    *   `R2_ACCESS_KEY_ID`: Copy the **Access Key ID** from Step 2.
    *   `R2_SECRET_ACCESS_KEY`: Copy the **Secret Access Key** from Step 2.
    *   `R2_BUCKET_NAME`: `gotosco-media`

## 3. Verify CORS (If on Web)
If you are testing on Web, ensuring CORS is set on the R2 bucket is mandatory.
```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["PUT", "GET", "HEAD"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]
```
