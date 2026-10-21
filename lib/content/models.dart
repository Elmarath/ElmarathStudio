import 'markdown_blocks.dart';

class Author {
  const Author({required this.id, required this.name, this.title, this.url, this.imageUrl});

  final String id;
  final String name;
  final String? title;
  final String? url;
  final String? imageUrl;
}

class BlogPost {
  BlogPost({
    required this.slug,
    required this.title,
    required this.date,
    required this.authors,
    required this.tags,
    required this.excerpt,
    required this.body,
    required this.assetPath,
    required this.image,
    required this.draft,
    required this.readingMinutes,
  });

  final String slug;
  final String title;
  final DateTime date;
  final List<Author> authors;
  final List<String> tags;
  final String excerpt;
  final String body;

  /// Path of the .md file inside the asset bundle (used to resolve relative images).
  final String assetPath;

  /// Cover image: an asset path or a URL.
  final String? image;
  final bool draft;
  final int readingMinutes;

  String get route => '/blog/$slug';

  late final ParsedMarkdown parsed = ParsedMarkdown.parse(body);
}

/// A node in the docs sidebar: either a page or a folder of pages.
sealed class DocNode {
  String get id;
  String get label;
  double get position;
  String get route => '/docs/$id';
}

class DocPage extends DocNode {
  DocPage({
    required this.id,
    required this.title,
    required this.label,
    required this.position,
    required this.description,
    required this.body,
    required this.assetPath,
  });

  @override
  final String id;
  final String title;

  /// Sidebar text (front matter `sidebar_label`, defaults to the title).
  @override
  final String label;
  @override
  final double position;
  final String? description;
  final String body;
  final String assetPath;

  /// The folder this page lives in, if any.
  DocCategory? category;

  late final ParsedMarkdown parsed = ParsedMarkdown.parse(body);

  /// The top-level folder (the plugin) this page belongs to.
  DocCategory? get rootCategory {
    var c = category;
    while (c?.parent != null) {
      c = c!.parent;
    }
    return c;
  }
}

class DocCategory extends DocNode {
  DocCategory({
    required this.id,
    required this.label,
    required this.position,
    required this.assetDir,
    this.description,
    this.summary,
    this.thumbnail,
    this.featured = false,
    this.links = const {},
  });

  @override
  final String id;
  @override
  final String label;
  @override
  final double position;
  final String assetDir;
  final String? description;

  /// One-line pitch shown on cards. Falls back to [description].
  final String? summary;

  /// Asset path or URL of the square thumbnail.
  final String? thumbnail;

  /// Shown in the home page spotlight.
  final bool featured;

  /// External links such as `fab` and `github`.
  final Map<String, String> links;

  final List<DocNode> children = [];
  DocCategory? parent;

  /// An `index.md` inside the folder replaces the generated overview page.
  DocPage? indexPage;

  String get pitch => summary ?? description ?? '';

  /// Every page inside this folder, depth first, in sidebar order.
  Iterable<DocPage> get allPages sync* {
    if (indexPage != null) yield indexPage!;
    for (final child in children) {
      if (child is DocPage) yield child;
      if (child is DocCategory) yield* child.allPages;
    }
  }

  bool containsRoute(String route) =>
      this.route == route || route.startsWith('${this.route}/');
}

class MarkdownPage {
  MarkdownPage({
    required this.slug,
    required this.title,
    required this.description,
    required this.body,
    required this.assetPath,
  });

  final String slug;
  final String title;
  final String? description;
  final String body;
  final String assetPath;

  late final ParsedMarkdown parsed = ParsedMarkdown.parse(body);
}

enum SearchKind { doc, post, page }

class SearchEntry {
  SearchEntry({
    required this.kind,
    required this.title,
    required this.context,
    required this.route,
    required this.headings,
    required this.text,
  });

  final SearchKind kind;
  final String title;

  /// Where it lives, e.g. the plugin name or the post date.
  final String context;
  final String route;
  final String headings;
  final String text;

  late final String _title = title.toLowerCase();
  late final String _headings = headings.toLowerCase();
  late final String _text = text.toLowerCase();

  /// 0 means no match.
  int score(List<String> terms) {
    var score = 0;
    for (final term in terms) {
      if (_title.contains(term)) {
        score += 10;
      } else if (_headings.contains(term)) {
        score += 4;
      } else if (_text.contains(term)) {
        score += 1;
      } else {
        return 0;
      }
    }
    return score;
  }

  String snippet(String term) {
    final at = _text.indexOf(term);
    if (at < 0) return text.length > 120 ? '${text.substring(0, 120)}…' : text;
    final start = (at - 50).clamp(0, text.length);
    final end = (at + 90).clamp(0, text.length);
    return '${start > 0 ? '…' : ''}${text.substring(start, end)}${end < text.length ? '…' : ''}';
  }
}
