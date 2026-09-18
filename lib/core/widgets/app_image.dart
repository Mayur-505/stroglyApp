import 'package:flutter/material.dart';

/// Renders either a network image or a local asset depending on the URL scheme.
/// Avoids "assets/https%253A/..." 404 errors in Flutter Web and Mobile.
class AppImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPath = imagePath.trim();
    if (cleanPath.isEmpty) {
      return errorWidget ?? _defaultFallback();
    }

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return Image.network(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
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
