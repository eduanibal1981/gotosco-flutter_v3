import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/core/services/media_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  const SecureImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.image_not_supported),
      );
    }

    if (!imageUrl.contains('/private/')) {
      // Public URL, display directly
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder:
            placeholder ??
            (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: errorWidget ?? (_, __, ___) => const Icon(Icons.error),
      );
    }

    // Private URL: Parse key and get signed URL
    // Format: .../private/drivers/...
    // extract key starting from 'private/'
    final startIndex = imageUrl.indexOf('private/');
    if (startIndex == -1) {
      // Fallback if formatting is unexpected
      return const Icon(Icons.broken_image);
    }

    final r2Key = imageUrl.substring(startIndex);
    final signedUrlAsync = ref.watch(signedUrlProvider(r2Key));

    return signedUrlAsync.when(
      data: (signedUrl) => CachedNetworkImage(
        imageUrl: signedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder:
            placeholder ??
            (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget:
            errorWidget ?? (_, __, ___) => const Icon(Icons.lock_clock),
      ),
      loading: () => SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.broken_image),
      ),
    );
  }
}
