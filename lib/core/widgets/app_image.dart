import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders either a cached network image or a local asset depending on the URL scheme.
/// Avoids "assets/https%253A/..." 404 errors in Flutter Web and Mobile.
/// Provides smooth fade-in, disk/memory caching, and skeleton loading indicator.
class AppImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final Widget? placeholder;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const AppImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.errorWidget,
    this.placeholder,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPath = imagePath.trim();
    if (cleanPath.isEmpty) {
      return errorWidget ?? _defaultFallback();
    }

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: cleanPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        memCacheWidth: memCacheWidth ?? (width != null ? (width! * 2).toInt() : null),
        memCacheHeight: memCacheHeight ?? (height != null ? (height! * 2).toInt() : null),
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) =>
            placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _defaultFallback(),
      );
    }

    return Image.asset(
      cleanPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultFallback(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1B1B1D),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6FF00)),
          ),
        ),
      ),
    );
  }

  Widget _defaultFallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1B1B1D),
      child: const Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: Colors.white38,
          size: 28,
        ),
      ),
    );
  }
}

