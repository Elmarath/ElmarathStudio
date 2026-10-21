import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

const bool supportsInlinePlayer = true;

final _registered = <String>{};

/// The real YouTube player, embedded as an <iframe>.
class YoutubePlayerView extends StatelessWidget {
  const YoutubePlayerView({super.key, required this.videoId, this.start});

  final String videoId;
  final int? start;

  @override
  Widget build(BuildContext context) {
    final viewType = 'youtube-$videoId-${start ?? 0}';
    if (_registered.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int id) {
        final params = 'autoplay=1&rel=0&modestbranding=1${start != null ? '&start=$start' : ''}';
        return web.HTMLIFrameElement()
          ..src = 'https://www.youtube-nocookie.com/embed/$videoId?$params'
          ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
          ..allowFullscreen = true
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
      });
    }
    return HtmlElementView(viewType: viewType);
  }
}
