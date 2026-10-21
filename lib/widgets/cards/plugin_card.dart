import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/app_image.dart';
import '../common/hover_card.dart';

/// A docs folder (usually one plugin) with its thumbnail and pitch.
class PluginCard extends StatelessWidget {
  const PluginCard({super.key, required this.category});

  final DocCategory category;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final pages = category.allPages.length;
    return HoverCard(
      semanticLabel: category.label,
      onTap: () => context.go(category.route),
      padding: const EdgeInsets.all(Insets.md),
      builder: (context, hovered) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PluginThumbnail(category: category, size: 88, hovered: hovered),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.label, style: text.titleMedium),
                const SizedBox(height: 6),
                Text(category.pitch, maxLines: 3, overflow: TextOverflow.ellipsis, style: text.bodyMedium),
                const SizedBox(height: Insets.sm),
                Text(
                  '$pages ${pages == 1 ? 'page' : 'pages'}',
                  style: text.labelMedium?.copyWith(color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PluginThumbnail extends StatelessWidget {
  const PluginThumbnail({super.key, required this.category, required this.size, this.hovered = false});

  final DocCategory category;
  final double size;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.14),
      child: SizedBox.square(
        dimension: size,
        child: category.thumbnail != null
            ? HoverZoom(hovered: hovered, child: AppImage(category.thumbnail!))
            : ColoredBox(
                color: p.surfaceRaised,
                child: Icon(Icons.extension_outlined, color: p.textMuted, size: size * 0.4),
              ),
      ),
    );
  }
}
