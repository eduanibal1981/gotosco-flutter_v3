-- Add transport_requests table for parent driver requests
CREATE TABLE IF NOT EXISTS "public"."transport_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "parent_id" "uuid" NOT NULL,
    "child_id" "uuid",
    "child_name" "text" NOT NULL,
    "child_age" integer,
    "child_gender" "text",
    "child_grade" "text",
    "school_name" "text",
    "hometxt_location" "text",
    "schooltxt_location" "text",
    "homegeo_location" "public"."geography"(Point,4326),
    "schoolgeo_location" "public"."geography"(Point,4326),
    "home_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("homegeo_location")::"public"."geometry")) STORED,
    "home_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("homegeo_location")::"public"."geometry")) STORED,
    "school_lat" double precision GENERATED ALWAYS AS ("public"."st_y"(("schoolgeo_location")::"public"."geometry")) STORED,
    "school_lng" double precision GENERATED ALWAYS AS ("public"."st_x"(("schoolgeo_location")::"public"."geometry")) STORED,
    "booking_type" "text" DEFAULT 'Two Way'::"text",
    "notes" "text",
    "status" "text" DEFAULT 'open'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "transport_requests_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "transport_requests_booking_type_check" CHECK (("booking_type" = ANY (ARRAY['Two Way'::"text", 'One Way to School'::"text", 'One Way Back Home'::"text", 'Other'::"text"]))),
    CONSTRAINT "transport_requests_status_check" CHECK (("status" = ANY (ARRAY['open'::"text", 'closed'::"text", 'cancelled'::"text"])) )
);

ALTER TABLE "public"."transport_requests" OWNER TO "postgres";

ALTER TABLE "public"."transport_requests" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can manage own transport requests" ON "public"."transport_requests"
USING (("auth"."uid"() = "parent_id"))
WITH CHECK (("auth"."uid"() = "parent_id"));

CREATE POLICY "Drivers can view transport requests" ON "public"."transport_requests"
FOR SELECT
USING (EXISTS (
  SELECT 1 FROM "public"."users" u
  WHERE u.id = "auth"."uid"()
    AND 'driver' = ANY (u.role)
));

GRANT ALL ON TABLE "public"."transport_requests" TO "anon";
GRANT ALL ON TABLE "public"."transport_requests" TO "authenticated";
GRANT ALL ON TABLE "public"."transport_requests" TO "service_role";

