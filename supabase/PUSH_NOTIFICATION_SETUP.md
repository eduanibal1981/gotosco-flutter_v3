# Push Notification Setup Guide

## Files Created
- `supabase/functions/send-notification/index.ts` - Edge Function for FCM
- `supabase/migrations/20260104_push_notifications.sql` - Database setup

---

## Step 1: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/project/gotoscoai-ec5bd/settings/serviceaccounts/adminsdk)
2. Click **"Generate new private key"**
3. Save the JSON file

---

## Step 2: Add Supabase Secrets

Run these commands (replace `YOUR_SERVICE_ACCOUNT_JSON` with the content of the JSON file):

```bash
npx supabase secrets set FIREBASE_PROJECT_ID="gotoscoai-ec5bd"
npx supabase secrets set FIREBASE_SERVICE_ACCOUNT_KEY='{"type":"service_account",...}'
```

---

## Step 3: Run the SQL Migration

Copy the contents of `supabase/migrations/20260104_push_notifications.sql` and run it in Supabase SQL Editor.

**Important:** First enable the `pg_net` extension:
- Dashboard → Database → Extensions → Search "pg_net" → Enable

---

## Step 4: Deploy the Edge Function

```bash
npx supabase functions deploy send-notification --project-ref ixjkvasziamjkeupqvfc
```

---

## Step 5: Test the Notification

From your Driver app, create a ride event:
```dart
await Supabase.instance.client.from('ride_events').insert({
  'booking_id': bookingId,
  'child_id': childId,
  'driver_id': driverId,
  'parent_id': parentId,
  'event_type': 'picked_up', // or 'approaching', 'dropped_off'
});
```
