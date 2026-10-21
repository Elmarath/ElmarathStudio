import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

import '../../app_scope.dart';
import '../../config/site_config.dart';
import '../../content/markdown_blocks.dart';
import '../../content/models.dart';
import '../../content/text_utils.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/plugin_card.dart';
import '../../widgets/cards/plugin_links.dart';
import '../../widgets/common/hover_card.dart';
import '../../widgets/common/links.dart';
import '../../widgets/layout/content_width.dart';
import '../../widgets/layout/responsive_grid.dart';
import '../../widgets/markdown/markdown_view.dart';
import '../not_found_page.dart';
import 'doc_toc.dart';

/// `/docs/<id>`: a doc page, or the overview of a folder.
class DocRoutePage extends StatelessWidget {
  const DocRoutePage({super.key, required this.id, this.fragment = ''});

  final String id;
  final String fragment;

  @override
  Widget build(BuildContext context) {
    final content = context.content;
    final doc = content.doc(id);
    if (doc != null) return DocPageView(doc: doc, fragment: fragment);
    final category = content.category(id);
    if (category != null) return CategoryPage(category: category);
    return const NotFoundPage(showFooter: false);
  }
}

class DocPageView extends StatefulWidget {
  const DocPageView({super.key, required this.doc, this.fragment = ''});

  final DocPage doc;
  final String fragment;

  @override
  State<DocPageView> createState() => _DocPageViewState();
}

class _DocPageViewState extends State<DocPageView> {
  final _scroll = ScrollController();
  late Map<String, GlobalKey> _keys;
  final _active = ValueNotifier<String?>(null);
  String? _scrollingTo;

  List<MdHeading> get _headings => widget.doc.parsed.headings;

  @override
  void initState() {
    super.initState();
    _keys = {for (final h in widget.doc.parsed.headings) h.id: GlobalKey(debugLabel: h.id)};
    _active.value = widget.doc.parsed.headings.firstOrNull?.id;
    _scroll.addListener(_updateActive);
    if (widget.fragment.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(widget.fragment, animate: false));
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _active.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(String id, {bool animate = true}) async {
    final target = _keys[id]?.currentContext;
    if (target == null) return;
    // Keep the clicked heading highlighted while the scroll animates past others.
    _scrollingTo = id;
    _active.value = id;
    final box = target.findRenderObject();
    if (box != null && _scroll.hasClients) {
      // Land a little below the top edge so the heading has room to breathe.
      final reveal = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset - Insets.lg;
      final offset = reveal.clamp(0.0, _scroll.position.maxScrollExtent);
      if (animate) {
        await _scroll.animateTo(offset, duration: Motion.slow, curve: Motion.curve);
      } else {
        _scroll.jumpTo(offset);
      }
    }
    if (_scrollingTo == id) _scrollingTo = null;
  }

  /// Highlights the last heading that has scrolled past the top of the view.
  void _updateActive() {
    if (_scrollingTo != null || _headings.isEmpty || !_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 4) {
      _active.value = widget.doc.parsed.headings.last.id;
      return;
    }
    final viewport = context.findRenderObject() as RenderBox?;
    if (viewport == null) return;
    final top = viewport.localToGlobal(Offset.zero).dy;
    // A heading counts as "being read" once it's in the top 30% of the view.
    final readingLine = position.viewportDimension * 0.3;
    String? current;
    for (final h in widget.doc.parsed.headings) {
      final box = _keys[h.id]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      if (box.localToGlobal(Offset.zero).dy - top <= readingLine) {
        current = h.id;
      } else {
        break;
      }
    }
    _active.value = current ?? widget.doc.parsed.headings.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final content = context.content;
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final width = MediaQuery.sizeOf(context).width;
    final showToc = width >= 1280 && doc.parsed.headings.length > 1;
    final index = content.docPages.indexOf(doc);
    final previous = index > 0 ? content.docPages[index - 1] : null;
    final next = index >= 0 && index < content.docPages.length - 1 ? content.docPages[index + 1] : null;
    final plugin = doc.rootCategory;

    final article = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DocBreadcrumbs(category: doc.category, current: doc.category?.indexPage == doc ? null : doc.title),
        const SizedBox(height: Insets.md),
        Text(doc.title, style: ScreenSize.of(context).isCompact ? text.headlineLarge : text.displaySmall),
        if (doc.description != null) ...[
          const SizedBox(height: Insets.sm),
          Text(doc.description!, style: text.bodyLarge?.copyWith(fontSize: 18)),
        ],
        const SizedBox(height: Insets.xl),
        SelectionArea(
          child: MarkdownView(
            blocks: doc.parsed.blocks,
            sourcePath: doc.assetPath,
            headingKeys: _keys,
            onAnchor: _scrollTo,
            directiveBuilder: (context, directive) =>
                directive.name == 'plugin-links' ? PluginLinks(links: plugin?.links ?? const {}) : null,
          ),
        ),
        const SizedBox(height: Insets.xxl),
        if (SiteConfig.editBaseUrl != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: InlineLink(
              label: 'Edit this page',
              href: '${SiteConfig.editBaseUrl}${doc.assetPath}',
              trailingIcon: Icons.edit_outlined,
              style: text.labelLarge?.copyWith(color: p.accent),
            ),
          ),
          const SizedBox(height: Insets.lg),
        ],
        Divider(color: p.border),
        const SizedBox(height: Insets.lg),
        DocPager(previous: previous, next: next),
      ],
    );

    return PageTitle(
      title: doc.title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ContentScrollView(
              controller: _scroll,
              child: ContentWidth(
                maxWidth: ContentWidths.reading,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
                  child: article,
                ),
              ),
            ),
          ),
          if (showToc)
            SizedBox(
              width: 260,
              child: DocToc(headings: doc.parsed.headings, active: _active, onSelect: _scrollTo),
            ),
        ],
      ),
    );
  }
}

/// Docs › Plugin › Folder › Page
class DocBreadcrumbs extends StatelessWidget {
  const DocBreadcrumbs({super.key, required this.category, this.current});

  final DocCategory? category;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final trail = <DocCategory>[];
    for (var c = category; c != null; c = c.parent) {
      trail.insert(0, c);
    }
    final linkStyle = text.labelMedium?.copyWith(color: p.textSecondary);
    final separator = Icon(Icons.chevron_right, size: 16, color: p.textMuted);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        InlineLink(label: 'Docs', href: '/docs', style: linkStyle),
        for (final c in trail) ...[separator, InlineLink(label: c.label, href: c.route, style: linkStyle)],
        if (current != null) ...[separator, Text(current!, style: text.labelMedium?.copyWith(color: p.textMuted))],
      ],
    );
  }
}

class DocPager extends StatelessWidget {
  const DocPager({super.key, this.previous, this.next});

  final DocPage? previous;
  final DocPage? next;

  @override
  Widget build(BuildContext context) {
    final compact = ScreenSize.of(context).isCompact;
    final prev = previous == null ? const SizedBox() : _PagerCard(page: previous!, isNext: false);
    final nxt = next == null ? const SizedBox() : _PagerCard(page: next!, isNext: true);
    if (compact) {
      return Column(children: [nxt, const SizedBox(height: Insets.sm), prev]);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Expanded(child: prev), const SizedBox(width: Insets.md), Expanded(child: nxt)],
      ),
    );
  }
}

class _PagerCard extends StatelessWidget {
  const _PagerCard({required this.page, required this.isNext});

  final DocPage page;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final align = isNext ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return HoverCard(
      onTap: () => context.go(page.route),
      padding: const EdgeInsets.all(Insets.md + 2),
      builder: (context, hovered) => SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: align,
          children: [
            Text(isNext ? 'Next' : 'Previous', style: text.labelSmall),
            const SizedBox(height: 4),
            Text(
              isNext ? '${page.title}  »' : '«  ${page.title}',
              textAlign: isNext ? TextAlign.end : TextAlign.start,
              style: text.titleMedium?.copyWith(color: p.accent),
            ),
            if (page.rootCategory != null) ...[
              const SizedBox(height: 2),
              Text(page.rootCategory!.label, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generated overview of a docs folder: its description and a card per page.
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, required this.category});

  final DocCategory category;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final compact = ScreenSize.of(context).isCompact;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category.label, style: compact ? text.headlineLarge : text.displaySmall),
        if (category.pitch.isNotEmpty) ...[
          const SizedBox(height: Insets.sm),
          Text(category.pitch, style: text.bodyLarge),
        ],
        if (category.links.isNotEmpty) ...[
          const SizedBox(height: Insets.md),
          PluginLinks(links: category.links),
        ],
      ],
    );
    final thumbnail = [
      if (category.thumbnail != null) ...[
        PluginThumbnail(category: category, size: compact ? 96 : 120),
        const SizedBox(width: Insets.lg, height: Insets.lg),
      ],
    ];

    return PageTitle(
      title: category.label,
      child: ContentScrollView(
        child: ContentWidth(
          maxWidth: 960,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Insets.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DocBreadcrumbs(category: category.parent),
                const SizedBox(height: Insets.lg),
                if (compact)
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...thumbnail, details])
                else
                  Row(children: [...thumbnail, Flexible(child: details)]),
                const SizedBox(height: Insets.xxl),
                ResponsiveGrid(
                  minItemWidth: 320,
                  maxColumns: 2,
                  children: [
                    for (final child in category.children) _ChildCard(node: child),
                  ],
                ),
                if (category.children.isEmpty)
                  Text('No pages yet.', style: text.bodyMedium?.copyWith(color: p.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.node});

  final DocNode node;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final (icon, subtitle) = switch (node) {
      DocPage(:final description, :final body) => (
          Icons.description_outlined,
          description ?? _firstSentence(plainText(body)),
        ),
      DocCategory(:final allPages, :final pitch) => (
          Icons.folder_outlined,
          pitch.isNotEmpty ? pitch : '${allPages.length} pages',
        ),
    };
    return HoverCard(
      onTap: () => context.go(node.route),
      padding: const EdgeInsets.all(Insets.lg - 4),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: p.accent),
          const SizedBox(height: Insets.md),
          Text(node.label, style: text.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis, style: text.bodyMedium),
        ],
      ),
    );
  }

  static String _firstSentence(String s) {
    final end = s.indexOf(RegExp(r'[.!?](\s|$)'));
    final sentence = end > 0 ? s.substring(0, end + 1) : s;
    return sentence.length > 160 ? '${sentence.substring(0, 157)}…' : sentence;
  }
}
