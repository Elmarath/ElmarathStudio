import 'package:flutter/widgets.dart';

/// Outside the browser (e.g. tests) videos open on youtube.com instead.
const bool supportsInlinePlayer = false;

class YoutubePlayerView extends StatelessWidget {
  const YoutubePlayerView({super.key, required this.videoId, this.start});

  final String videoId;
  final int? start;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
