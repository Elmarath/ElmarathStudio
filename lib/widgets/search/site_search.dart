import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';

/// Search over every doc page, blog post and page, built on Material's [SearchAnchor].
class SiteSearch extends StatelessWidget {
  const SiteSearch({super.key, required this.controller});

  final SearchController controller;

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final shortcut = defaultTargetPlatform == TargetPlatform.macOS ? '⌘ K' : 'Ctrl K';
    return SearchAnchor(
      searchController: controller,
      isFullScreen: size.isCompact,
      viewHintText: 'Search docs, posts and pages',
      viewConstraints: const BoxConstraints(minWidth: 420, maxWidth: 640, minHeight: 240, maxHeight: 560),
      builder: (context, controller) => size.isExpanded
          ? _SearchPill(onTap: controller.openView, shortcut: shortcut)
          : IconButton(tooltip: 'Search ($shortcut)', icon: const Icon(Icons.search), onPressed: controller.openView),
      suggestionsBuilder: (viewContext, controller) => _results(context, controller),
    );
  }

  Iterable<Widget> _results(BuildContext context, SearchController controller) {
    final content = context.content;
    final query = controller.text.trim();

    void open(String route) {
      controller.closeView(null);
      controller.clear();
      context.go(route);
    }

    if (query.isEmpty) {
      return [
        const _GroupLabel('Plugins'),
        for (final plugin in content.plugins)
          _ResultTile(
            icon: Icons.extension_outlined,
            title: plugin.label,
            subtitle: plugin.pitch,
            onTap: () => open(plugin.route),
          ),
        if (content.posts.isNotEmpty) const _GroupLabel('Latest posts'),
        for (final post in content.posts.take(3))
          _ResultTile(
            icon: Icons.article_outlined,
            title: post.title,
            subtitle: post.excerpt,
            onTap: () => open(post.route),
          ),
      ];
    }

    final hits = content.search(query);
    if (hits.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(Insets.xl),
          child: Center(child: Text('No results for “$query”', style: Theme.of(context).textTheme.bodyMedium)),
        ),
      ];
    }
    final firstTerm = query.toLowerCase().split(RegExp(r'\s+')).first;
    return [
      for (final (entry, _) in hits)
        _ResultTile(
          icon: switch (entry.kind) {
            SearchKind.doc => Icons.description_outlined,
            SearchKind.post => Icons.article_outlined,
            SearchKind.page => Icons.web_asset_outlined,
          },
          title: entry.title,
          overline: entry.context,
          subtitle: entry.snippet(firstTerm),
          onTap: () => open(entry.route),
        ),
    ];
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap, required this.shortcut});

  final VoidCallback onTap;
  final String shortcut;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Material(
      color: p.surfaceRaised,
      borderRadius: Radii.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.smAll,
        child: Container(
          width: 250,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: Radii.smAll,
            border: Border.all(color: p.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: p.textMuted),
              const SizedBox(width: 8),
              Expanded(child: Text('Search', style: text.bodyMedium?.copyWith(color: p.textMuted))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: p.border),
                ),
                child: Text(shortcut, style: text.labelSmall?.copyWith(letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.md, Insets.md, Insets.md, Insets.xs),
      child: Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.overline,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? overline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: p.textMuted),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overline != null) Text(overline!, style: text.labelSmall?.copyWith(color: p.accent)),
          Text(title, style: text.titleSmall),
        ],
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodySmall),
      onTap: onTap,
    );
  }
}
