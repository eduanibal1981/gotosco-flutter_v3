// lib/core/widgets/optimized_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A highly optimized network image widget with:
/// - Shimmer loading placeholder for smooth UX
/// - Memory-efficient caching using memCacheWidth/memCacheHeight
/// - Fade-in animation for professional appearance
/// - 1.5:1 aspect ratio support (mobile-optimized)
/// - Circle variant for avatars
class OptimizedNetworkImage extends StatelessWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// Width of the image container
  final double? width;

  /// Height of the image container (defaults to width / 1.5 for 1.5:1 ratio)
  final double? height;

  /// How the image should be inscribed into the box
  final BoxFit fit;

  /// Border radius for rounded corners
  final double borderRadius;

  /// Whether to show as a circle (for avatars)
  final bool isCircle;

  /// Size for circle avatar (diameter)
  final double? circleSize;

  /// Placeholder widget (optional, defaults to shimmer)
  final Widget Function(BuildContext, String)? placeholder;

  /// Error widget (optional, defaults to icon)
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  /// Fallback text for circle avatars (usually first letter of name)
  final String? fallbackText;

  /// Background color for fallback avatar
  final Color? fallbackBackgroundColor;

  /// Text color for fallback avatar
  final Color? fallbackTextColor;

  /// Duration of fade-in animation
  final Duration fadeInDuration;

  /// Memory cache width (for efficient memory usage)
  /// Defaults to 2x the display width for retina screens
  final int? memCacheWidth;

  /// Memory cache height (for efficient memory usage)
  final int? memCacheHeight;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.isCircle = false,
    this.circleSize,
    this.placeholder,
    this.errorWidget,
    this.fallbackText,
    this.fallbackBackgroundColor,
    this.fallbackTextColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
  });

  /// Creates a circular avatar-optimized image
  /// Perfect for profile pictures, user avatars, etc.
  factory OptimizedNetworkImage.circle({
    Key? key,
    required String imageUrl,
    required double size,
    String? fallbackText,
    Color? fallbackBackgroundColor,
    Color? fallbackTextColor,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    return OptimizedNetworkImage(
      key: key,
      imageUrl: imageUrl,
      isCircle: true,
      circleSize: size,
      fallbackText: fallbackText,
      fallbackBackgroundColor: fallbackBackgroundColor,
      fallbackTextColor: fallbackTextColor,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  /// Creates an image with the mobile-optimized 1.5:1 aspect ratio
  factory OptimizedNetworkImage.mobileRatio({
    Key? key,
    required String imageUrl,
    required double width,
    double borderRadius = 12,
    BoxFit fit = BoxFit.cover,
  }) {
    return OptimizedNetworkImage(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: width / 1.5,
      borderRadius: borderRadius,
      fit: fit,
    );
  }

  /// Calculate effective dimensions for the image
  (double?, double?) get _effectiveDimensions {
    if (isCircle) {
      return (circleSize, circleSize);
    }
    final effectiveHeight = height ?? (width != null ? width! / 1.5 : null);
    return (width, effectiveHeight);
  }

  /// Calculate memory cache dimensions (2x for retina, capped at 1200)
  int? _getMemCacheSize(double? displaySize) {
    if (displaySize == null) return null;
    // 2x for retina screens, but cap at 1200 to prevent excessive memory use
    return (displaySize * 2).clamp(50, 1200).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final (effectiveWidth, effectiveHeight) = _effectiveDimensions;

    // Use provided memCache sizes or calculate from display size
    final cacheWidth = memCacheWidth ?? _getMemCacheSize(effectiveWidth);
    final cacheHeight = memCacheHeight ?? _getMemCacheSize(effectiveHeight);

    // Handle empty URL
    if (imageUrl.isEmpty) {
      return _buildFallback(effectiveWidth, effectiveHeight);
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder:
          placeholder ??
          (context, url) => _buildShimmer(effectiveWidth, effectiveHeight),
      errorWidget:
          errorWidget ??
          (context, url, error) =>
              _buildFallback(effectiveWidth, effectiveHeight),
    );

    // Apply shape clipping
    if (isCircle) {
      return ClipOval(child: image);
    } else if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  /// Build shimmer placeholder
  Widget _buildShimmer(double? width, double? height) {
    final shimmerContent = Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
    );

    Widget shimmer = Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: shimmerContent,
    );

    if (isCircle) {
      return ClipOval(child: shimmer);
    } else if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: shimmer,
      );
    }

    return shimmer;
  }

  /// Build fallback widget for errors or empty URLs
  Widget _buildFallback(double? width, double? height) {
    if (isCircle && fallbackText != null && fallbackText!.isNotEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fallbackBackgroundColor ?? Colors.indigo.shade50,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          fallbackText![0].toUpperCase(),
          style: TextStyle(
            fontSize: (width ?? 40) * 0.4,
            fontWeight: FontWeight.bold,
            color: fallbackTextColor ?? Colors.indigo.shade700,
          ),
        ),
      );
    }

    Widget fallback = Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(
        isCircle ? Icons.person : Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: (width ?? 40) * 0.4,
      ),
    );

    if (isCircle) {
      return ClipOval(child: fallback);
    } else if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: fallback,
      );
    }

    return fallback;
  }
}

/// Provider for optimized image with ImageProvider interface
/// Use this when you need an ImageProvider (e.g., for CircleAvatar backgroundImage)
class OptimizedImageProvider extends CachedNetworkImageProvider {
  OptimizedImageProvider(super.url, {int? maxWidth, int? maxHeight})
    : super(maxWidth: maxWidth ?? 400, maxHeight: maxHeight ?? 400);

  /// Create a provider optimized for small avatars (32-64px)
  factory OptimizedImageProvider.avatar(String url, {double size = 64}) {
    final cacheSize = (size * 2).clamp(50, 200).toInt();
    return OptimizedImageProvider(
      url,
      maxWidth: cacheSize,
      maxHeight: cacheSize,
    );
  }

  /// Create a provider optimized for thumbnail images
  factory OptimizedImageProvider.thumbnail(
    String url, {
    double width = 150,
    double height = 100,
  }) {
    return OptimizedImageProvider(
      url,
      maxWidth: (width * 2).clamp(100, 600).toInt(),
      maxHeight: (height * 2).clamp(100, 400).toInt(),
    );
  }
}
