// Writes a plain HTML copy of every page into build/web, plus sitemap.xml, so
// search engines can read the site: the app itself draws its text on a canvas.
//
//   flutter build web --release
//   flutter test tool/prerender_test.dart
//
// Each copy is the app's index.html with the page's own title, description and
// canonical address, and its text as ordinary HTML behind the app (which covers
// it). Visitors get the app as usual. It runs as a test only to load the
// content exactly as the app does; `flutter test` alone doesn't run it.
// tool/netlify_build.sh runs it after each build.
import 'dart:convert';
import 'dart:io';

import 'package:elmarath_dev_website/config/site_config.dart';
import 'package:elmarath_dev_website/content/content_repository.dart';
import 'package:elmarath_dev_website/content/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

const _out = 'build/web';

void main() {
  test('write HTML copies of every page and the sitemap', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final content = await ContentRepository.load(rootBundle);

    // The untouched app page: kept as app.html for addresses without a copy
    // (see web/_redirects), and the template for every copy.
    final app = File('$_out/app.html');
    if (!app.existsSync()) File('$_out/index.html').copySync(app.path);
    final template = app.readAsStringSync();

    final pages = <String, _Page>{};
    void add(String route, String title, String description, String body) =>
        pages[route] = _Page(title, description, body);
    String link(String route, String text) => '<a href="$route">${_escape(text)}</a>';
    String list(Iterable<String> items) => '<ul>${items.map((i) => '<li>$i</li>').join()}</ul>';

    final plugins = list([
      for (final p in content.plugins) '${link(p.route, p.label)}: ${_escape(p.pitch)}',
    ]);
    final posts = list([
      for (final p in content.posts) '${link(p.route, p.title)}: ${_escape(p.excerpt)}',
    ]);

    add(
      '/',
      '${SiteConfig.siteName} · Unreal Engine tools & devlog',
      SiteConfig.heroSubtitle,
      '<h1>${_escape(SiteConfig.heroTitle.replaceAll('\n', ' '))}</h1>'
          '<p>${_escape(SiteConfig.heroSubtitle)}</p><h2>Unreal Engine plugins</h2>$plugins<h2>Blog</h2>$posts',
    );
    add(
      '/docs',
      'Documentation · ${SiteConfig.siteName}',
      'Documentation for ${SiteConfig.siteName}\'s Unreal Engine plugins: '
          '${content.plugins.map((p) => p.label).join(', ')}.',
      '<h1>Documentation</h1>$plugins',
    );
    for (final category in content.categories) {
      final inside = content.docPages.where((d) => _isIn(d, category));
      add(
        category.route,
        '${category.label} · ${SiteConfig.siteName} docs',
        category.pitch.isNotEmpty ? category.pitch : '${category.label} documentation.',
        '<h1>${_escape(category.label)}</h1><p>${_escape(category.pitch)}</p>'
            '${list([for (final d in inside) link(d.route, d.title)])}',
      );
    }
    for (final doc in content.docPages) {
      final plugin = doc.rootCategory;
      final html = _html(content, doc.body, doc.assetPath);
      final siblings = plugin == null ? <DocPage>[] : content.docPages.where((d) => _isIn(d, plugin));
      add(
        doc.route,
        [doc.title, if (plugin != null && !doc.title.contains(plugin.label)) plugin.label, SiteConfig.siteName].join(' · '),
        // The plugin's summary first: it's what people search for.
        doc.description ?? _excerpt('${_escape(plugin?.pitch ?? '')} $html', fallback: doc.title),
        '${_heading(doc.title, doc.body)}$html'
            '${plugin == null ? '' : '<h2>${link(plugin.route, plugin.label)}</h2>${list([for (final d in siblings) link(d.route, d.title)])}'}',
      );
    }
    add('/blog', 'Blog · ${SiteConfig.siteName}', 'Devlogs and articles by ${SiteConfig.ownerName}.', '<h1>Blog</h1>$posts');
    for (final post in content.posts) {
      final html = _html(content, post.body, post.assetPath);
      add(post.route, '${post.title} · ${SiteConfig.siteName}', post.excerpt, '${_heading(post.title, post.body)}$html');
    }
    for (final MapEntry(key: slug, value: page) in content.pages.entries) {
      final html = _html(content, page.body, page.assetPath);
      add(
        '/$slug',
        '${page.title} · ${SiteConfig.siteName}',
        page.description ?? _excerpt(html, fallback: page.title),
        '${_heading(page.title, page.body)}$html',
      );
    }

    for (final MapEntry(key: route, value: page) in pages.entries) {
      final file = File(route == '/' ? '$_out/index.html' : '$_out$route.html');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(_fill(template, route, page));
    }
    File('$_out/sitemap.xml').writeAsStringSync(
      '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
      '${pages.keys.map((r) => '  <url><loc>${SiteConfig.siteUrl}${r == '/' ? '/' : r}</loc></url>\n').join()}'
      '</urlset>\n',
    );
    stdout.writeln('Wrote ${pages.length} pages and sitemap.xml to $_out');
  });
}

class _Page {
  _Page(this.title, this.description, this.body);
  final String title;
  final String description;
  final String body;
}

/// The app's page with this page's title, description, address and text.
String _fill(String template, String route, _Page page) {
  final url = '${SiteConfig.siteUrl}${route == '/' ? '/' : route}';
  final title = _escape(page.title), description = _escape(page.description);
  String meta(String html, String attribute, String name, String value) => html.replaceFirst(
    RegExp('<meta $attribute="$name" content="[^"]*">'),
    '<meta $attribute="$name" content="$value">',
  );
  var html = template.replaceFirst(RegExp(r'<title>[^<]*</title>'), '<title>$title</title>');
  html = meta(html, 'name', 'description', description);
  html = meta(html, 'property', 'og:title', title);
  html = meta(html, 'property', 'og:description', description);
  html = meta(html, 'property', 'og:url', url);
  html = html.replaceFirst('</head>', '  <link rel="canonical" href="$url">\n</head>');
  final nav = [
    '<a href="/">${SiteConfig.siteName}</a>',
    for (final item in SiteConfig.navItems) '<a href="${item.path}">${_escape(item.label)}</a>',
  ].join(' · ');
  return html.replaceFirst('<body>', '<body>\n  <main id="page-text"><nav>$nav</nav><article>${page.body}</article></main>');
}

/// Markdown as HTML for search engines: links point at the site's routes, and
/// embeds and images are left out (they'd load behind the app for nothing).
String _html(ContentRepository content, String markdown, String sourcePath) {
  // The site's own block commands (`::youtube <id>`, `:::tip`) are left out.
  markdown = markdown.replaceAll(RegExp(r'^[ \t]*::.*$', multiLine: true), '');
  var html = md.markdownToHtml(markdown, extensionSet: md.ExtensionSet.gitHubWeb);
  html = html.replaceAll(RegExp(r'<(script|style|iframe|video|object)\b[^>]*>.*?</\1>', dotAll: true), '');
  html = html.replaceAll(RegExp(r'<(img|iframe|video|source|embed|link)\b[^>]*>'), '');
  return html.replaceAllMapped(RegExp(r'href="([^"]*)"'), (m) {
    final route = content.internalRoute(m[1]!, sourcePath: sourcePath);
    return 'href="${route ?? m[1]}"';
  });
}

/// A title heading, unless the Markdown starts with its own.
String _heading(String title, String markdown) =>
    markdown.trimLeft().startsWith('# ') ? '' : '<h1>${_escape(title)}</h1>';

/// The start of the page's text, for its description.
String _excerpt(String html, {required String fallback}) {
  final text = html
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      // Back to plain text: it's escaped again where it's used.
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .trim();
  if (text.isEmpty) return fallback;
  if (text.length <= 155) return text;
  final cut = text.substring(0, 155);
  return '${cut.substring(0, cut.lastIndexOf(' '))}…';
}

bool _isIn(DocPage doc, DocCategory category) {
  for (var c = doc.category; c != null; c = c.parent) {
    if (c == category) return true;
  }
  return false;
}

String _escape(String text) => const HtmlEscape().convert(text);
