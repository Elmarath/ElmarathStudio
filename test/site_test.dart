// Renders the whole site: every route at phone, tablet and desktop sizes,
// every theme, plus the interactive pieces (search, table of contents).
// Any overflow or exception while building a page fails the test.
import 'package:elmarath_dev_website/app.dart';
import 'package:elmarath_dev_website/content/content_repository.dart';
import 'package:elmarath_dev_website/content/text_utils.dart';
import 'package:elmarath_dev_website/pages/about_page.dart';
import 'package:elmarath_dev_website/pages/blog/blog_list_page.dart';
import 'package:elmarath_dev_website/pages/blog/featured_post.dart';
import 'package:elmarath_dev_website/pages/docs/doc_toc.dart';
import 'package:elmarath_dev_website/pages/home/home_page.dart';
import 'package:elmarath_dev_website/theme/app_theme.dart';
import 'package:elmarath_dev_website/theme/app_themes.dart';
import 'package:elmarath_dev_website/theme/theme_controller.dart';
import 'package:elmarath_dev_website/widgets/layout/site_nav_bar.dart';
import 'package:elmarath_dev_website/widgets/layout/site_shell.dart';
import 'package:elmarath_dev_website/widgets/markdown/markdown_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ContentRepository content;

const sizes = {
  'phone': Size(375, 812),
  'tablet': Size(900, 1100),
  'desktop': Size(1440, 900),
};

List<String> allRoutes() => [
      '/',
      '/docs',
      for (final c in content.categories) c.route,
      for (final d in content.docPages) d.route,
      '/blog',
      for (final t in content.tags) '/blog?tag=${slugify(t)}',
      for (final p in content.posts) p.route,
      '/about',
      for (final slug in content.pages.keys) '/$slug',
      '/this-page-does-not-exist',
      '/docs/no-such-plugin/no-such-page',
    ];

Future<ThemeController> pumpSite(WidgetTester tester, Size size) async {
  // Tests have no network, so remote images (YouTube posters, avatars) always fail.
  // That isn't a layout problem, so don't count it.
  final reportError = FlutterError.onError!;
  FlutterError.onError = (details) {
    if (details.exception is! NetworkImageLoadException) reportError(details);
  };
  _restoreErrorHandler = () => FlutterError.onError = reportError;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final theme = await ThemeController.load();
  await tester.pumpWidget(ElmarathApp(content: content, theme: theme));
  await tester.pump();
  return theme;
}

/// Navigates and lets transitions and entrance animations finish.
Future<void> visit(WidgetTester tester, String route) async {
  GoRouter.of(tester.element(find.byType(SiteShell).first)).go(route);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(seconds: 1));
}

void Function()? _restoreErrorHandler;

Future<void> tearDownSite(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  _restoreErrorHandler?.call();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppTheme.useGoogleFonts = false;
    content = await ContentRepository.load(rootBundle);
  });

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('every route renders on $name', (tester) async {
      await pumpSite(tester, size);
      final failures = <String>[];
      for (final route in allRoutes()) {
        await visit(tester, route);
        final error = tester.takeException();
        if (error != null) failures.add('$route: $error');
      }
      expect(failures, isEmpty);
      await tearDownSite(tester);
    });
  }

  testWidgets('every theme renders the main pages', (tester) async {
    final theme = await pumpSite(tester, sizes['desktop']!);
    final failures = <String>[];
    for (final preset in appThemes) {
      theme.select(preset);
      for (final route in ['/', '/docs', content.docPages.first.route, '/blog', content.posts.first.route, '/about']) {
        await visit(tester, route);
        final error = tester.takeException();
        if (error != null) failures.add('${preset.id} $route: $error');
      }
    }
    expect(failures, isEmpty);
    await tearDownSite(tester);
  });

  testWidgets('blog features the pinned post and filters by tag', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    await visit(tester, '/blog');
    final featured = content.posts.firstWhere((p) => p.featured);
    expect(find.descendant(of: find.byType(FeaturedPost), matching: find.text(featured.title)), findsOneWidget);

    // Pick a tag that only some posts have, then check the page shows exactly those.
    final tag = content.tags.firstWhere((t) => content.posts.where((p) => p.tags.contains(t)).length < content.posts.length);
    await tester.tap(find.widgetWithText(ChoiceChip, tag));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    for (final post in content.posts) {
      final shown = find.text(post.title).evaluate().isNotEmpty;
      expect(shown, post.tags.contains(tag), reason: '${post.title} with tag filter "$tag"');
    }
    await tearDownSite(tester);
  });

  testWidgets('nav tabs slide toward their side; other navigation does not slide', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    Finder tab(String label) => find.descendant(of: find.byType(SiteNavBar), matching: find.text(label));
    double leftOf(Type page) => tester.getTopLeft(find.byType(page)).dx;
    // Mid-slide a page is hundreds of pixels off; fade-through only zooms (a few dozen).
    final slid = sizes['desktop']!.width * 0.2;

    // Home → Blog (a tab to the right): Blog comes in from the right.
    await tester.tap(tab('Blog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(leftOf(BlogListPage), greaterThan(slid));
    await tester.pump(const Duration(seconds: 1));
    expect(leftOf(BlogListPage), 0);

    // Blog → Home (a tab to the left): Home comes in from the left.
    await tester.tap(tab('Home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(leftOf(HomePage), lessThan(-slid));
    await tester.pump(const Duration(seconds: 1));

    // Any other navigation (here a link straight to About) keeps the fade.
    GoRouter.of(tester.element(find.byType(SiteShell).first)).go('/about');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(leftOf(AboutPage).abs(), lessThan(slid));
    await tester.pump(const Duration(seconds: 1));
    await tearDownSite(tester);
  });

  testWidgets('Ctrl+K search finds docs and opens them', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField).last, 'socket');
    await tester.pump(const Duration(milliseconds: 300));
    final result = find.widgetWithText(ListTile, 'Setup').first;
    expect(result, findsOneWidget);

    await tester.tap(result);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    final router = GoRouter.of(tester.element(find.byType(SiteShell).first));
    expect(router.routerDelegate.currentConfiguration.uri.path, startsWith('/docs/'));
    await tearDownSite(tester);
  });

  testWidgets('"On this page" jumps to headings and follows scrolling, after switching docs', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    final accent = appThemes.first.palette.accent;
    final setup = content.doc('staged-interaction-system/setup')!;
    final target = setup.parsed.headings.firstWhere((h) => h.text == 'Why use Stages?');

    Finder tocEntry(String text) => find.descendant(of: find.byType(DocToc), matching: find.text(text));
    Finder heading(String text) =>
        find.descendant(of: find.byType(MarkdownView), matching: find.text(text, findRichText: true)).first;
    Color? tocColor(String text) => tester.widget<Text>(tocEntry(text)).style?.color;

    // Open another doc first: this is the path that used to break the table of contents.
    await visit(tester, '/docs/staged-interaction-system/overview');
    await visit(tester, setup.route);

    await tester.tap(tocEntry(target.text));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getTopLeft(heading(target.text)).dy, lessThan(200), reason: 'heading should be scrolled to the top');
    expect(tocColor(target.text), accent);

    // Scroll back to the top by hand: the highlight follows.
    final first = setup.parsed.headings.first;
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 4000));
    await tester.pump(const Duration(seconds: 1));
    expect(tocColor(first.text), accent);
    expect(tocColor(target.text), isNot(accent));
    await tearDownSite(tester);
  });
}
