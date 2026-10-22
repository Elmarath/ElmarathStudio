import 'package:yaml/yaml.dart';

/// Turns a file name, folder name or heading into a URL-safe id.
///
/// `Easy-Trace-Trail-System` → `easy-trace-trail-system`,
/// `AbilitySets.md` → `ability-sets`, `02-setup` → `setup`.
/// Docusaurus-style links (`/docs/Easy-Ability-Set-System/AbilitySets`) are
/// slugified the same way, so old links keep working.
String slugify(String input, {bool stripNumberPrefix = true}) {
  var s = input;
  try {
    s = Uri.decodeComponent(s);
  } catch (_) {}
  s = s.replaceAll(RegExp(r'\.(md|mdx)$', caseSensitive: false), '');
  if (stripNumberPrefix) s = s.replaceFirst(RegExp(r'^\d+[-_.\s]+(?=\S)'), '');
  s = s.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}-${m[2]}');
  s = s.replaceAllMapped(RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]}-${m[2]}');
  s = s.toLowerCase().replaceAll(RegExp(r"['’]"), '');
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return s.replaceAll(RegExp(r'^-+|-+$'), '');
}

/// `Easy-Trace-Trail-System` → `Easy Trace Trail System`.
String humanize(String input) {
  var s = input.replaceAll(RegExp(r'\.(md|mdx)$'), '');
  s = s.replaceFirst(RegExp(r'^\d+[-_.\s]+(?=\S)'), '');
  s = s.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  s = s.replaceAll(RegExp(r'[-_]+'), ' ').trim();
  return s.isEmpty ? input : s[0].toUpperCase() + s.substring(1);
}

/// Strips Markdown syntax to get readable text (for excerpts, search and TOC).
String plainText(String markdown) {
  var s = markdown;
  s = s.replaceAll(RegExp(r'```[\s\S]*?```'), ' ');
  s = s.replaceAll(RegExp(r'!\[([^\]]*)\]\([^)]*\)'), '');
  s = s.replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (m) => m[1]!);
  s = s.replaceAll(RegExp(r'<[^>]+>'), '');
  s = s.replaceAll(RegExp(r'^\s{0,3}(#{1,6}|>|[-*+]|\d+\.)\s+', multiLine: true), '');
  s = s.replaceAll(RegExp(r'^:{2,}.*$', multiLine: true), '');
  s = s.replaceAll(RegExp(r'[*_`~|]'), '');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// A Markdown file split into its YAML front matter and body.
class FrontMatterDocument {
  const FrontMatterDocument(this.data, this.body);

  final Map<String, dynamic> data;
  final String body;

  static FrontMatterDocument parse(String raw) {
    final text = raw.replaceAll('\r\n', '\n');
    final match = RegExp(r'^---[ \t]*\n([\s\S]*?)\n---[ \t]*(\n|$)').firstMatch(text);
    if (match == null) return FrontMatterDocument(const {}, text);
    return FrontMatterDocument(
      parseYamlMap(match.group(1)!),
      text.substring(match.end),
    );
  }

  String? string(String key) {
    final value = data[key];
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  num? number(String key) {
    final value = data[key];
    if (value is num) return value;
    return value == null ? null : num.tryParse(value.toString());
  }

  bool flag(String key) => data[key] == true || data[key]?.toString() == 'true';

  List<String> list(String key) {
    final value = data[key];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}

/// Parses YAML (or JSON, which is valid YAML) into plain Dart maps and lists.
Map<String, dynamic> parseYamlMap(String source) {
  if (source.trim().isEmpty) return {};
  final node = loadYaml(source);
  final value = _plain(node);
  return value is Map<String, dynamic> ? value : {};
}

dynamic _plain(dynamic node) {
  if (node is YamlMap) {
    return {for (final e in node.entries) e.key.toString(): _plain(e.value)};
  }
  if (node is YamlList) return node.map(_plain).toList();
  return node;
}
