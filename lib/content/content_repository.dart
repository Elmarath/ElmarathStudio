import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'text_utils.dart';

/// Loads every Markdown file under `content/` once at startup.
///
/// * `content/blog/*.md` or `content/blog/<folder>/index.md` → blog posts
/// * `content/docs/**`                                          → documentation tree
/// * `content/pages/*.md`                                       → standalone pages (`/about`, …)
class ContentRepository {
  ContentRepository._({required this.posts, required this.docsRoot, required this.pages}) {
    docPages = docsRoot.allPages.toList();
    for (final page in docPages) {
      _docsById[page.id] = page;
    }
    void indexCategories(DocCategory c) {
      for (final child in c.children) {
        if (child is DocCategory) {
          _categoriesById[child.id] = child;
          indexCategories(child);
        }
      }
    }

    indexCategories(docsRoot);
  }

  final List<BlogPost> posts;
  final DocCategory docsRoot;
  final Map<String, MarkdownPage> pages;

  /// All doc pages in sidebar order (used for previous/next links).
  late final List<DocPage> docPages;
  final Map<String, DocPage> _docsById = {};
  final Map<String, DocCategory> _categoriesById = {};

  List<DocCategory> get plugins => docsRoot.children.whereType<DocCategory>().toList();
  /// The home page carousel: every plugin, those with `featured: true` first.
  List<DocCategory> get spotlightPlugins => [
    ...plugins.where((c) => c.featured),
    ...plugins.where((c) => !c.featured),
  ];

  DocPage? doc(String id) => _docsById[id];
  DocCategory? category(String id) => _categoriesById[id];
  Iterable<DocCategory> get categories => _categoriesById.values;

  BlogPost? post(String slug) => posts.where((p) => p.slug == slug).firstOrNull;

  List<String> get tags {
    final counts = <String, int>{};
    for (final p in posts) {
      for (final t in p.tags) {
        counts.update(t, (c) => c + 1, ifAbsent: () => 1);
      }
    }
    return counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }

  late final List<SearchEntry> searchIndex = [
    for (final d in docPages)
      SearchEntry(
        kind: SearchKind.doc,
        title: d.title,
        context: d.rootCategory?.label ?? 'Docs',
        route: d.route,
        headings: d.parsed.headings.map((h) => h.text).join(' · '),
        text: plainText(d.body),
      ),
    for (final p in posts)
      SearchEntry(
        kind: SearchKind.post,
        title: p.title,
        context: 'Blog · ${formatDate(p.date)}',
        route: p.route,
        headings: p.tags.join(' '),
        text: plainText(p.body),
      ),
    for (final p in pages.values)
      SearchEntry(
        kind: SearchKind.page,
        title: p.title,
        context: 'Page',
        route: '/${p.slug}',
        headings: '',
        text: plainText(p.body),
      ),
  ];

  List<(SearchEntry, int)> search(String query, {int limit = 20}) {
    final terms = query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty) return const [];
    final hits = <(SearchEntry, int)>[];
    for (final e in searchIndex) {
      final s = e.score(terms);
      if (s > 0) hits.add((e, s));
    }
    hits.sort((a, b) => b.$2.compareTo(a.$2));
    return hits.take(limit).toList();
  }

  /// Every route on the site, for telling real pages from old addresses.
  late final Set<String> _routes = {
    '/',
    '/docs',
    '/blog',
    '/about',
    '/cv',
    for (final d in docPages) d.route,
    for (final c in categories) c.route,
    for (final p in posts) p.route,
    for (final slug in pages.keys) '/$slug',
  };

  /// Whether [path] is a page on this site.
  bool isRoute(String path) => _routes.contains(path);

  late final Map<String, String> _routesByLooseKey = {for (final r in _routes) _looseKey(r): r};

  /// Old folder name (slug) → the folder's current name, from `aliases:` in `_category_.yaml`.
  late final Map<String, String> _folderAliases = {
    for (final c in categories)
      for (final alias in c.aliases) slugify(alias): c.id.split('/').last,
  };

  /// Letters and digits only, lowercased: `/docs/Decide%20Montages` and
  /// `/docs/decide-montages` look the same.
  static String _looseKey(String path) {
    var s = path;
    try {
      s = Uri.decodeFull(s);
    } catch (_) {}
    return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Where an old address (e.g. from the previous Docusaurus site) lives now,
  /// or null when [uri] is already a page here or nothing matches.
  ///
  /// [moved] lists pages that moved somewhere else entirely. Everything else is
  /// matched loosely: letter case, spaces and dashes, `.html` endings, Docusaurus
  /// `/docs/category/...` overviews, `/blog/tags/...` and renamed folders.
  String? legacyRoute(Uri uri, {Map<String, String> moved = const {}}) {
    var path = uri.path;
    try {
      path = Uri.decodeFull(path);
    } catch (_) {}
    path = path.replaceFirst(RegExp(r'\.html$'), '');
    if (path.length > 1) path = path.replaceFirst(RegExp(r'/+$'), '');
    if (_routes.contains(path)) return null;

    final fragment = uri.fragment.isEmpty ? '' : '#${uri.fragment}';
    final key = _looseKey(path);
    for (final entry in moved.entries) {
      if (_looseKey(entry.key) == key) return entry.value;
    }

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    final section = segments.firstOrNull?.toLowerCase();
    if (section == 'blog' && segments.length >= 3 && segments[1].toLowerCase() == 'tags') {
      return '/blog?tag=${Uri.encodeQueryComponent(slugify(segments[2]))}';
    }
    if (section == 'docs' && segments.length == 3 && segments[1].toLowerCase() == 'category') {
      final wanted = slugify(segments[2]);
      final match = categories.where((c) => slugify(c.label) == wanted || c.id.split('/').last == wanted).firstOrNull;
      if (match != null) return match.route;
    }
    final renamed = [for (final s in segments) _folderAliases[slugify(s)] ?? s];
    final match = _routesByLooseKey[_looseKey('/${renamed.join('/')}')];
    return match == null ? null : '$match$fragment';
  }

  /// Resolves an image path written in Markdown, relative to the file it's in.
  ///
  /// Returns a URL unchanged, `/assets/x.png` as the asset `assets/x.png`,
  /// other absolute paths under `content/`, and relative paths next to the file.
  static String resolveAsset(String sourcePath, String src) {
    final s = src.trim();
    if (RegExp(r'^(https?|data):', caseSensitive: false).hasMatch(s)) return s;
    if (s.startsWith('/assets/')) return s.substring(1);
    if (s.startsWith('/')) return 'content$s';
    try {
      return Uri.decodeFull(Uri(path: sourcePath).resolve(s).path);
    } catch (_) {
      return '${sourcePath.substring(0, sourcePath.lastIndexOf('/'))}/$s';
    }
  }

  /// Maps a Markdown link to a route on this site, or null if it's external.
  ///
  /// Understands site routes (`/docs/intro`), Docusaurus-style paths
  /// (`/docs/Easy-Ability-Set-System/AbilitySets`) and relative file links
  /// (`./Setup.md`, `../other-plugin/overview.md`).
  String? internalRoute(String href, {required String sourcePath}) {
    var link = href.trim();
    if (link.isEmpty || RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(link)) {
      return null;
    }
    var fragment = '';
    final hash = link.indexOf('#');
    if (hash >= 0) {
      fragment = link.substring(hash);
      link = link.substring(0, hash);
    }
    if (link.isEmpty) return fragment;

    if (!link.startsWith('/')) {
      final asset = resolveAsset(sourcePath, link);
      link =
          asset.startsWith('content/pages/')
              ? asset.substring('content/pages'.length)
              : asset.substring('content'.length);
    }

    final segments = link.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return '/$fragment';
    final section = segments.first.toLowerCase();
    final rest = segments.skip(1).map(slugify).where((s) => s.isNotEmpty && s != 'index').toList();
    if (section == 'docs' || section == 'blog') {
      if (section == 'blog' && rest.isNotEmpty) {
        final post = posts.where((p) => p.slug == rest.last || p.assetPath.contains(segments.last)).firstOrNull;
        if (post != null) return '${post.route}$fragment';
      }
      return '/${[section, ...rest].join('/')}$fragment';
    }
    return '/${segments.map(slugify).join('/')}$fragment';
  }

  static Future<ContentRepository> load(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final assets = manifest.listAssets().where((a) => a.startsWith('content/')).toList()..sort();
    final textAssets = assets.where(_isTextFile).toList();
    final texts = await Future.wait(textAssets.map(bundle.loadString));
    final files = Map.fromIterables(textAssets, texts);

    final authors = _parseAuthors(files);
    return ContentRepository._(
      posts: _parsePosts(files, authors),
      docsRoot: _parseDocs(files),
      pages: _parsePages(files),
    );
  }

  static bool _isTextFile(String path) =>
      path.endsWith('.md') ||
      path.endsWith('.mdx') ||
      _isCategoryFile(path) ||
      RegExp(r'^content/blog/authors\.ya?ml$').hasMatch(path);

  static bool _isCategoryFile(String path) => RegExp(r'/_category_\.(json|ya?ml)$').hasMatch(path);

  static String _dirOf(String path) => path.substring(0, path.lastIndexOf('/'));
  static String _nameOf(String path) => path.substring(path.lastIndexOf('/') + 1);

  static Map<String, Author> _parseAuthors(Map<String, String> files) {
    final entry = files.entries.where((e) => e.key.contains('content/blog/authors.')).firstOrNull;
    if (entry == null) return {};
    final data = parseYamlMap(entry.value);
    return {
      for (final e in data.entries)
        if (e.value is Map)
          e.key: Author(
            id: e.key,
            name: (e.value['name'] ?? e.key).toString(),
            title: e.value['title']?.toString(),
            url: e.value['url']?.toString(),
            imageUrl: e.value['image_url']?.toString(),
          ),
    };
  }

  static List<BlogPost> _parsePosts(Map<String, String> files, Map<String, Author> authors) {
    final posts = <BlogPost>[];
    for (final entry in files.entries) {
      final path = entry.key;
      if (!path.startsWith('content/blog/') || !(path.endsWith('.md') || path.endsWith('.mdx'))) continue;
      final relative = path.substring('content/blog/'.length).split('/');
      final String baseName;
      if (relative.length == 1) {
        baseName = relative.first.replaceAll(RegExp(r'\.mdx?$'), '');
      } else if (relative.length == 2 && RegExp(r'^index\.mdx?$').hasMatch(relative.last)) {
        baseName = relative.first;
      } else {
        continue;
      }

      final fm = FrontMatterDocument.parse(entry.value);
      final draft = fm.flag('draft');
      if (draft && !kDebugMode) continue;

      final nameMatch = RegExp(r'^(\d{4}-\d{2}-\d{2})[-_]?(.*)$').firstMatch(baseName);
      final date =
          DateTime.tryParse(fm.string('date') ?? '') ?? DateTime.tryParse(nameMatch?.group(1) ?? '') ?? DateTime(2000);
      final (h1, body) = _extractTitle(fm.body);
      final title = fm.string('title') ?? h1 ?? humanize(nameMatch?.group(2) ?? baseName);
      final slug = slugify(
        fm.string('slug') ?? (nameMatch?.group(2)?.isNotEmpty == true ? nameMatch!.group(2)! : title),
      );

      var excerpt = fm.string('description');
      if (excerpt == null) {
        final cut = body.indexOf('<!-- truncate -->');
        final intro = cut >= 0 ? body.substring(0, cut) : body.trim().split(RegExp(r'\n\s*\n')).first;
        excerpt = plainText(intro);
      }
      if (excerpt.length > 220) excerpt = '${excerpt.substring(0, 217).trimRight()}…';

      final words = plainText(body).split(' ').length;
      final image = fm.string('image');
      posts.add(
        BlogPost(
          slug: slug,
          title: title,
          date: date,
          authors: fm.list('authors').map((id) => authors[id] ?? Author(id: id, name: id)).toList(),
          tags: fm.list('tags'),
          excerpt: excerpt,
          body: body,
          assetPath: path,
          image: image == null ? null : resolveAsset(path, image),
          draft: draft,
          featured: fm.flag('featured'),
          readingMinutes: (words / 220).ceil().clamp(1, 999),
        ),
      );
    }
    posts.sort((a, b) => b.date.compareTo(a.date));
    return posts;
  }

  static DocCategory _parseDocs(Map<String, String> files) {
    const rootDir = 'content/docs';
    final root = DocCategory(id: '', label: 'Docs', position: 0, assetDir: rootDir);
    final byDir = <String, DocCategory>{rootDir: root};
    final meta = <String, Map<String, dynamic>>{
      for (final e in files.entries)
        if (e.key.startsWith('$rootDir/') && _isCategoryFile(e.key)) _dirOf(e.key): parseYamlMap(e.value),
    };

    DocCategory categoryFor(String dir) {
      final existing = byDir[dir];
      if (existing != null) return existing;
      final parent = categoryFor(_dirOf(dir));
      final folder = _nameOf(dir);
      final m = meta[dir] ?? const {};
      final link = m['link'];
      final thumbnail = m['thumbnail']?.toString();
      final links = m['links'];
      final category = DocCategory(
        id: [if (parent.id.isNotEmpty) parent.id, slugify(folder)].join('/'),
        label: m['label']?.toString() ?? humanize(folder),
        position: _position(m['position'], folder),
        assetDir: dir,
        description: m['description']?.toString() ?? (link is Map ? link['description']?.toString() : null),
        summary: m['summary']?.toString(),
        thumbnail: thumbnail == null ? null : resolveAsset('$dir/_category_.yaml', thumbnail),
        featured: m['featured'] == true,
        links: links is Map ? links.map((k, v) => MapEntry(k.toString(), v.toString())) : const {},
        aliases: m['aliases'] is List ? [for (final a in m['aliases'] as List) a.toString()] : const [],
      )..parent = parent == root ? null : parent;
      parent.children.add(category);
      byDir[dir] = category;
      return category;
    }

    for (final entry in files.entries) {
      final path = entry.key;
      if (!path.startsWith('$rootDir/') || !(path.endsWith('.md') || path.endsWith('.mdx'))) continue;
      final dir = _dirOf(path);
      final file = _nameOf(path);
      final category = categoryFor(dir);
      final fm = FrontMatterDocument.parse(entry.value);
      final (h1, body) = _extractTitle(fm.body);
      final title = fm.string('title') ?? h1 ?? humanize(file);
      final isIndex = category != root && RegExp(r'^(index|readme)\.mdx?$', caseSensitive: false).hasMatch(file);
      // Like Docusaurus: `slug`, else `id`, else the file name sets the URL.
      final slug = slugify(fm.string('slug') ?? fm.string('id') ?? file);
      final page = DocPage(
        id: isIndex ? category.id : [if (category.id.isNotEmpty) category.id, slug].join('/'),
        title: title,
        label: fm.string('sidebar_label') ?? title,
        position: _position(fm.data['sidebar_position'], file),
        description: fm.string('description'),
        body: body,
        assetPath: path,
      )..category = category == root ? null : category;
      if (isIndex) {
        category.indexPage = page;
      } else {
        category.children.add(page);
      }
    }

    void sortTree(DocCategory c) {
      c.children.sort((a, b) {
        final byPosition = a.position.compareTo(b.position);
        return byPosition != 0 ? byPosition : a.label.compareTo(b.label);
      });
      c.children.whereType<DocCategory>().forEach(sortTree);
    }

    sortTree(root);
    return root;
  }

  static Map<String, MarkdownPage> _parsePages(Map<String, String> files) {
    final pages = <String, MarkdownPage>{};
    for (final entry in files.entries) {
      final path = entry.key;
      if (!RegExp(r'^content/pages/[^/]+\.mdx?$').hasMatch(path)) continue;
      final fm = FrontMatterDocument.parse(entry.value);
      final (h1, body) = _extractTitle(fm.body);
      final slug = slugify(fm.string('slug') ?? _nameOf(path));
      pages[slug] = MarkdownPage(
        slug: slug,
        title: fm.string('title') ?? h1 ?? humanize(_nameOf(path)),
        description: fm.string('description'),
        body: body,
        assetPath: path,
      );
    }
    return pages;
  }

  /// Front matter position, else a numeric file prefix (`02-setup.md`), else last.
  static double _position(Object? value, String name) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    final prefix = RegExp(r'^(\d+)[-_.\s]').firstMatch(name);
    return prefix != null ? double.parse(prefix.group(1)!) : 1e6;
  }

  /// Pulls a leading `# Title` out of the body, since pages render titles themselves.
  static (String?, String) _extractTitle(String body) {
    final match = RegExp(r'^\s*#\s+(.+?)\s*#*\s*(\n|$)').firstMatch(body);
    if (match == null) return (null, body);
    return (plainText(match.group(1)!), body.substring(match.end));
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDate(DateTime date) => '${_months[date.month - 1]} ${date.day}, ${date.year}';
