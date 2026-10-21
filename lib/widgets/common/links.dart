import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

bool isExternalLink(String href) => RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(href);

/// Opens an internal route with go_router, or an external URL in a new tab.
Future<void> openLink(BuildContext context, String href) async {
  if (isExternalLink(href)) {
    await launchUrl(Uri.parse(href), webOnlyWindowName: href.startsWith('mailto:') ? '_self' : '_blank');
  } else {
    context.go(href);
  }
}

/// A text link that underlines on hover.
class InlineLink extends StatefulWidget {
  const InlineLink({super.key, required this.label, required this.href, this.style, this.trailingIcon});

  final String label;
  final String href;
  final TextStyle? style;
  final IconData? trailingIcon;

  @override
  State<InlineLink> createState() => _InlineLinkState();
}

class _InlineLinkState extends State<InlineLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final style = (widget.style ?? Theme.of(context).textTheme.labelLarge)!;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => openLink(context, widget.href),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.label,
                style: style.copyWith(
                  decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: style.color,
                ),
              ),
            ),
            if (widget.trailingIcon != null) ...[
              const SizedBox(width: 6),
              AnimatedSlide(
                offset: Offset(_hovered ? 0.25 : 0, 0),
                duration: const Duration(milliseconds: 150),
                child: Icon(widget.trailingIcon, size: (style.fontSize ?? 14) + 2, color: style.color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
