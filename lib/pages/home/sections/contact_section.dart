import 'package:flutter/material.dart';
import '../../../widgets/common/brand_icons.dart';

import '../../../config/site_config.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/common/links.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/layout/content_width.dart';

/// "Let's work together" band. Also used at the bottom of the About page.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final compact = ScreenSize.of(context).isCompact;
    final linkedIn = SiteConfig.socials.where((s) => s.label == 'LinkedIn').firstOrNull;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Open to work'),
        const SizedBox(height: Insets.sm),
        Text("Let's build something together.", style: text.headlineLarge),
        const SizedBox(height: Insets.sm),
        Text(
          'Hiring a gameplay programmer, need a custom Unreal system, or have feedback on a plugin? I read every message.',
          style: text.bodyLarge,
        ),
      ],
    );

    final actions = Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        FilledButton.icon(
          onPressed: () => openLink(context, 'mailto:${SiteConfig.email}'),
          icon: const Icon(Icons.mail_outline, size: 18),
          label: const Text('Email me'),
        ),
        if (linkedIn != null)
          OutlinedButton.icon(
            onPressed: () => openLink(context, linkedIn.url),
            icon: const Icon(BrandIcons.linkedin, size: 16),
            label: const Text('LinkedIn'),
          ),
        OutlinedButton.icon(
          onPressed: () => openLink(context, SiteConfig.resumeUrl),
          icon: const Icon(Icons.description_outlined, size: 18),
          label: const Text('Resume'),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.section),
      child: ContentWidth(
        child: Container(
          padding: EdgeInsets.all(compact ? Insets.lg : Insets.xxl),
          decoration: BoxDecoration(
            borderRadius: Radii.lgAll,
            border: Border.all(color: p.border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [p.heroGlow.withValues(alpha: 0.5), p.surface],
            ),
          ),
          child: compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [copy, const SizedBox(height: Insets.lg), actions])
              : Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: Insets.xl),
                    Flexible(child: actions),
                  ],
                ),
        ),
      ),
    );
  }
}
