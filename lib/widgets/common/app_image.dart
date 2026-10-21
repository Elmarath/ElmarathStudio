import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

/// Shows an image from the asset bundle (`content/...`, `assets/...`) or a URL,
/// with a fade-in and a quiet placeholder when it can't be loaded.
class AppImage extends StatelessWidget {
  const AppImage(
    this.source, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.semanticLabel,
    this.cacheWidth,
    this.filterQuality = FilterQuality.medium,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  /// Decode the image at this pixel width (smaller is cheaper; tiny values look blurred).
  final int? cacheWidth;
  final FilterQuality filterQuality;

  bool get isNetwork => source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    Widget frame(BuildContext context, Widget child, int? frame, bool syncLoaded) {
      if (syncLoaded) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: child,
      );
    }

    Widget error(BuildContext context, Object error, StackTrace? stack) => _Broken(source: source);

    if (isNetwork) {
      return Image.network(
        source,
        cacheWidth: cacheWidth,
        filterQuality: filterQuality,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        frameBuilder: frame,
        errorBuilder: error,
        // Fall back to an <img> element for hosts that don't send CORS headers.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      );
    }
    return Image.asset(
      source,
      cacheWidth: cacheWidth,
      filterQuality: filterQuality,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      frameBuilder: frame,
      errorBuilder: error,
    );
  }
}

class _Broken extends StatelessWidget {
  const _Broken({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      color: p.surfaceRaised,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Tooltip(
        message: 'Image not found: $source',
        child: Icon(Icons.image_not_supported_outlined, color: p.textMuted),
      ),
    );
  }
}
