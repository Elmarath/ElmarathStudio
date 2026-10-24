import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/tokens.dart';
import '../search/site_search.dart';
import 'site_nav_bar.dart';

/// The frame around every page: nav bar on top, page below.
/// Cmd/Ctrl + K opens search from anywhere.
class SiteShell extends StatefulWidget {
  const SiteShell({super.key, required this.location, required this.child});

  /// Current path, used to highlight the active nav item.
  final String location;
  final Widget child;

  @override
  State<SiteShell> createState() => _SiteShellState();
}

class _SiteShellState extends State<SiteShell> {
  final _search = SearchController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openSearch() {
    if (!_search.isOpen) _search.openView();
  }

  @override
  Widget build(BuildContext context) {
    final compact = ScreenSize.of(context).isCompact;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _openSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _openSearch,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          endDrawer: compact ? SiteNavDrawer(location: widget.location) : null,
          body: Column(
            children: [
              SiteNavBar(location: widget.location, search: SiteSearch(controller: _search)),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}
