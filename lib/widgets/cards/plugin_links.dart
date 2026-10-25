import 'package:flutter/material.dart';
import '../common/brand_icons.dart';

import '../../content/text_utils.dart';
import '../../theme/tokens.dart';
import '../common/links.dart';

/// Store / repository buttons for a plugin, from the `links:` in its `_category_.yaml`.
/// Rendered by the `::plugin-links` directive in Markdown.
class PluginLinks extends StatelessWidget {
  const PluginLinks({super.key, required this.links});

  final Map<String, String> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final MapEntry(:key, :value) in links.entries)
          switch (key) {
            'fab' => FilledButton.icon(
                onPressed: () => openLink(context, value),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Text('Get it on Fab'),
              ),
            'github' => OutlinedButton.icon(
                onPressed: () => openLink(context, value),
                icon: const Icon(BrandIcons.github, size: 16),
                label: const Text('GitHub'),
              ),
            'youtube' => OutlinedButton.icon(
                onPressed: () => openLink(context, value),
                icon: const Icon(BrandIcons.youtube, size: 16),
                label: const Text('YouTube'),
              ),
            _ => OutlinedButton.icon(
                onPressed: () => openLink(context, value),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(humanize(key)),
              ),
          },
      ],
    );
  }
}
