import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/about_page.dart';
import '../pages/blog/blog_list_page.dart';
import '../pages/blog/blog_post_page.dart';
import '../pages/docs/doc_route_page.dart';
import '../pages/docs/docs_home_page.dart';
import '../pages/docs/docs_shell.dart';
import '../pages/home/home_page.dart';
import '../pages/markdown_page_view.dart';
import '../pages/not_found_page.dart';
import '../widgets/layout/site_shell.dart';

/// All routes of the site.
///
/// Every page is wrapped in [SiteShell] (nav bar). Docs pages are additionally
/// wrapped in [DocsShell] (sidebar), which stays put while you move between docs.
GoRouter buildRouter() {
  return GoRouter(
    errorBuilder: (context, state) => SiteShell(location: state.uri.path, child: const NotFoundPage()),
    routes: [
      ShellRoute(
        builder: (context, state, child) => SiteShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', pageBuilder: (context, state) => _fade(state, const HomePage())),
          GoRoute(
            path: '/blog',
            pageBuilder: (context, state) =>
                _fade(state, BlogListPage(tag: state.uri.queryParameters['tag'])),
            routes: [
              GoRoute(
                path: ':slug',
                pageBuilder: (context, state) =>
                    _fade(state, BlogPostPage(slug: state.pathParameters['slug']!)),
              ),
            ],
          ),
          GoRoute(path: '/about', pageBuilder: (context, state) => _fade(state, const AboutPage())),
          ShellRoute(
            builder: (context, state, child) => DocsShell(location: state.uri.path, child: child),
            routes: [
              GoRoute(
                path: '/docs',
                pageBuilder: (context, state) => _instant(state, const DocsHomePage()),
                routes: [_docRoute(1)],
              ),
            ],
          ),
          // Standalone pages from content/pages/<slug>.md, e.g. /privacy-policy.
          GoRoute(
            path: '/:slug',
            pageBuilder: (context, state) =>
                _fade(state, MarkdownPageView(slug: state.pathParameters['slug']!)),
          ),
        ],
      ),
    ],
  );
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

Page<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: _pageKey(state),
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

Page<void> _instant(GoRouterState state, Widget child) => NoTransitionPage<void>(key: _pageKey(state), child: child);
