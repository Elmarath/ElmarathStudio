import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

/// A vertical scroll view whose content is drawn once and then only moved while
/// scrolling. A plain [SingleChildScrollView] redraws all of its content on
/// every scroll frame, which makes long pages stutter on the web.
class ContentScrollView extends StatelessWidget {
  const ContentScrollView({super.key, required this.child, this.controller});

  final Widget child;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(controller: controller, child: RepaintBoundary(child: child));
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
    return ContentScrollView(
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
    // Only the page showing sets the title: not one on its way out, nor one in
    // a section that's hidden. A section coming back into view rebuilds this
    // (TickerMode turns on), which puts its title back. The page itself always
    // stays in the same place in the tree, so it's never rebuilt for this.
    if ((ModalRoute.of(context)?.isCurrent ?? true) && TickerMode.of(context)) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: title == null ? '${SiteConfig.siteName} · Unreal Engine tools & devlog' : '$title · ${SiteConfig.siteName}',
          primaryColor: Theme.of(context).colorScheme.primary.toARGB32(),
        ),
      );
    }
    return child;
  }
}
