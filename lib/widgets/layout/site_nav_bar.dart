import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../config/site_config.dart';
import '../../router/tab_slide.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_themes.dart';
import '../../theme/tokens.dart';
import '../common/links.dart';

bool _isActive(String location, String path) =>
    path == '/' ? location == '/' : location == path || location.startsWith('$path/');

/// Opens a nav tab, sliding the page in from the side the tab sits on
/// relative to the current one.
void _openTab(BuildContext context, String location, NavItem item) {
  if (!isExternalLink(item.path)) {
    final items = SiteConfig.navItems;
    final from = items.indexWhere((i) => _isActive(location, i.path));
    final to = items.indexOf(item);
    TabSlide.prepare(direction: from < 0 ? 1 : (to - from).sign, target: Uri.parse(item.path).path);
  }
  openLink(context, item.path);
}

class SiteNavBar extends StatelessWidget {
  const SiteNavBar({super.key, required this.location, required this.search});

  final String location;
  final Widget search;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = ScreenSize.of(context);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: size.gutter),
      child: Row(
        children: [
          const SiteLogo(),
          if (!size.isCompact) ...[
            const SizedBox(width: Insets.xl),
            for (final item in SiteConfig.navItems)
              _NavLink(
                item: item,
                active: _isActive(location, item.path),
                onTap: () => _openTab(context, location, item),
              ),
          ],
          const Spacer(),
          search,
          const SizedBox(width: Insets.xs),
          const ThemeMenuButton(),
          if (size.isExpanded) ...[
            const SizedBox(width: Insets.sm),
            FilledButton.icon(
              onPressed: () => openLink(context, SiteConfig.storeLink.url),
              icon: Icon(SiteConfig.storeLink.icon, size: 18),
              label: Text(SiteConfig.storeLink.label),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
            ),
          ],
          if (size.isCompact)
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
        ],
      ),
    );
  }
}

class SiteLogo extends StatelessWidget {
  const SiteLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      link: true,
      label: '${SiteConfig.siteName} home',
      child: InkWell(
        onTap: () => context.go('/'),
        borderRadius: Radii.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(SiteConfig.logoAsset, width: 30, height: 30),
              const SizedBox(width: 10),
              Text(
                SiteConfig.siteName.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                      color: p.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({required this.item, required this.active, required this.onTap});

  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final highlighted = widget.active || _hovered;
    return InkWell(
      onTap: widget.onTap,
      onHover: (h) => setState(() => _hovered = h),
      borderRadius: Radii.smAll,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedDefaultTextStyle(
              duration: Motion.fast,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: highlighted ? p.textPrimary : p.textSecondary,
                  ),
              child: Text(widget.item.label),
            ),
            Positioned(
              bottom: -21,
              child: AnimatedContainer(
                duration: Motion.normal,
                curve: Motion.curve,
                height: 2,
                width: widget.active ? 24 : 0,
                color: p.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Palette icon that lists every preset in `app_themes.dart`.
class ThemeMenuButton extends StatelessWidget {
  const ThemeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).theme;
    return PopupMenuButton<AppThemePreset>(
      tooltip: 'Theme',
      icon: const Icon(Icons.palette_outlined),
      position: PopupMenuPosition.under,
      onSelected: controller.select,
      itemBuilder: (context) => [
        for (final preset in controller.presets)
          PopupMenuItem(
            value: preset,
            child: Row(
              children: [
                _Swatch(palette: preset.palette),
                const SizedBox(width: 12),
                Expanded(child: Text(preset.name)),
                if (preset.id == controller.current.id)
                  Icon(Icons.check, size: 18, color: context.palette.accent),
              ],
            ),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.palette.border),
        gradient: SweepGradient(colors: [
          palette.background,
          palette.background,
          palette.accent,
          palette.accent,
        ], stops: const [0, 0.5, 0.5, 1]),
      ),
    );
  }
}

/// Slide-in menu for phones.
class SiteNavDrawer extends StatelessWidget {
  const SiteNavDrawer({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Insets.md),
          children: [
            const Align(alignment: Alignment.centerLeft, child: SiteLogo()),
            const SizedBox(height: Insets.lg),
            for (final item in SiteConfig.navItems)
              ListTile(
                title: Text(item.label),
                selected: _isActive(location, item.path),
                onTap: () {
                  Navigator.of(context).pop();
                  _openTab(context, location, item);
                },
              ),
            const SizedBox(height: Insets.md),
            FilledButton.icon(
              onPressed: () => openLink(context, SiteConfig.storeLink.url),
              icon: Icon(SiteConfig.storeLink.icon, size: 18),
              label: Text(SiteConfig.storeLink.label),
            ),
            const SizedBox(height: Insets.lg),
            Divider(color: p.border),
            const SizedBox(height: Insets.sm),
            Wrap(
              spacing: 4,
              children: [
                for (final s in SiteConfig.socials)
                  IconButton(tooltip: s.label, icon: Icon(s.icon, size: 18), onPressed: () => openLink(context, s.url)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
