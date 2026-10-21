import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import 'docs_sidebar.dart';

/// Docs layout: sidebar on the left, the page on the right.
/// On phones the sidebar moves into a drawer opened from a bar at the top.
class DocsShell extends StatelessWidget {
  const DocsShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = ScreenSize.of(context);
    final sidebar = DocsSidebar(location: location);

    if (size.isCompact) {
      return Scaffold(
        drawer: Drawer(width: 320, child: SafeArea(child: sidebar)),
        body: Column(
          children: [
            Builder(
              builder: (context) => Material(
                color: p.surface,
                child: InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: size.gutter),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border))),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_open, size: 20),
                        const SizedBox(width: Insets.sm),
                        Text('Docs menu', style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: size.isExpanded ? 300 : 260,
          decoration: BoxDecoration(border: Border(right: BorderSide(color: p.border))),
          child: sidebar,
        ),
        Expanded(child: child),
      ],
    );
  }
}
