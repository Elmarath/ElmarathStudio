import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';

/// A clickable card that lifts slightly and highlights its border on hover.
///
/// [builder] receives the hover state so children can react too
/// (e.g. zoom a thumbnail). Keyboard focus and Enter work like a button.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.builder,
    this.onTap,
    this.borderRadius = Radii.mdAll,
    this.color,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
  });

  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final active = _hovered && widget.onTap != null;
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: AnimatedContainer(
        duration: Motion.normal,
        curve: Motion.curve,
        transform: Matrix4.translationValues(0, active ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color ?? p.surface,
          borderRadius: widget.borderRadius,
          border: Border.all(color: active ? p.textPrimary.withValues(alpha: 0.28) : p.border),
          boxShadow: [
            if (active)
              BoxShadow(
                color: Colors.black.withValues(alpha: p.isDark ? 0.45 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (h) => setState(() => _hovered = h),
            borderRadius: widget.borderRadius,
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: Padding(
                padding: widget.padding,
                child: widget.builder(context, active),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Zooms its child a little when [hovered] (for card thumbnails).
class HoverZoom extends StatelessWidget {
  const HoverZoom({super.key, required this.hovered, required this.child});

  final bool hovered;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: hovered ? 1.04 : 1,
      duration: Motion.slow,
      curve: Motion.curve,
      child: child,
    );
  }
}
