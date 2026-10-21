import 'package:flutter/material.dart';

import '../../config/site_config.dart';
import '../../theme/tokens.dart';
import 'site_footer.dart';

/// Centers its child and limits its width, with responsive side padding.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = ContentWidths.page});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = ScreenSize.of(context).gutter;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// A scrolling page: [children] stacked vertically with the footer at the end.
class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.children, this.controller, this.showFooter = true});

  final List<Widget> children;
  final ScrollController? controller;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          if (showFooter) const SiteFooter(),
        ],
      ),
    );
  }
}

/// Sets the browser tab title for a page.
class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // A page that is animating out must not overwrite the new page's title.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return child;
    return Title(
      title: title == null ? '${SiteConfig.siteName} · Unreal Engine tools & devlog' : '$title · ${SiteConfig.siteName}',
      color: Theme.of(context).colorScheme.primary,
      child: child,
    );
  }
}
