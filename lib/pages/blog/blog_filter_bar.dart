import 'package:flutter/material.dart';

import '../../content/text_utils.dart';
import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';

/// Tag pills on the left, a "Search by tag…" field on the right.
/// [selected] is a tag slug, or null for all posts.
class BlogFilterBar extends StatelessWidget {
  const BlogFilterBar({super.key, required this.tags, required this.selected, required this.onSelect});

  final List<String> tags;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final compact = ScreenSize.of(context).isCompact;
    final pills = [
      _TagPill(label: 'All', selected: selected == null, onTap: () => onSelect(null)),
      for (final tag in tags)
        _TagPill(label: tag, selected: slugify(tag) == selected, onTap: () => onSelect(slugify(tag))),
    ];

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TagSearch(tags: tags, selected: selected, onSelect: onSelect, expand: true),
          const SizedBox(height: Insets.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final pill in pills) Padding(padding: const EdgeInsets.only(right: 10), child: pill),
              ],
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Wrap(spacing: 10, runSpacing: 10, children: pills)),
        const SizedBox(width: Insets.xl),
        _TagSearch(tags: tags, selected: selected, onSelect: onSelect, expand: false),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.transparent,
      selectedColor: p.textPrimary,
      side: BorderSide(color: selected ? p.textPrimary : p.textMuted.withValues(alpha: 0.6)),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: selected ? p.background : p.textPrimary,
          ),
    );
  }
}

/// Material's [DropdownMenu] with type-to-filter, listing every tag.
class _TagSearch extends StatelessWidget {
  const _TagSearch({required this.tags, required this.selected, required this.onSelect, required this.expand});

  final List<String> tags;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final border = OutlineInputBorder(
      borderRadius: Radii.smAll,
      borderSide: BorderSide(color: p.textMuted.withValues(alpha: 0.6)),
    );
    return DropdownMenu<String>(
      // Rebuild when the selection changes elsewhere (e.g. a pill), so the field text follows.
      key: ValueKey(selected),
      initialSelection: selected,
      width: expand ? null : 340,
      expandedInsets: expand ? EdgeInsets.zero : null,
      hintText: 'Search by tag...',
      leadingIcon: const Icon(Icons.search, size: 20),
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textPrimary),
      onSelected: (slug) {
        if (slug != null) onSelect(slug);
      },
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        constraints: const BoxConstraints.tightFor(height: 46),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: p.textMuted),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: p.accent)),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(p.surfaceRaised),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: Radii.mdAll, side: BorderSide(color: p.border)),
        ),
      ),
      dropdownMenuEntries: [
        for (final tag in tags) DropdownMenuEntry(value: slugify(tag), label: tag),
      ],
    );
  }
}
