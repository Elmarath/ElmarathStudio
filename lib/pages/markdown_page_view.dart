import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/layout/content_width.dart';
import '../widgets/markdown/markdown_view.dart';
import 'not_found_page.dart';

/// `/<slug>`: any `content/pages/<slug>.md`, e.g. the privacy policy.
class MarkdownPageView extends StatelessWidget {
  const MarkdownPageView({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final page = context.content.pages[slug];
    if (page == null) return const NotFoundPage();
    final text = Theme.of(context).textTheme;
    return PageTitle(
      title: page.title,
      child: PageScroll(
        children: [
          ContentWidth(
            maxWidth: ContentWidths.reading,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Insets.xxl + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(page.title, style: text.displaySmall),
                  if (page.description != null) ...[
                    const SizedBox(height: Insets.sm),
                    Text(page.description!, style: text.bodyLarge),
                  ],
                  const SizedBox(height: Insets.xl),
                  SelectionArea(child: MarkdownView(blocks: page.parsed.blocks, sourcePath: page.assetPath)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
