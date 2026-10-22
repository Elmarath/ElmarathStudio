import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/app_image.dart';

/// An image inside Markdown: rounded, never wider than the text column,
/// and opens a zoomable full-screen view on click.
class MarkdownImage extends StatelessWidget {
  const MarkdownImage({super.key, required this.source, this.alt});

  final String source;
  final String? alt;

  void _openViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => _ImageViewer(source: source, alt: alt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.sm),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: () => _openViewer(context),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 640),
              decoration: BoxDecoration(
                borderRadius: Radii.mdAll,
                border: Border.all(color: p.border),
              ),
              child: ClipRRect(
                borderRadius: Radii.mdAll,
                // Animated GIFs repaint every frame; keep that to the image itself.
                child: RepaintBoundary(
                  child: LayoutBuilder(
                    // Decoded no bigger than it's shown: screenshots can be several times
                    // wider than the page, and a full-size copy is slow to decode and to
                    // hand to the GPU the first time it scrolls into view. The viewer
                    // still opens the original.
                    builder: (context, constraints) => AppImage(
                      source,
                      fit: BoxFit.contain,
                      semanticLabel: alt,
                      cacheWidth:
                          constraints.hasBoundedWidth
                              ? (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context)).round()
                              : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.source, this.alt});

  final String source;
  final String? alt;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(child: AppImage(source, fit: BoxFit.contain, semanticLabel: alt)),
              ),
            ),
          ),
          if (alt != null && alt!.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: Insets.lg,
              child: Text(
                alt!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
          Positioned(
            top: Insets.md,
            right: Insets.md,
            child: IconButton.filledTonal(
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
