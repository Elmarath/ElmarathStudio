import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/tokens.dart';
import '../common/app_image.dart';
import '../common/links.dart';
import 'youtube_player_stub.dart' if (dart.library.js_interop) 'youtube_player_web.dart';

/// A YouTube video. Shows the thumbnail first and loads the player on click,
/// so pages with several videos stay fast.
class YoutubeEmbed extends StatefulWidget {
  const YoutubeEmbed({super.key, required this.videoId, this.start});

  final String videoId;
  final int? start;

  @override
  State<YoutubeEmbed> createState() => _YoutubeEmbedState();
}

class _YoutubeEmbedState extends State<YoutubeEmbed> {
  bool _playing = false;

  String get _watchUrl =>
      'https://www.youtube.com/watch?v=${widget.videoId}${widget.start != null ? '&t=${widget.start}s' : ''}';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: Radii.mdAll,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black, border: Border.all(color: p.border)),
          child: _playing && supportsInlinePlayer
              ? YoutubePlayerView(videoId: widget.videoId, start: widget.start)
              : _Poster(
                  videoId: widget.videoId,
                  onPlay: () => supportsInlinePlayer ? setState(() => _playing = true) : openLink(context, _watchUrl),
                ),
        ),
      ),
    );
  }
}

class _Poster extends StatefulWidget {
  const _Poster({required this.videoId, required this.onPlay});

  final String videoId;
  final VoidCallback onPlay;

  @override
  State<_Poster> createState() => _PosterState();
}

class _PosterState extends State<_Poster> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play video',
      child: InkWell(
        onTap: widget.onPlay,
        onHover: (h) => setState(() => _hovered = h),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage('https://i.ytimg.com/vi/${widget.videoId}/hqdefault.jpg'),
            AnimatedContainer(
              duration: Motion.normal,
              color: Colors.black.withValues(alpha: _hovered ? 0.15 : 0.35),
            ),
            Center(
              child: AnimatedScale(
                scale: _hovered ? 1.1 : 1,
                duration: Motion.normal,
                curve: Motion.curve,
                child: Container(
                  width: 72,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0033),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
