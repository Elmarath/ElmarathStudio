import 'package:flutter/material.dart';

import '../../config/site_config.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/links.dart';
import 'content_width.dart';
import 'site_nav_bar.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final compact = ScreenSize.of(context).isCompact;

    final brand = SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SiteLogo(),
          const SizedBox(height: Insets.md),
          Text('${SiteConfig.role}. Plugins, documentation and devlogs for Unreal Engine.', style: text.bodyMedium),
          const SizedBox(height: Insets.md),
          Wrap(
            spacing: 2,
            children: [
              for (final s in SiteConfig.socials)
                IconButton(
                  tooltip: s.label,
                  icon: Icon(s.icon, size: 18),
                  onPressed: () => openLink(context, s.url),
                ),
            ],
          ),
        ],
      ),
    );

    final columns = [
      for (final column in SiteConfig.footerColumns)
        SizedBox(
          width: 170,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(column.title.toUpperCase(), style: text.labelSmall),
              const SizedBox(height: Insets.md),
              for (final link in column.links)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InlineLink(
                    label: link.label,
                    href: link.path,
                    style: text.bodyMedium?.copyWith(color: p.textSecondary),
                  ),
                ),
            ],
          ),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
      child: ContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: Insets.xxl,
              runSpacing: Insets.xl,
              children: [brand, ...columns],
            ),
            const SizedBox(height: Insets.xl),
            Divider(color: p.border),
            const SizedBox(height: Insets.md),
            Flex(
              direction: compact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('© ${DateTime.now().year} ${SiteConfig.ownerName}. Built with Flutter.', style: text.bodySmall),
                if (!compact) const Spacer() else const SizedBox(height: Insets.xs),
                Text('Unreal Engine is a trademark of Epic Games, Inc.', style: text.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
