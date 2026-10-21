import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../../app_scope.dart';
import '../../content/content_repository.dart';
import '../../content/markdown_blocks.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/links.dart';
import 'admonition.dart';
import 'code_block.dart';
import 'markdown_image.dart';
import 'youtube_embed.dart';

/// Builds a widget for a `::name args` directive, or null if unknown.
typedef DirectiveBuilder = Widget? Function(BuildContext context, MdDirective directive);

/// Renders parsed Markdown with the site's styling.
///
/// [sourcePath] is the .md file's asset path; relative images and links are
/// resolved against it. Give [headingKeys] to make headings scroll targets
/// for a table of contents.
class MarkdownView extends StatelessWidget {
  const MarkdownView({
    super.key,
    required this.blocks,
    required this.sourcePath,
    this.headingKeys = const {},
    this.directiveBuilder,
    this.onAnchor,
  });

  final List<MdBlock> blocks;
  final String sourcePath;
  final Map<String, GlobalKey> headingKeys;
  final DirectiveBuilder? directiveBuilder;

  /// Called for `#anchor` links on the same page.
  final ValueChanged<String>? onAnchor;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final block in blocks) {
      final widget = _buildBlock(context, block);
      if (widget == null) continue;
      if (children.isNotEmpty) {
        children.add(SizedBox(height: block is MdHeading ? Insets.xl : Insets.md));
      }
      children.add(widget);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget? _buildBlock(BuildContext context, MdBlock block) {
    switch (block) {
      case MdText(:final markdown):
        return _markdown(context, markdown);
      case MdHeading():
        return KeyedSubtree(
          key: headingKeys[block.id],
          child: _markdown(context, '${'#' * block.level} ${block.markdown}'),
        );
      case MdAdmonition():
        return Admonition(
          type: block.type,
          title: block.title,
          child: MarkdownView(
            blocks: block.children,
            sourcePath: sourcePath,
            directiveBuilder: directiveBuilder,
            onAnchor: onAnchor,
          ),
        );
      case MdYoutube(:final videoId, :final start):
        return YoutubeEmbed(videoId: videoId, start: start);
      case MdDirective():
        return directiveBuilder?.call(context, block) ?? _UnknownDirective(block);
    }
  }

  Widget _markdown(BuildContext context, String data) {
    final content = context.content;
    return MarkdownBody(
      data: data,
      styleSheet: markdownStyleSheet(context),
      extensionSet: md.ExtensionSet.gitHubFlavored,
      builders: {'pre': CodeBlockBuilder()},
      imageBuilder: (uri, title, alt) => MarkdownImage(
        source: ContentRepository.resolveAsset(sourcePath, uri.toString()),
        alt: alt,
      ),
      onTapLink: (text, href, title) {
        if (href == null) return;
        if (isExternalLink(href) || isFileLink(href)) {
          openLink(context, href);
          return;
        }
        final route = content.internalRoute(href, sourcePath: sourcePath);
        if (route == null) return;
        if (route.startsWith('#')) {
          onAnchor?.call(route.substring(1));
        } else {
          openLink(context, route);
        }
      },
    );
  }
}

MarkdownStyleSheet markdownStyleSheet(BuildContext context) {
  final p = context.palette;
  final text = Theme.of(context).textTheme;
  final body = text.bodyLarge!;
  return MarkdownStyleSheet(
    p: body,
    pPadding: EdgeInsets.zero,
    a: body.copyWith(color: p.accent, decoration: TextDecoration.underline, decorationColor: p.accent.withValues(alpha: 0.4)),
    strong: const TextStyle(fontWeight: FontWeight.w700).copyWith(color: p.textPrimary),
    em: const TextStyle(fontStyle: FontStyle.italic),
    del: TextStyle(decoration: TextDecoration.lineThrough, color: p.textMuted),
    h1: text.headlineLarge,
    h1Padding: const EdgeInsets.only(top: Insets.lg, bottom: Insets.xs),
    h2: text.headlineMedium,
    h3: text.headlineSmall,
    h4: text.titleLarge,
    h5: text.titleMedium,
    h6: text.titleSmall,
    code: AppTheme.code(fontSize: 14, color: p.textPrimary).copyWith(backgroundColor: p.surfaceRaised),
    blockSpacing: Insets.md,
    listIndent: 26,
    listBullet: body.copyWith(color: p.textMuted),
    listBulletPadding: const EdgeInsets.only(right: 6),
    blockquote: body.copyWith(color: p.textSecondary, fontStyle: FontStyle.italic),
    blockquotePadding: const EdgeInsets.fromLTRB(Insets.md, Insets.sm, Insets.md, Insets.sm),
    blockquoteDecoration: BoxDecoration(
      color: p.surface,
      border: Border(left: BorderSide(color: p.accent, width: 3)),
    ),
    codeblockDecoration: const BoxDecoration(),
    horizontalRuleDecoration: BoxDecoration(border: Border(top: BorderSide(color: p.border))),
    tableHead: text.titleSmall,
    tableBody: text.bodyMedium,
    tableBorder: TableBorder.all(color: p.border, borderRadius: Radii.smAll),
    tableHeadAlign: TextAlign.left,
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    tableCellsDecoration: BoxDecoration(color: p.surface),
    tableColumnWidth: const _SafeIntrinsicColumnWidth(),
    tableScrollbarThumbVisibility: false,
    checkbox: body.copyWith(color: p.accent),
  );
}

/// Sizes table columns to their content (the table scrolls sideways when wide).
///
/// Adds a couple of pixels because on the web the measured text width can come
/// out a fraction too small, which wraps the last character onto a new line.
class _SafeIntrinsicColumnWidth extends IntrinsicColumnWidth {
  const _SafeIntrinsicColumnWidth();

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      super.minIntrinsicWidth(cells, containerWidth) + 2;

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) =>
      super.maxIntrinsicWidth(cells, containerWidth) + 2;
}

class _UnknownDirective extends StatelessWidget {
  const _UnknownDirective(this.directive);

  final MdDirective directive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      'Unknown directive ::${directive.name}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: p.warning),
    );
  }
}
