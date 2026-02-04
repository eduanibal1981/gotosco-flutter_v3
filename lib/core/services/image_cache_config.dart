// lib/core/services/image_cache_config.dart
import 'package:flutter/painting.dart';

/// Configuration for image caching to optimize memory and performance
class ImageCacheConfig {
  /// Initialize image cache settings
  /// Call this in main.dart before runApp()
  static void initialize() {
    // Configure Flutter's in-memory image cache
    // Maximum 100 images in memory cache
    PaintingBinding.instance.imageCache.maximumSize = 100;

    // Maximum 50MB for memory cache
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;
  }

  /// Clear the image cache
  /// Useful when app goes to background or on low memory warnings
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSize': cache.maximumSize,
      'maximumSizeBytes': cache.maximumSizeBytes,
      'liveImageCount': cache.liveImageCount,
      'pendingImageCount': cache.pendingImageCount,
    };
  }
}
