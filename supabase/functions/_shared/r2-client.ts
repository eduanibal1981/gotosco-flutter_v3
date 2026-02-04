// Shared R2 client utilities for Supabase Edge Functions
// Uses AWS S3-compatible API with Cloudflare R2

import { S3Client, PutObjectCommand, HeadObjectCommand, GetObjectCommand, DeleteObjectCommand } from "npm:@aws-sdk/client-s3@3.515.0";
import { getSignedUrl } from "npm:@aws-sdk/s3-request-presigner@3.515.0";

// R2 Configuration from environment
const R2_ACCOUNT_ID = Deno.env.get("R2_ACCOUNT_ID")!;
const R2_ACCESS_KEY_ID = Deno.env.get("R2_ACCESS_KEY_ID")!;
const R2_SECRET_ACCESS_KEY = Deno.env.get("R2_SECRET_ACCESS_KEY")!;
const R2_BUCKET_NAME = Deno.env.get("R2_BUCKET_NAME") || "gotosco-media";
const R2_PUBLIC_URL = Deno.env.get("R2_PUBLIC_URL") || `https://${R2_BUCKET_NAME}.${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;

// R2 uses S3-compatible API
const r2Client = new S3Client({
  region: "auto",
  endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: R2_ACCESS_KEY_ID,
    secretAccessKey: R2_SECRET_ACCESS_KEY,
  },
});

export interface PresignedUploadRequest {
  key: string;
  contentType: string;
  contentLength?: number;
  expiresIn?: number; // seconds, default 300 (5 minutes)
}

export interface PresignedUrlResponse {
  uploadUrl: string;
  expiresIn: number;
}

/**
 * Generate a pre-signed PUT URL for uploading to R2
 */
export async function getPresignedPutUrl(request: PresignedUploadRequest): Promise<PresignedUrlResponse> {
  const expiresIn = request.expiresIn || 300;

  const command = new PutObjectCommand({
    Bucket: R2_BUCKET_NAME,
    Key: request.key,
    ContentType: request.contentType,
    ...(request.contentLength && { ContentLength: request.contentLength }),
  });

  const uploadUrl = await getSignedUrl(r2Client, command, { expiresIn });

  return {
    uploadUrl,
    expiresIn,
  };
}

/**
 * Generate a pre-signed GET URL for reading from R2 (private files)
 */
export async function getPresignedGetUrl(key: string, expiresIn: number = 3600): Promise<string> {
  const command = new GetObjectCommand({
    Bucket: R2_BUCKET_NAME,
    Key: key,
  });

  return await getSignedUrl(r2Client, command, { expiresIn });
}

/**
 * Check if an object exists in R2
 */
export async function objectExists(key: string): Promise<{ exists: boolean; size?: number }> {
  try {
    const command = new HeadObjectCommand({
      Bucket: R2_BUCKET_NAME,
      Key: key,
    });

    const response = await r2Client.send(command);
    return {
      exists: true,
      size: response.ContentLength,
    };
  } catch (error) {
    if (error.name === "NotFound" || error.$metadata?.httpStatusCode === 404) {
      return { exists: false };
    }
    throw error;
  }
}

/**
 * Delete an object from R2
 */
export async function deleteObject(key: string): Promise<void> {
  const command = new DeleteObjectCommand({
    Bucket: R2_BUCKET_NAME,
    Key: key,
  });

  await r2Client.send(command);
}

/**
 * Get the public URL for a file (only works for public/ prefix files)
 */
export function getPublicUrl(key: string): string {
  if (!key.startsWith("public/")) {
    throw new Error("Only files with public/ prefix have public URLs");
  }
  return `${R2_PUBLIC_URL}/${key}`;
}

/**
 * Validate asset type and return storage path details
 */
export interface AssetPathInfo {
  visibility: "public" | "private";
  basePath: string;
  legacyColumn: string;
}

export function getAssetPathInfo(assetType: string): AssetPathInfo {
  switch (assetType) {
    case "avatar":
      return {
        visibility: "public",
        basePath: "public/users",
        legacyColumn: "users.photo_url",
      };
    case "license":
      return {
        visibility: "private",
        basePath: "private/drivers",
        legacyColumn: "drivers.license_image_url",
      };
    case "mulkia":
      return {
        visibility: "private",
        basePath: "private/drivers",
        legacyColumn: "drivers.mulkia_image_url",
      };
    case "child_photo":
      return {
        visibility: "public",
        basePath: "public/children",
        legacyColumn: "children.photo_url",
      };
    case "adv_photo":
      return {
        visibility: "public",
        basePath: "public/drivers/ads",
        legacyColumn: "", // Array column, handled differently
      };
    case "vehicle_photo":
      return {
        visibility: "private",
        basePath: "private/vehicles",
        legacyColumn: "", // Array column, handled in repository
      };
    default:
      throw new Error(`Unknown asset type: ${assetType}`);
  }
}

/**
 * Generate the R2 key for an asset
 */
export function generateR2Key(assetType: string, userId: string, extension: string = "webp"): string {
  const pathInfo = getAssetPathInfo(assetType);
  const timestamp = Date.now();
  const randomSuffix = Math.random().toString(36).substring(2, 8);

  // Structure: {basePath}/{userId}/{assetType}/{timestamp}_{random}.{ext}
  return `${pathInfo.basePath}/${userId}/${assetType}/${timestamp}_${randomSuffix}.${extension}`;
}

// Export config for use in functions
export const config = {
  bucketName: R2_BUCKET_NAME,
  publicUrl: R2_PUBLIC_URL,
};
