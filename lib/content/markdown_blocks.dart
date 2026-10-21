import 'text_utils.dart';

/// A Markdown body split into blocks the site renders with its own widgets.
///
/// Plain Markdown stays as [MdText]. On top of that we understand:
///
/// * `## Heading` / `### Heading` → [MdHeading] (feeds the table of contents)
/// * `:::note Title` … `:::` (Docusaurus admonitions) and GitHub's
///   `> [!NOTE]` alerts → [MdAdmonition]
/// * `::youtube <id or url> [start=90]` or a YouTube `<iframe>` → [MdYoutube]
/// * `::name args` → [MdDirective], e.g. `::plugin-links`
sealed class MdBlock {
  const MdBlock();
}

class MdText extends MdBlock {
  const MdText(this.markdown);
  final String markdown;
}

class MdHeading extends MdBlock {
  const MdHeading({required this.level, required this.markdown, required this.text, required this.id});

  final int level;

  /// The heading's inline Markdown (may contain `code` or **bold**).
  final String markdown;

  /// Plain text, for the table of contents.
  final String text;

  /// Anchor id, unique within the page.
  final String id;
}

class MdAdmonition extends MdBlock {
  const MdAdmonition({required this.type, required this.title, required this.children});

  /// note, tip, info, warning, danger.
  final String type;
  final String? title;
  final List<MdBlock> children;
}

class MdYoutube extends MdBlock {
  const MdYoutube({required this.videoId, this.start});
  final String videoId;
  final int? start;
}

class MdDirective extends MdBlock {
  const MdDirective(this.name, this.args);
  final String name;
  final String args;
}

class ParsedMarkdown {
  const ParsedMarkdown(this.blocks, this.headings);

  final List<MdBlock> blocks;

  /// Top-level h2/h3 headings in order, for the table of contents.
  final List<MdHeading> headings;

  static ParsedMarkdown parse(String body) {
    final ids = <String, int>{};
    final headings = <MdHeading>[];
    final blocks = _parseBlocks(body.split('\n'), ids, headings, topLevel: true);
    return ParsedMarkdown(blocks, headings);
  }
}

const _admonitionTypes = {
  'note': 'note',
  'tip': 'tip',
  'info': 'info',
  'important': 'info',
  'warning': 'warning',
  'caution': 'warning',
  'danger': 'danger',
};

final _fence = RegExp(r'^\s*(```|~~~)');
final _admonitionStart = RegExp(r'^\s*:::\s*([a-zA-Z]+)\s*(.*)$');
final _admonitionEnd = RegExp(r'^\s*:::\s*$');
final _githubAlert = RegExp(r'^\s*>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$', caseSensitive: false);
final _heading = RegExp(r'^(#{2,3})\s+(.+?)\s*#*\s*$');
final _directive = RegExp(r'^::([a-zA-Z][\w-]*)\s*(.*)$');
final _youtubeIframe = RegExp(r'<iframe[^>]+youtube(?:-nocookie)?\.com/embed/([\w-]+)([^"\x27]*)');
final _mdxImport = RegExp(r'''^import\s+.+\s+from\s+['"].+['"];?\s*$''');

List<MdBlock> _parseBlocks(
  List<String> lines,
  Map<String, int> ids,
  List<MdHeading> headings, {
  required bool topLevel,
}) {
  final blocks = <MdBlock>[];
  final buffer = <String>[];
  var inFence = false;
  String? fenceMarker;

  void flush() {
    final text = buffer.join('\n').trim();
    if (text.isNotEmpty) blocks.add(MdText(text));
    buffer.clear();
  }

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];

    final fence = _fence.firstMatch(line);
    if (fence != null) {
      if (!inFence) {
        inFence = true;
        fenceMarker = fence.group(1);
      } else if (line.trim().startsWith(fenceMarker!)) {
        inFence = false;
      }
      buffer.add(line);
      continue;
    }
    if (inFence) {
      buffer.add(line);
      continue;
    }

    if (line.trim() == '<!-- truncate -->' || _mdxImport.hasMatch(line.trim())) continue;

    final admonition = _admonitionStart.firstMatch(line);
    if (admonition != null && _admonitionTypes.containsKey(admonition.group(1)!.toLowerCase())) {
      flush();
      final inner = <String>[];
      var depth = 1;
      var innerFence = false;
      i++;
      for (; i < lines.length; i++) {
        final l = lines[i];
        if (_fence.hasMatch(l)) innerFence = !innerFence;
        if (!innerFence) {
          if (_admonitionEnd.hasMatch(l)) {
            depth--;
            if (depth == 0) break;
          } else if (_admonitionStart.hasMatch(l)) {
            depth++;
          }
        }
        inner.add(l);
      }
      blocks.add(MdAdmonition(
        type: _admonitionTypes[admonition.group(1)!.toLowerCase()]!,
        title: _cleanTitle(admonition.group(2)),
        children: _parseBlocks(_dedent(inner), ids, headings, topLevel: false),
      ));
      continue;
    }

    final alert = _githubAlert.firstMatch(line);
    if (alert != null) {
      flush();
      final inner = <String>[];
      while (i + 1 < lines.length && lines[i + 1].trimLeft().startsWith('>')) {
        i++;
        inner.add(lines[i].trimLeft().replaceFirst(RegExp(r'^>\s?'), ''));
      }
      blocks.add(MdAdmonition(
        type: _admonitionTypes[alert.group(1)!.toLowerCase()]!,
        title: null,
        children: _parseBlocks(inner, ids, headings, topLevel: false),
      ));
      continue;
    }

    final iframe = _youtubeIframe.firstMatch(line);
    if (iframe != null) {
      flush();
      final start = RegExp(r'start=(\d+)').firstMatch(iframe.group(2) ?? '');
      blocks.add(MdYoutube(videoId: iframe.group(1)!, start: int.tryParse(start?.group(1) ?? '')));
      continue;
    }

    final directive = _directive.firstMatch(line.trim());
    if (directive != null) {
      flush();
      final name = directive.group(1)!.toLowerCase();
      final args = directive.group(2)!.trim();
      final youtube = name == 'youtube' ? _parseYoutube(args) : null;
      blocks.add(youtube ?? MdDirective(name, args));
      continue;
    }

    final heading = _heading.firstMatch(line);
    if (heading != null && topLevel) {
      flush();
      final markdown = heading.group(2)!;
      final text = plainText(markdown);
      final base = slugify(text, stripNumberPrefix: false);
      final count = ids.update(base, (c) => c + 1, ifAbsent: () => 0);
      final h = MdHeading(
        level: heading.group(1)!.length,
        markdown: markdown,
        text: text,
        id: count == 0 ? base : '$base-$count',
      );
      headings.add(h);
      blocks.add(h);
      continue;
    }

    buffer.add(line);
  }
  flush();
  return blocks;
}

MdYoutube? _parseYoutube(String args) {
  final parts = args.split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return null;
  final source = parts.first;
  String? id;
  int? start;
  final uri = Uri.tryParse(source);
  if (uri != null && uri.host.isNotEmpty) {
    id = uri.queryParameters['v'] ??
        (uri.host.contains('youtu.be') ? uri.pathSegments.firstOrNull : uri.pathSegments.lastOrNull);
    start = int.tryParse((uri.queryParameters['t'] ?? uri.queryParameters['start'] ?? '').replaceAll('s', ''));
  } else {
    id = source;
  }
  for (final p in parts.skip(1)) {
    final m = RegExp(r'^(?:start|t)=(\d+)').firstMatch(p);
    if (m != null) start = int.parse(m.group(1)!);
  }
  return id == null || id.isEmpty ? null : MdYoutube(videoId: id, start: start);
}

String? _cleanTitle(String? raw) {
  final t = raw?.replaceAll('*', '').trim();
  return t == null || t.isEmpty ? null : t;
}

/// Removes the indentation shared by all non-empty lines (tabs count as 4).
List<String> _dedent(List<String> lines) {
  final expanded = lines.map((l) => l.replaceAll('\t', '    ')).toList();
  int? minIndent;
  for (final l in expanded) {
    if (l.trim().isEmpty) continue;
    final indent = l.length - l.trimLeft().length;
    if (minIndent == null || indent < minIndent) minIndent = indent;
  }
  final indent = minIndent ?? 0;
  if (indent == 0) return expanded;
  return expanded.map((l) => l.length >= indent ? l.substring(indent) : l.trimLeft()).toList();
}
