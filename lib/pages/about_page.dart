import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/site_config.dart';
import '../theme/tokens.dart';
import '../widgets/common/app_image.dart';
import '../widgets/common/links.dart';
import '../widgets/common/section_header.dart';
import '../widgets/layout/content_width.dart';
import '../widgets/markdown/markdown_view.dart';
import 'home/sections/contact_section.dart';

/// `/about`: profile header plus the text from `content/pages/about.md`.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final page = context.content.pages['about'];
    final text = Theme.of(context).textTheme;
    final compact = ScreenSize.of(context).isCompact;

    final avatar = [
      ClipOval(child: AppImage(SiteConfig.avatarUrl, width: 112, height: 112)),
      const SizedBox(width: Insets.xl, height: Insets.lg),
    ];
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(SiteConfig.role),
        const SizedBox(height: Insets.sm),
        Text(SiteConfig.ownerName, style: compact ? text.headlineLarge : text.displaySmall),
        if (page?.description != null) ...[
          const SizedBox(height: Insets.sm),
          Text(page!.description!, style: text.bodyLarge),
        ],
      ],
    );

    return PageTitle(
      title: 'About',
      child: PageScroll(
        children: [
          ContentWidth(
            maxWidth: ContentWidths.reading,
            child: Padding(
              padding: const EdgeInsets.only(top: Insets.xxl + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (compact)
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...avatar, details])
                  else
                    Row(children: [...avatar, Flexible(child: details)]),
                  const SizedBox(height: Insets.lg),
                  Wrap(
                    spacing: Insets.sm,
                    runSpacing: Insets.sm,
                    children: [
                      for (final s in SiteConfig.socials)
                        OutlinedButton.icon(
                          onPressed: () => openLink(context, s.url),
                          icon: Icon(s.icon, size: 16),
                          label: Text(s.label),
                        ),
                    ],
                  ),
                  const SizedBox(height: Insets.xxl),
                  if (page != null)
                    SelectionArea(child: MarkdownView(blocks: page.parsed.blocks, sourcePath: page.assetPath)),
                ],
              ),
            ),
          ),
          const ContactSection(),
        ],
      ),
    );
  }
}
