import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimmer/shimmer.dart';

part 'secure_image.g.dart';

@riverpod
Future<String> signedUrl(Ref ref, String r2Key) async {
  final mediaService = ref.watch(mediaServiceProvider);
  return mediaService.getSignedUrl(r2Key: r2Key);
}

class SecureImage extends ConsumerWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final double borderRadius;

  const SecureImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 0,
  });

  /// Calculate memory cache size (2x for retina, capped at 1200)
  int? _getMemCacheSize(double? displaySize) {
    if (displaySize == null) return null;
    return (displaySize * 2).clamp(50, 1200).toInt();
  }

  /// Build shimmer placeholder
  Widget _buildShimmer() {
    Widget shimmer = Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      ),
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: shimmer,
      );
    }
    return shimmer;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.image_not_supported),
      );
    }

    final cacheWidth = _getMemCacheSize(width);
    final cacheHeight = _getMemCacheSize(height);

    if (!imageUrl.contains('/private/')) {
      // Public URL, display directly with optimized caching
      Widget image = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        fadeInDuration: const Duration(milliseconds: 300),
        placeholder: placeholder ?? (_, __) => _buildShimmer(),
        errorWidget: errorWidget ?? (_, __, ___) => const Icon(Icons.error),
      );

      if (borderRadius > 0) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: image,
        );
      }
      return image;
    }

    // Private URL: Parse key and get signed URL
    final startIndex = imageUrl.indexOf('private/');
    if (startIndex == -1) {
      return const Icon(Icons.broken_image);
    }

    final r2Key = imageUrl.substring(startIndex);
    final signedUrlAsync = ref.watch(signedUrlProvider(r2Key));

    return signedUrlAsync.when(
      data: (signedUrl) {
        Widget image = CachedNetworkImage(
          imageUrl: signedUrl,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: placeholder ?? (_, __) => _buildShimmer(),
          errorWidget:
              errorWidget ?? (_, __, ___) => const Icon(Icons.lock_clock),
        );

        if (borderRadius > 0) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: image,
          );
        }
        return image;
      },
      loading: () =>
          SizedBox(width: width, height: height, child: _buildShimmer()),
      error: (_, __) => SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
