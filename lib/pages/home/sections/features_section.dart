import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/site_config.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/common/hover_card.dart';
import '../../../widgets/common/links.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/layout/content_width.dart';
import '../../../widgets/layout/responsive_grid.dart';

/// "What you'll find here": one card per item in [SiteConfig.features].
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Insets.xxl),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              eyebrow: "What's here",
              title: 'Everything in one place',
              subtitle: 'Docs for every plugin, a devlog, and a way to get in touch.',
            ),
            ResponsiveGrid(
              minItemWidth: 250,
              children: [
                for (final (i, feature) in SiteConfig.features.indexed)
                  _FeatureCard(feature: feature)
                      .animate(delay: (80 * i).ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final SiteFeature feature;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return HoverCard(
      semanticLabel: feature.title,
      onTap: () => openLink(context, feature.link),
      padding: const EdgeInsets.all(Insets.lg),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: Motion.normal,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.accent.withValues(alpha: hovered ? 0.22 : 0.12),
              borderRadius: Radii.mdAll,
            ),
            child: Icon(feature.icon, color: p.accent, size: 22),
          ),
          const SizedBox(height: Insets.lg - 4),
          Text(feature.title, style: text.titleLarge),
          const SizedBox(height: Insets.sm),
          Text(feature.description, style: text.bodyMedium),
          const Spacer(),
          const SizedBox(height: Insets.lg - 4),
          Row(
            children: [
              Flexible(child: Text(feature.linkLabel, style: text.labelLarge?.copyWith(color: p.accent))),
              const SizedBox(width: 6),
              AnimatedSlide(
                offset: Offset(hovered ? 0.3 : 0, 0),
                duration: Motion.fast,
                child: Icon(
                  isExternalLink(feature.link) ? Icons.north_east : Icons.arrow_forward,
                  size: 16,
                  color: p.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
