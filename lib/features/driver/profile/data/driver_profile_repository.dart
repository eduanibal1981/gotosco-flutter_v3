// lib/features/driver/profile/data/driver_profile_repository.dart
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotosco_v3/core/services/media_service.dart';
import 'driver_profile_model.dart';
import 'driver_schedule_model.dart';

part 'driver_profile_repository.g.dart';

@riverpod
DriverProfileRepository driverProfileRepository(Ref ref) {
  return DriverProfileRepository(
    Supabase.instance.client,
    ref.read(mediaServiceProvider),
  );
}

/// Provider for the current driver's profile
@riverpod
Future<DriverProfileModel?> currentDriverProfile(Ref ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  debugPrint('DEBUG: currentDriverProfile called, userId: $userId');

  if (userId == null) {
    debugPrint('DEBUG: userId is null, returning null');
    return null;
  }

  final repository = ref.read(driverProfileRepositoryProvider);
  final profile = await repository.getDriverProfile(userId);
  debugPrint(
    'DEBUG: getDriverProfile returned: ${profile != null ? 'profile found' : 'null'}',
  );
  return profile;
}

/// Provider for the current driver's schedules
@riverpod
Future<List<DriverScheduleModel>> driverSchedules(Ref ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  final repository = ref.read(driverProfileRepositoryProvider);
  return repository.getDriverSchedules(userId);
}

class DriverProfileRepository {
  final SupabaseClient _supabase;
  final MediaService _mediaService;

  DriverProfileRepository(this._supabase, this._mediaService);

  /// Fetches the driver profile for the given user ID
  Future<DriverProfileModel?> getDriverProfile(String userId) async {
    debugPrint('DEBUG: getDriverProfile called with userId: $userId');

    try {
      // First, try with the user join - select all columns from users
      debugPrint('DEBUG: Attempting JOIN query on drivers table...');
      final response = await _supabase
          .from('drivers')
          .select('''
            *,
            users!drivers_user_id_fkey(*)
          ''')
          .eq('user_id', userId)
          .maybeSingle();

      debugPrint(
        'DEBUG: JOIN query response: ${response != null ? 'data found' : 'null'}',
      );

      if (response != null) {
        debugPrint('DEBUG: Response data: $response');
        final coverage = await _getCoverageNames(userId);
        return DriverProfileModel.fromMap({
          ...response,
          'service_areas': coverage['areas'],
          'schools': coverage['schools'],
        });
      }
    } catch (e) {
      debugPrint('DEBUG: Error fetching driver profile with JOIN: $e');
      // Fall through to try without the join
    }

    // Fallback: Try without the user join (in case foreign key is missing/misconfigured)
    try {
      debugPrint('DEBUG: Attempting fallback query (no JOIN)...');
      final driverData = await _supabase
          .from('drivers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      debugPrint(
        'DEBUG: Fallback driver query result: ${driverData != null ? 'found' : 'null'}',
      );

      if (driverData == null) {
        debugPrint('DEBUG: No driver data found for userId: $userId');
        return null;
      }

      debugPrint('DEBUG: Driver data found: $driverData');

      // Fetch user data separately - use * to get all available columns
      // since the schema may vary (email column doesn't exist)
      Map<String, dynamic>? userData;
      try {
        userData = await _supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .maybeSingle();
        debugPrint('DEBUG: User data: $userData');
      } catch (userError) {
        debugPrint('DEBUG: Error fetching user data: $userError');
        // Continue without user data - driver data is still valid
      }

      // Combine the data
      final coverage = await _getCoverageNames(userId);
      final combinedData = {
        ...driverData,
        'users': userData,
        'service_areas': coverage['areas'],
        'schools': coverage['schools'],
      };

      return DriverProfileModel.fromMap(combinedData);
    } catch (e) {
      debugPrint('DEBUG: Error fetching driver profile (fallback): $e');
      return null;
    }
  }

  Future<Map<String, List<String>>> _getCoverageNames(String userId) async {
    final serviceAreas = <String>[];
    final schools = <String>[];

    try {
      final areaRows = await _supabase
          .from('driver_service_areas')
          .select('area:areas(name)')
          .eq('driver_id', userId);
      for (final row in areaRows as List) {
        final area = row['area'] as Map<String, dynamic>?;
        final name = area?['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          serviceAreas.add(name);
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Error loading service areas: $e');
    }

    try {
      final schoolRows = await _supabase
          .from('driver_covered_schools')
          .select('school:schools(name)')
          .eq('driver_id', userId);
      for (final row in schoolRows as List) {
        final school = row['school'] as Map<String, dynamic>?;
        final name = school?['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          schools.add(name);
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Error loading covered schools: $e');
    }

    return {'areas': serviceAreas, 'schools': schools};
  }

  /// Updates the driver profile
  Future<bool> updateDriverProfile(
    String driverId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Primary key is user_id, not id
      await _supabase.from('drivers').update(updates).eq('user_id', driverId);
      return true;
    } catch (e) {
      debugPrint('Error updating driver profile: $e');
      return false;
    }
  }

  /// Updates the driver's current location
  /// Uses PostGIS geography format for storing coordinates
  Future<bool> updateDriverLocation({
    required String driverId,
    required String locationText,
    required double lat,
    required double lng,
  }) async {
    try {
      // Create PostGIS geography point in WKT format
      final geoPoint = 'SRID=4326;POINT($lng $lat)';

      await _supabase
          .from('users')
          .update({
            'location_text': locationText,
            'location_geo': geoPoint,
            'last_location_update': DateTime.now().toIso8601String(),
          })
          .eq('id', driverId);

      return true;
    } catch (e) {
      debugPrint('Error updating driver location: $e');
      return false;
    }
  }

  /// Updates the driver's start point location
  Future<bool> updateStartLocation({
    required String driverId,
    required String locationText,
    required double lat,
    required double lng,
  }) async {
    try {
      // Create PostGIS geography point in WKT format
      final geoPoint = 'SRID=4326;POINT($lng $lat)';

      await _supabase
          .from('drivers')
          .update({
            'start_location_text': locationText,
            'start_location_geo': geoPoint,
          })
          .eq('user_id', driverId);

      return true;
    } catch (e) {
      debugPrint('Error updating start location: $e');
      return false;
    }
  }

  /// Copies current location to start location
  Future<bool> copyLocationToStartPoint(String driverId) async {
    try {
      // Fetch current location
      final user = await _supabase
          .from('users')
          .select('location_text, location_geo')
          .eq('id', driverId)
          .maybeSingle();

      if (user == null || user['location_geo'] == null) {
        return false;
      }

      await _supabase
          .from('drivers')
          .update({
            'start_location_text': user['location_text'],
            'start_location_geo': user['location_geo'],
          })
          .eq('user_id', driverId);

      return true;
    } catch (e) {
      debugPrint('Error copying location to start point: $e');
      return false;
    }
  }

  /// Uploads a document (license or mulkia) using R2 hybrid storage
  /// Compresses to JPEG, uploads to Cloudflare R2 via signed URL,
  /// and updates the legacy database columns
  /// Falls back to Supabase Storage if R2 fails
  /// Returns the public/signed URL of the uploaded file
  Future<String> uploadDocument({
    required String driverId,
    required XFile file,
    required String documentType, // 'license' or 'mulkia'
    void Function(UploadProgress)? onProgress,
  }) async {
    try {
      // Determine asset type
      final assetType = documentType == 'license'
          ? MediaAssetType.license
          : MediaAssetType.mulkia;

      final asset = await _mediaService.uploadMedia(
        file,
        assetType,
        originalFilename: file.name,
        onProgress: onProgress,
      );

      debugPrint('Document uploaded successfully via R2: ${asset.url}');
      return asset.url;
    } catch (e) {
      debugPrint('R2 upload failed, falling back to Supabase Storage: $e');
      // Fallback to legacy Supabase Storage upload
      final url = await _uploadDocumentLegacy(
        driverId: driverId,
        file: file,
        documentType: documentType,
      );
      if (url == null) {
        throw Exception('Failed to upload document');
      }
      return url;
    }
  }

  /// Legacy upload method using Supabase Storage (fallback)
  Future<String?> _uploadDocumentLegacy({
    required String driverId,
    required XFile file,
    required String documentType,
  }) async {
    try {
      debugPrint('Using legacy Supabase Storage upload...');
      final extension = file.name.split('.').last;
      final fileName =
          '${driverId}_${documentType}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = 'driver_documents/$driverId/$fileName';

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from('documents')
          .uploadBinary(storagePath, bytes);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('documents')
          .getPublicUrl(storagePath);

      // Update driver record with the URL
      final fieldName = documentType == 'license'
          ? 'license_image_url'
          : 'mulkia_image_url';
      await _supabase
          .from('drivers')
          .update({fieldName: publicUrl})
          .eq('user_id', driverId);

      debugPrint('Document uploaded successfully via Supabase: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading document (legacy): $e');
      return null;
    }
  }

  /// Uploads a vehicle picture and appends it to the vehicle_image_urls list
  Future<String> uploadVehiclePicture({
    required String driverId,
    required XFile file,
    void Function(UploadProgress)? onProgress,
  }) async {
    try {
      // 1. Upload to R2
      final asset = await _mediaService.uploadMedia(
        file,
        MediaAssetType.vehiclePhoto,
        onProgress: onProgress,
      );

      final newUrl = asset.url;
      debugPrint('Vehicle picture uploaded to R2: $newUrl');

      // 2. Fetch current list
      final response = await _supabase
          .from('drivers')
          .select('vehicle_image_urls')
          .eq('user_id', driverId)
          .single();

      final List<String> currentUrls =
          (response['vehicle_image_urls'] as List?)
              ?.whereType<String>()
              .toList() ??
          [];

      // 3. Append and update
      final updatedUrls = [...currentUrls, newUrl];

      await _supabase
          .from('drivers')
          .update({'vehicle_image_urls': updatedUrls})
          .eq('user_id', driverId);

      return newUrl;
    } catch (e) {
      debugPrint('Error uploading vehicle picture: $e');
      // Fallback: Try simple upload if media service fails completely (unlikely if uploadMedia worked)
      // But if fetch/update fails, we should rethrow
      throw Exception('Failed to upload vehicle picture: $e');
    }
  }

  /// Removes a vehicle picture URL from the driver's profile
  Future<void> deleteVehiclePicture({
    required String driverId,
    required String imageUrl,
  }) async {
    try {
      // 1. Fetch current list
      final response = await _supabase
          .from('drivers')
          .select('vehicle_image_urls')
          .eq('user_id', driverId)
          .single();

      final List<String> currentUrls =
          (response['vehicle_image_urls'] as List?)
              ?.whereType<String>()
              .toList() ??
          [];

      // 2. Remove the specific URL
      final updatedUrls = currentUrls.where((url) => url != imageUrl).toList();

      // 3. Update the database
      await _supabase
          .from('drivers')
          .update({'vehicle_image_urls': updatedUrls})
          .eq('user_id', driverId);

      debugPrint('Vehicle picture removed from drivers table: $imageUrl');

      // Delete the actual file from R2
      try {
        // Extract key if it's a private file
        // Helper logic similar to SecureImage
        if (imageUrl.contains('private/')) {
          final startIndex = imageUrl.indexOf('private/');
          final key = imageUrl.substring(startIndex);

          await _supabase.functions.invoke('delete-file', body: {'key': key});
          debugPrint('File deleted from R2: $key');
        }
      } catch (e) {
        // Log error but don't fail the operation since DB update succeeded
        debugPrint('Warning: Failed to delete file from R2: $e');
      }
    } catch (e) {
      debugPrint('Error deleting vehicle picture: $e');
      throw Exception('Failed to delete vehicle picture: $e');
    }
  }

  /// Creates a driver profile for a new driver
  Future<String?> createDriverProfile({
    required String userId,
    required String vehicleType,
  }) async {
    try {
      final response = await _supabase
          .from('drivers')
          .insert({
            'user_id': userId,
            'vehicle_type': vehicleType,
            'is_verified': false,
          })
          .select('user_id')
          .single();

      // Primary key is user_id
      return response['user_id'] as String?;
    } catch (e) {
      debugPrint('Error creating driver profile: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCHEDULE METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all schedules for a driver
  Future<List<DriverScheduleModel>> getDriverSchedules(String driverId) async {
    try {
      final response = await _supabase
          .from('driver_schedules')
          .select()
          .eq('driver_id', driverId)
          .eq('is_active', true)
          .order('day_of_week');

      return (response as List)
          .map((e) => DriverScheduleModel.fromMap(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching driver schedules: $e');
      return [];
    }
  }

  /// Check if driver has at least one schedule
  Future<bool> hasSchedules(String driverId) async {
    try {
      final response = await _supabase
          .from('driver_schedules')
          .select('id')
          .eq('driver_id', driverId)
          .eq('is_active', true)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('Error checking schedules: $e');
      return false;
    }
  }

  /// Create a new schedule
  Future<String?> createSchedule(DriverScheduleModel schedule) async {
    try {
      final mapData = schedule.toMap();
      debugPrint(
        'DEBUG createSchedule: Inserting schedule with data: $mapData',
      );

      final response = await _supabase
          .from('driver_schedules')
          .insert(mapData)
          .select('id')
          .single();

      debugPrint(
        'DEBUG createSchedule: Success! Created schedule with id: ${response['id']}',
      );
      return response['id'] as String?;
    } catch (e) {
      debugPrint('DEBUG createSchedule ERROR: $e');
      return null;
    }
  }

  /// Update a schedule
  Future<bool> updateSchedule(
    String scheduleId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _supabase
          .from('driver_schedules')
          .update(updates)
          .eq('id', scheduleId);
      return true;
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      return false;
    }
  }

  /// Delete a schedule (soft delete by setting is_active to false)
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabase
          .from('driver_schedules')
          .update({'is_active': false})
          .eq('id', scheduleId);
      return true;
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      return false;
    }
  }
}
