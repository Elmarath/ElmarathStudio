// Renders the whole site: every route at phone, tablet and desktop sizes,
// every theme, plus the interactive pieces (search, table of contents).
// Any overflow or exception while building a page fails the test.
import 'package:elmarath_dev_website/app.dart';
import 'package:elmarath_dev_website/config/site_config.dart';
import 'package:elmarath_dev_website/content/content_repository.dart';
import 'package:elmarath_dev_website/content/models.dart';
import 'package:elmarath_dev_website/content/text_utils.dart';
import 'package:elmarath_dev_website/pages/about_page.dart';
import 'package:elmarath_dev_website/pages/blog/blog_list_page.dart';
import 'package:elmarath_dev_website/pages/blog/blog_post_page.dart';
import 'package:elmarath_dev_website/pages/blog/featured_post.dart';
import 'package:elmarath_dev_website/pages/docs/doc_toc.dart';
import 'package:elmarath_dev_website/pages/docs/docs_home_page.dart';
import 'package:elmarath_dev_website/pages/docs/docs_sidebar.dart';
import 'package:elmarath_dev_website/pages/home/home_page.dart';
import 'package:elmarath_dev_website/pages/home/sections/hero_section.dart';
import 'package:elmarath_dev_website/pages/home/sections/spotlight_section.dart';
import 'package:elmarath_dev_website/theme/app_theme.dart';
import 'package:elmarath_dev_website/theme/app_themes.dart';
import 'package:elmarath_dev_website/theme/theme_controller.dart';
import 'package:elmarath_dev_website/widgets/cv/cv_viewer.dart';
import 'package:elmarath_dev_website/widgets/layout/site_nav_bar.dart';
import 'package:elmarath_dev_website/widgets/layout/site_shell.dart';
import 'package:elmarath_dev_website/widgets/markdown/markdown_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ContentRepository content;

const sizes = {'phone': Size(375, 812), 'tablet': Size(900, 1100), 'desktop': Size(1440, 900)};

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

/// Drives the home page's plugin carousel.
class Carousel {
  Carousel(this.tester) : items = content.featuredPlugins;

  final WidgetTester tester;
  final List<DocCategory> items;

  Finder text(String text) => find.descendant(of: find.byType(SpotlightSection), matching: find.text(text));

  /// Only the banner shows a plugin's pitch, so it tells which one is up.
  Finder pitch(int i) => text(items[i % items.length].pitch);
  bool showing(int i) => pitch(i).evaluate().isNotEmpty;

  /// Small steps, so timers and the progress bar run the way they do in a browser.
  Future<void> wait(int milliseconds) async {
    for (var t = 0; t < milliseconds; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  static Future<Carousel> open(WidgetTester tester, Size size) async {
    await pumpSite(tester, size);
    final carousel = Carousel(tester);
    await tester.ensureVisible(find.byType(SpotlightSection));
    await carousel.wait(1000);
    expect(carousel.showing(0), isTrue);
    return carousel;
  }
}

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

  testWidgets('blog leads with the pinned (or newest) post and filters by tag', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    await visit(tester, '/blog');
    final featured = content.posts.where((p) => p.featured).firstOrNull ?? content.posts.first;
    expect(find.descendant(of: find.byType(FeaturedPost), matching: find.text(featured.title)), findsOneWidget);

    // Pick a tag that only some posts have, then check the page shows exactly those.
    final tag = content.tags.firstWhere(
      (t) => content.posts.where((p) => p.tags.contains(t)).length < content.posts.length,
      orElse: () => content.tags.first,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, tag));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    for (final post in content.posts) {
      final shown = find.text(post.title).evaluate().isNotEmpty;
      expect(shown, post.tags.contains(tag), reason: '${post.title} with tag filter "$tag"');
    }
    await tearDownSite(tester);
  });

  testWidgets(
    'sections slide in from their tab\'s side, stay as you left them, and pages within one change instantly',
    (tester) async {
      await pumpSite(tester, sizes['desktop']!);
      final width = sizes['desktop']!.width;
      String? title;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
          title = (call.arguments as Map)['label'] as String;
        }
        return null;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(SystemChannels.platform, null));
      Finder tab(String label) => find.descendant(of: find.byType(SiteNavBar), matching: find.text(label));
      double leftOf(Type page) => tester.getTopLeft(find.byType(page)).dx;
      Future<void> midSlide() async {
        await tester.pump(); // builds the new section
        await tester.pump(const Duration(milliseconds: 16)); // the slide starts
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Home → Blog (a tab to the right): Blog comes in from the right.
      await tester.tap(tab('Blog'));
      await midSlide();
      expect(leftOf(BlogListPage), inExclusiveRange(0, width));
      await tester.pump(const Duration(seconds: 1));
      expect(leftOf(BlogListPage), 0);

      // Within a section, pages change instantly.
      GoRouter.of(tester.element(find.byType(SiteShell).first)).go(content.posts.first.route);
      await tester.pump();
      expect(leftOf(BlogPostPage), 0);

      // Blog → Home (a tab to the left): Home comes in from the left, scrolled where it was left.
      await tester.tap(tab('Home'));
      await midSlide();
      expect(leftOf(HomePage), inExclusiveRange(-width, 0));
      await tester.pump(const Duration(seconds: 1));
      final homeScroll = tester.state<ScrollableState>(
        find.descendant(of: find.byType(HomePage), matching: find.byType(Scrollable)).first,
      );
      homeScroll.position.jumpTo(500);
      await tester.pump();
      final homeTitle = title;
      await tester.tap(tab('About'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(title, isNot(homeTitle));
      await tester.tap(tab('Home'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // The same page, not a rebuilt one, and its title is back.
      final homeScrollNow = find.descendant(of: find.byType(HomePage), matching: find.byType(Scrollable)).first;
      expect(tester.state<ScrollableState>(homeScrollNow), same(homeScroll));
      expect(homeScroll.position.pixels, 500);
      expect(title, homeTitle);

      // A tab goes back to where you were in its section; the tab of the
      // section you're in goes to its first page.
      await tester.tap(tab('Blog'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BlogPostPage), findsOneWidget);
      await tester.tap(tab('Blog'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(BlogListPage), findsOneWidget);
      await tearDownSite(tester);
    },
  );

  testWidgets('a mouse wheel glides the page; a trackpad moves it straight away', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    await tester.pump(const Duration(seconds: 1));
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: find.byType(HomePage), matching: find.byType(Scrollable)).first,
    );
    final center = tester.getCenter(find.byType(HomePage));
    Future<void> wheel(double dy, {PointerDeviceKind kind = PointerDeviceKind.mouse}) =>
        tester.sendEventToBinding(PointerScrollEvent(position: center, scrollDelta: Offset(0, dy), kind: kind));

    // One notch: on its way after a moment, there once the glide ends.
    await wheel(100);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(scroll.position.pixels, inExclusiveRange(0, 100));
    await tester.pump(const Duration(milliseconds: 200));
    expect(scroll.position.pixels, 100);

    // Quick notches add up.
    await wheel(100);
    await tester.pump(const Duration(milliseconds: 30));
    await wheel(100);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(scroll.position.pixels, 300);

    // A trackpad already sends small, smooth steps: no glide.
    await wheel(40, kind: PointerDeviceKind.trackpad);
    await tester.pump();
    expect(scroll.position.pixels, 340);
    await tearDownSite(tester);
  });

  testWidgets('the home page counts open the docs and the blog', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    Finder count(String label) => find.descendant(of: find.byType(HeroSection), matching: find.text(label));
    final posts = content.posts.length == 1 ? 'BLOG POST' : 'BLOG POSTS';
    expect(
      find.descendant(of: find.byType(HeroSection), matching: find.text('${content.plugins.length}')),
      findsOneWidget,
    );

    // The counts slide in last: their animation starts on a timer, a frame after
    // it fires. Until it has run they sit below where taps are looked for.
    Future<void> tapCount(String label) async {
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 600));
      }
      await tester.ensureVisible(count(label));
      await tester.pump();
      await tester.tap(count(label));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    await tapCount('PLUGINS');
    expect(find.byType(DocsHomePage), findsOneWidget);

    await visit(tester, '/');
    await tapCount(posts);
    expect(find.byType(BlogListPage), findsOneWidget);
    await tearDownSite(tester);
  });

  testWidgets('the plugin carousel plays on until it is paused', (tester) async {
    final c = await Carousel.open(tester, sizes['desktop']!);

    // Resting the mouse on it doesn't stop it.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(c.pitch(0)));
    await c.wait(7000);
    expect(c.showing(1), isTrue);

    // A tab shows its plugin, which gets the usual 7 s.
    await tester.tap(c.text(c.items[3].label));
    await c.wait(7600);
    expect(c.showing(4), isTrue);

    // A narrower window swaps the list for dots and stays on the same plugin.
    tester.view.physicalSize = sizes['tablet']!;
    await c.wait(500);
    expect(c.showing(4), isTrue);
    tester.view.physicalSize = sizes['desktop']!;
    await c.wait(500);
    expect(c.showing(4), isTrue);

    await tester.tap(find.byTooltip('Pause'));
    await c.wait(20000);
    expect(c.showing(4), isTrue);
    await tester.tap(find.byTooltip('Play'));
    await c.wait(7500);
    expect(c.showing(5), isTrue);

    // Next to the list it doesn't move with a swipe.
    await tester.fling(c.pitch(5), const Offset(-500, 0), 1000);
    await c.wait(1000);
    expect(c.showing(5), isTrue);
    await mouse.removePointer();
    await tearDownSite(tester);
  });

  testWidgets('on small screens the plugin carousel has previews below and follows a swipe or a mouse drag', (
    tester,
  ) async {
    final c = await Carousel.open(tester, sizes['phone']!);
    double pageScroll() =>
        tester
            .state<ScrollableState>(find.ancestor(of: find.byType(SpotlightSection), matching: find.byType(Scrollable)))
            .position
            .pixels;

    await tester.fling(c.pitch(0), const Offset(-200, 0), 1000);
    await c.wait(1000);
    expect(c.showing(1), isTrue);
    expect(c.showing(0), isFalse);

    // Back twice: past the first plugin round to the last one.
    await tester.fling(c.pitch(1), const Offset(200, 0), 1000);
    await c.wait(1000);
    await tester.fling(c.pitch(0), const Offset(200, 0), 1000);
    await c.wait(1000);
    expect(c.showing(-1), isTrue);

    await tester.drag(c.pitch(-1), const Offset(-250, 0), kind: PointerDeviceKind.mouse);
    await c.wait(1000);
    expect(c.showing(0), isTrue);

    // The wheel (or a trackpad) scrolls the page, even with a little sideways movement in it.
    final before = pageScroll();
    await tester.sendEventToBinding(
      PointerScrollEvent(position: tester.getCenter(c.pitch(0)), scrollDelta: const Offset(4, 120)),
    );
    await c.wait(1000);
    expect(pageScroll(), greaterThan(before));
    expect(c.showing(0), isTrue);

    // Below the banner, a preview of every plugin, together exactly as wide as the banner.
    final banner = tester.getRect(find.byType(PageView));
    expect(tester.getRect(find.byTooltip(c.items.first.label)).left, banner.left);
    expect(tester.getRect(find.byTooltip(c.items.last.label)).right, banner.right);
    await tester.ensureVisible(find.byTooltip(c.items[2].label));
    await tester.tap(find.byTooltip(c.items[2].label));
    await c.wait(1000);
    expect(c.showing(2), isTrue);
    await tearDownSite(tester);
  });

  testWidgets('the name chip on the home page opens About', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    await tester.tap(find.descendant(of: find.byType(HeroSection), matching: find.text(SiteConfig.ownerName)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AboutPage), findsOneWidget);
    await tearDownSite(tester);
  });

  testWidgets('"View CV" on the About page opens the CV window', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    await visit(tester, '/about');
    await tester.tap(find.text('View CV'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.descendant(of: find.byType(Dialog), matching: find.byType(CvViewer)), findsOneWidget);
    expect(find.text('Curriculum Vitae'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CvViewer), findsNothing);
    await tearDownSite(tester);
  });

  testWidgets('expanding a docs folder in the sidebar opens its first page', (tester) async {
    await pumpSite(tester, sizes['desktop']!);
    String location() =>
        GoRouter.of(tester.element(find.byType(SiteShell).first)).routerDelegate.currentConfiguration.uri.path;
    Finder folder(String label) => find.descendant(of: find.byType(DocsSidebar), matching: find.text(label));
    final plugin = content.plugins.firstWhere((c) => c.allPages.length > 1);
    final first = plugin.allPages.first;
    final second = plugin.allPages.elementAt(1);

    await visit(tester, '/docs');
    await tester.tap(folder(plugin.label));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(location(), first.route);

    // Collapsing doesn't navigate.
    await tester.tap(folder(plugin.label));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(location(), first.route);

    // Expanding the folder you're already reading in keeps you on your page.
    await visit(tester, second.route);
    await tester.tap(folder(plugin.label)); // collapse
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(folder(plugin.label)); // expand again
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(location(), second.route);
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
