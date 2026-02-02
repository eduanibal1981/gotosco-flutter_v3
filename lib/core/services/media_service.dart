// lib/core/services/media_service.dart
// Production-grade media service for R2 uploads with WebP compression

import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'media_service.g.dart';

/// Asset types supported by the media system
enum MediaAssetType { avatar, license, mulkia, childPhoto, advPhoto }

extension MediaAssetTypeExtension on MediaAssetType {
  String get value {
    switch (this) {
      case MediaAssetType.avatar:
        return 'avatar';
      case MediaAssetType.license:
        return 'license';
      case MediaAssetType.mulkia:
        return 'mulkia';
      case MediaAssetType.childPhoto:
        return 'child_photo';
      case MediaAssetType.advPhoto:
        return 'adv_photo';
    }
  }

  /// Maximum dimension (width/height) for this asset type
  int get maxDimension {
    switch (this) {
      case MediaAssetType.avatar:
        return 800;
      case MediaAssetType.license:
      case MediaAssetType.mulkia:
        return 1600; // Higher quality for documents
      case MediaAssetType.childPhoto:
        return 800;
      case MediaAssetType.advPhoto:
        return 1200;
    }
  }

  /// Quality setting for WebP compression (0-100)
  int get quality {
    switch (this) {
      case MediaAssetType.avatar:
        return 85;
      case MediaAssetType.license:
      case MediaAssetType.mulkia:
        return 90; // Higher quality for documents
      case MediaAssetType.childPhoto:
        return 85;
      case MediaAssetType.advPhoto:
        return 85;
    }
  }
}

/// Response from request-upload edge function
class UploadRequest {
  final String assetId;
  final String uploadUrl;
  final String r2Key;
  final String visibility;
  final int expiresIn;

  UploadRequest({
    required this.assetId,
    required this.uploadUrl,
    required this.r2Key,
    required this.visibility,
    required this.expiresIn,
  });

  factory UploadRequest.fromJson(Map<String, dynamic> json) {
    return UploadRequest(
      assetId: json['asset_id'] as String,
      uploadUrl: json['upload_url'] as String,
      r2Key: json['r2_key'] as String,
      visibility: json['visibility'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }
}

/// Response from finalize-upload edge function
class MediaAsset {
  final String assetId;
  final String url;
  final String r2Key;
  final String visibility;

  MediaAsset({
    required this.assetId,
    required this.url,
    required this.r2Key,
    required this.visibility,
  });

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      assetId: json['asset_id'] as String,
      url: json['url'] as String,
      r2Key: json['r2_key'] as String,
      visibility: json['visibility'] as String,
    );
  }

  bool get isPrivate => visibility == 'private';
}

/// Exception for media service errors
class MediaServiceException implements Exception {
  final String message;
  final int? statusCode;

  MediaServiceException(this.message, [this.statusCode]);

  @override
  String toString() => 'MediaServiceException: $message (status: $statusCode)';
}

@riverpod
MediaService mediaService(Ref ref) {
  return MediaService(Supabase.instance.client);
}

/// Production-grade media service for R2 uploads
class MediaService {
  final SupabaseClient _supabase;

  MediaService(this._supabase);

  /// Compress and resize an image file to WebP format
  /// Runs in an isolate to avoid blocking the UI thread
  Future<Uint8List> compressImage(
    XFile file, {
    int maxDimension = 1200,
    int quality = 85,
  }) async {
    // Read file bytes
    final bytes = await file.readAsBytes();

    // Run compression in isolate
    return compute(
      _compressImageIsolate,
      _CompressParams(
        bytes: bytes,
        maxDimension: maxDimension,
        quality: quality,
      ),
    );
  }

  /// Request a pre-signed upload URL from the edge function
  Future<UploadRequest> requestUpload(
    MediaAssetType type, {
    int? fileSize,
    String? originalFilename,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check if user is authenticated
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      debugPrint('MediaService: Checking auth status...');
      debugPrint('MediaService: User ID: ${user?.id}');
      debugPrint('MediaService: Session exists: ${session != null}');
      debugPrint('MediaService: Token expires at: ${session?.expiresAt}');

      if (session == null || user == null) {
        throw MediaServiceException('User not authenticated. Please log in again.');
      }

      // Check if token is expired
      final expiresAt = session.expiresAt;
      if (expiresAt != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        if (expiryDate.isBefore(DateTime.now())) {
          debugPrint('MediaService: Token expired at $expiryDate, refreshing...');
          // Try to refresh the session
          await _supabase.auth.refreshSession();
        }
      }

      debugPrint('MediaService: Invoking request-upload function...');
      final response = await _supabase.functions.invoke(
        'request-upload',
        body: {
          'asset_type': type.value,
          'content_type': 'image/jpeg',
          if (fileSize != null) 'file_size': fileSize,
          if (originalFilename != null) 'original_filename': originalFilename,
          if (metadata != null) 'metadata': metadata,
        },
      );

      debugPrint('MediaService: Response status: ${response.status}');
      debugPrint('MediaService: Response data: ${response.data}');

      if (response.status != 200) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw MediaServiceException(error.toString(), response.status);
      }

      return UploadRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('MediaService: Error in requestUpload: $e');
      if (e is MediaServiceException) rethrow;
      throw MediaServiceException('Failed to request upload: $e');
    }
  }

  /// Upload data directly to R2 via pre-signed PUT URL
  Future<void> uploadToR2(
    String uploadUrl,
    Uint8List data, {
    String contentType = 'image/jpeg',
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final request = http.Request('PUT', Uri.parse(uploadUrl));
      request.headers['Content-Type'] = contentType;
      request.headers['Content-Length'] = data.length.toString();
      request.bodyBytes = data;

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        throw MediaServiceException(
          'Upload failed: $body',
          streamedResponse.statusCode,
        );
      }
    } catch (e) {
      if (e is MediaServiceException) rethrow;
      throw MediaServiceException('Upload to R2 failed: $e');
    }
  }

  /// Finalize upload - confirms the file is in R2 and updates database
  Future<MediaAsset> finalizeUpload(String assetId) async {
    try {
      final response = await _supabase.functions.invoke(
        'finalize-upload',
        body: {'asset_id': assetId},
      );

      if (response.status != 200) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw MediaServiceException(error.toString(), response.status);
      }

      return MediaAsset.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is MediaServiceException) rethrow;
      throw MediaServiceException('Failed to finalize upload: $e');
    }
  }

  /// Get a signed URL for accessing private assets
  /// Can lookup by either assetId OR r2Key
  Future<String> getSignedUrl({
    String? assetId,
    String? r2Key,
    int expiresIn = 3600,
  }) async {
    assert(
      assetId != null || r2Key != null,
      'Must provide either assetId or r2Key',
    );

    try {
      final response = await _supabase.functions.invoke(
        'get-signed-url',
        body: {
          if (assetId != null) 'asset_id': assetId,
          if (r2Key != null) 'r2_key': r2Key,
          'expires_in': expiresIn,
        },
      );

      if (response.status != 200) {
        final error = response.data is Map
            ? response.data['error']
            : 'Unknown error';
        throw MediaServiceException(error.toString(), response.status);
      }

      return response.data['url'] as String;
    } catch (e) {
      if (e is MediaServiceException) rethrow;
      throw MediaServiceException('Failed to get signed URL: $e');
    }
  }

  /// Complete upload flow: compress, request URL, upload to R2, finalize
  /// This is the main method to use for uploading media
  Future<MediaAsset> uploadMedia(
    XFile file,
    MediaAssetType type, {
    String? originalFilename,
    Map<String, dynamic>? metadata,
    void Function(UploadProgress)? onProgress,
  }) async {
    onProgress?.call(
      UploadProgress(stage: UploadStage.compressing, progress: 0),
    );

    // Step 1: Compress image
    final compressed = await compressImage(
      file,
      maxDimension: type.maxDimension,
      quality: type.quality,
    );

    onProgress?.call(
      UploadProgress(stage: UploadStage.compressing, progress: 1),
    );

    // Step 2: Request upload URL
    onProgress?.call(
      UploadProgress(stage: UploadStage.requesting, progress: 0),
    );

    final request = await requestUpload(
      type,
      fileSize: compressed.length,
      originalFilename: originalFilename ?? file.path.split('/').last,
      metadata: metadata,
    );

    onProgress?.call(
      UploadProgress(stage: UploadStage.requesting, progress: 1),
    );

    // Step 3: Upload to R2
    onProgress?.call(UploadProgress(stage: UploadStage.uploading, progress: 0));

    await uploadToR2(request.uploadUrl, compressed);

    onProgress?.call(UploadProgress(stage: UploadStage.uploading, progress: 1));

    // Step 4: Finalize
    onProgress?.call(
      UploadProgress(stage: UploadStage.finalizing, progress: 0),
    );

    final asset = await finalizeUpload(request.assetId);

    onProgress?.call(
      UploadProgress(stage: UploadStage.finalizing, progress: 1),
    );

    return asset;
  }
}

/// Upload progress stages
enum UploadStage { compressing, requesting, uploading, finalizing }

/// Upload progress information
class UploadProgress {
  final UploadStage stage;
  final double progress; // 0.0 to 1.0

  UploadProgress({required this.stage, required this.progress});

  String get stageLabel {
    switch (stage) {
      case UploadStage.compressing:
        return 'Compressing image...';
      case UploadStage.requesting:
        return 'Preparing upload...';
      case UploadStage.uploading:
        return 'Uploading...';
      case UploadStage.finalizing:
        return 'Finalizing...';
    }
  }
}

/// Parameters for isolate compression
class _CompressParams {
  final Uint8List bytes;
  final int maxDimension;
  final int quality;

  _CompressParams({
    required this.bytes,
    required this.maxDimension,
    required this.quality,
  });
}

/// Image compression function that runs in an isolate
Uint8List _compressImageIsolate(_CompressParams params) {
  // Decode image
  final image = img.decodeImage(params.bytes);
  if (image == null) {
    throw MediaServiceException('Failed to decode image');
  }

  // Resize if needed
  img.Image resized;
  if (image.width > params.maxDimension || image.height > params.maxDimension) {
    if (image.width > image.height) {
      resized = img.copyResize(image, width: params.maxDimension);
    } else {
      resized = img.copyResize(image, height: params.maxDimension);
    }
  } else {
    resized = image;
  }

  // Encode as JPEG with quality setting
  // Note: WebP encoding not available in image package 4.x, using JPEG for compression
  final jpegBytes = img.encodeJpg(resized, quality: params.quality);

  return Uint8List.fromList(jpegBytes);
}
