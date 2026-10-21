import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_palette.dart';
import '../theme/tokens.dart';
import '../widgets/layout/content_width.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.showFooter = true});

  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PageTitle(
      title: 'Page not found',
      child: PageScroll(
        showFooter: showFooter,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 120),
            child: ContentWidth(
              child: Column(
                children: [
                  Text('404', style: text.displayLarge?.copyWith(color: context.palette.accent, fontSize: 96)),
                  const SizedBox(height: Insets.md),
                  Text('Page not found', style: text.headlineMedium),
                  const SizedBox(height: Insets.sm),
                  Text(
                    "The page you're looking for doesn't exist or has moved.",
                    textAlign: TextAlign.center,
                    style: text.bodyLarge,
                  ),
                  const SizedBox(height: Insets.xl),
                  Wrap(
                    spacing: Insets.md,
                    runSpacing: Insets.md,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton(onPressed: () => context.go('/'), child: const Text('Back to home')),
                      OutlinedButton(onPressed: () => context.go('/docs'), child: const Text('Browse the docs')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
