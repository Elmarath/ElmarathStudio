import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/site_config.dart';
import '../content/content_repository.dart';
import '../pages/about_page.dart';
import '../pages/blog/blog_list_page.dart';
import '../pages/blog/blog_post_page.dart';
import '../pages/cv_page.dart';
import '../pages/docs/doc_route_page.dart';
import '../pages/docs/docs_home_page.dart';
import '../pages/docs/docs_shell.dart';
import '../pages/home/home_page.dart';
import '../pages/markdown_page_view.dart';
import '../pages/not_found_page.dart';
import '../widgets/layout/site_shell.dart';
import 'tab_slide.dart';

/// All routes of the site.
///
/// Every page is wrapped in [SiteShell] (nav bar). Docs pages are additionally
/// wrapped in [DocsShell] (sidebar), which stays put while you move between docs.
///
/// Pressing a nav bar tab slides pages sideways ([TabSlide]); other navigation
/// between top-level pages uses Material's fade-through; moving between doc
/// pages is instant, like a docs site.
GoRouter buildRouter(ContentRepository content) {
  final router = GoRouter(
    // Old links (the previous site, the CV, Fab listings) land on today's pages.
    redirect: (context, state) => content.legacyRoute(state.uri, moved: SiteConfig.movedPages),
    errorBuilder: (context, state) => SiteShell(location: state.uri.path, child: const NotFoundPage()),
    routes: [
      ShellRoute(
        builder: (context, state, child) => SiteShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (context, state) => _page(state, const HomePage())),
          GoRoute(
            path: '/blog',
            pageBuilder: (context, state) =>
                _page(state, BlogListPage(tag: state.uri.queryParameters['tag'])),
            routes: [
              GoRoute(
                path: ':slug',
                pageBuilder: (context, state) =>
                    _page(state, BlogPostPage(slug: state.pathParameters['slug']!)),
              ),
            ],
          ),
          GoRoute(path: '/about', pageBuilder: (context, state) => _page(state, const AboutPage())),
          ShellRoute(
            // One stable page for the whole docs section, so the sidebar keeps its state.
            pageBuilder: (context, state, child) =>
                _page(state, DocsShell(location: state.uri.path, child: child), key: state.pageKey),
            routes: [
              GoRoute(
                path: '/docs',
                pageBuilder: (context, state) => _instant(state, const DocsHomePage()),
                routes: [_docRoute(1)],
              ),
            ],
          ),
          GoRoute(path: '/cv', pageBuilder: (context, state) => _page(state, const CvPage())),
          // Standalone pages from content/pages/<slug>.md, e.g. /privacy-policy.
          GoRoute(
            path: '/:slug',
            pageBuilder: (context, state) =>
                _page(state, MarkdownPageView(slug: state.pathParameters['slug']!)),
          ),
        ],
      ),
    ],
  );
  router.routerDelegate.addListener(
    () => TabSlide.onLocationChanged(router.routerDelegate.currentConfiguration.uri.path),
  );
  return router;
}

/// `/docs/a`, `/docs/a/b`, `/docs/a/b/c`, `/docs/a/b/c/d`: doc ids can be nested folders.
GoRoute _docRoute(int depth) {
  return GoRoute(
    path: ':p$depth',
    pageBuilder: (context, state) {
      final id = [
        for (var i = 1; i <= depth; i++) state.pathParameters['p$i']!,
      ].join('/');
      return _instant(state, DocRoutePage(id: id, fragment: state.uri.fragment));
    },
    routes: [if (depth < 4) _docRoute(depth + 1)],
  );
}

/// go_router keys pages by route pattern (`/docs/:p1/:p2`), so two docs would
/// share one page and its state (scroll position, table of contents). Keying by
/// the location this route matched gives every URL a fresh page, while parent
/// routes in the stack (`/docs`, `/docs/<plugin>`) keep distinct keys.
/// Query changes (`?tag=`) keep the page.
LocalKey _pageKey(GoRouterState state) => ValueKey<String>(state.matchedLocation);

/// A top-level page: slides after a nav tab press, fades through otherwise.
/// Both directions use the same duration so the two pages move in step.
Page<void> _page(GoRouterState state, Widget child, {LocalKey? key}) {
  return CustomTransitionPage<void>(
    key: key ?? _pageKey(state),
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: tabSlideOrFadeThrough,
  );
}

Page<void> _instant(GoRouterState state, Widget child) => NoTransitionPage<void>(key: _pageKey(state), child: child);
