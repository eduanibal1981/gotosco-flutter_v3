-- Add read_at to ride_events so parents can track unread notifications
ALTER TABLE "public"."ride_events"
ADD COLUMN IF NOT EXISTS "read_at" timestamp with time zone;

CREATE INDEX IF NOT EXISTS "idx_ride_events_read_at"
  ON "public"."ride_events" ("read_at");

CREATE POLICY "Parents can update their ride events"
ON "public"."ride_events"
FOR UPDATE
TO "authenticated"
USING (("parent_id" = "auth"."uid"()))
WITH CHECK (("parent_id" = "auth"."uid"()));
