import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../content/models.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_image.dart';

/// The docs navigation tree, generated from the folders in `content/docs/`.
class DocsSidebar extends StatelessWidget {
  const DocsSidebar({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final root = context.content.docsRoot;
    return ListView(
      key: const PageStorageKey('docs-sidebar'),
      padding: const EdgeInsets.symmetric(horizontal: Insets.sm + 4, vertical: Insets.lg),
      children: [
        _SidebarLink(label: 'Overview', route: '/docs', location: location, depth: 0, icon: Icons.grid_view_rounded),
        const SizedBox(height: Insets.sm),
        for (final node in root.children) _node(node, 0),
      ],
    );
  }

  Widget _node(DocNode node, int depth) => switch (node) {
        DocPage() => _SidebarLink(label: node.label, route: node.route, location: location, depth: depth),
        DocCategory() => _SidebarCategory(
            category: node,
            location: location,
            depth: depth,
            children: [
              if (node.indexPage != null)
                _SidebarLink(label: 'Overview', route: node.route, location: location, depth: depth + 1),
              for (final child in node.children) _node(child, depth + 1),
            ],
          ),
      };
}

class _SidebarCategory extends StatefulWidget {
  const _SidebarCategory({
    required this.category,
    required this.location,
    required this.depth,
    required this.children,
  });

  final DocCategory category;
  final String location;
  final int depth;
  final List<Widget> children;

  @override
  State<_SidebarCategory> createState() => _SidebarCategoryState();
}

class _SidebarCategoryState extends State<_SidebarCategory> {
  final _controller = ExpansionTileController();

  bool get _containsActive => widget.category.containsRoute(widget.location);

  @override
  void didUpdateWidget(_SidebarCategory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Opening a doc from elsewhere (search, a link) expands its folder.
    if (_containsActive && !oldWidget.category.containsRoute(oldWidget.location)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_controller.isExpanded) _controller.expand();
      });
    }
  }

  /// Expanding a folder opens its first page, unless you're already reading
  /// one of its pages. Collapsing just collapses.
  void _onExpansionChanged(bool expanded) {
    if (!expanded || _containsActive) return;
    final first = widget.category.allPages.firstOrNull;
    if (first != null) context.go(first.route);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final topLevel = widget.depth == 0;
    final thumbnail = widget.category.thumbnail;
    return ExpansionTile(
      key: PageStorageKey('docs-${widget.category.id}'),
      controller: _controller,
      initiallyExpanded: _containsActive,
      onExpansionChanged: _onExpansionChanged,
      dense: true,
      visualDensity: VisualDensity.compact,
      tilePadding: EdgeInsets.only(left: 12.0 + widget.depth * 12, right: 4),
      childrenPadding: EdgeInsets.zero,
      minTileHeight: 40,
      leading: topLevel && thumbnail != null
          ? ClipRRect(borderRadius: BorderRadius.circular(5), child: AppImage(thumbnail, width: 22, height: 22))
          : null,
      title: Text(
        widget.category.label,
        style: (topLevel ? text.titleSmall : text.bodyMedium)?.copyWith(
          color: _containsActive ? p.textPrimary : (topLevel ? p.textPrimary : p.textSecondary),
          fontWeight: topLevel ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
      children: widget.children,
    );
  }
}

class _SidebarLink extends StatelessWidget {
  const _SidebarLink({
    required this.label,
    required this.route,
    required this.location,
    required this.depth,
    this.icon,
  });

  final String label;
  final String route;
  final String location;
  final int depth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final active = location == route;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active ? p.accent.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: Radii.smAll,
        child: InkWell(
          borderRadius: Radii.smAll,
          onTap: () {
            // On phones the sidebar is a drawer: close it so the page is visible.
            Scaffold.maybeOf(context)?.closeDrawer();
            context.go(route);
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(12.0 + depth * 12 + (depth > 0 ? 8 : 0), 9, 10, 9),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: active ? p.accent : p.textSecondary),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: (depth == 0 ? text.titleSmall : text.bodyMedium)?.copyWith(
                      color: active ? p.accent : (depth == 0 ? p.textPrimary : p.textSecondary),
                      fontWeight: active || depth == 0 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
