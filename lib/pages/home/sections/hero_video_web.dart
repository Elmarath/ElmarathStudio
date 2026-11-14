import 'dart:async';
import 'dart:js_interop';
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../config/site_config.dart';

/// The home page showreel, like the one on unrealengine.com: [SiteConfig.heroVideos]
/// play one after another on a loop in a rounded frame.
///
/// It's an HTML <video>, so the browser plays it without Flutter redrawing the
/// page for every video frame. It covers exactly the frame: Flutter has to draw
/// anything that overlaps an HTML element in an extra layer on every frame, so
/// the glow around it is drawn by Flutter instead ([HeroGlow]).
class HeroVideo extends StatelessWidget {
  const HeroVideo({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    if (_registered.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId, {Object? params}) {
        final settings = params! as Map<Object?, Object?>;
        return _Showreel(radius: (settings['radius']! as num).toDouble()).root;
      });
    }
    // Plain values: they travel through Flutter's platform view channel.
    return HtmlElementView(viewType: _viewType, creationParams: {'radius': radius});
  }
}

const _viewType = 'hero-showreel';
final _registered = <String>{};

class _Showreel {
  _Showreel({required double radius}) {
    final clips = SiteConfig.heroVideos;
    // Decorative: clicks and scrolling go through to the page.
    root.style.cssText =
        'position:relative;width:100%;height:100%;pointer-events:none;opacity:0;transition:opacity .8s ease';
    video
      ..muted = true
      ..playsInline = true
      ..preload = 'auto'
      ..loop = clips.length == 1
      ..style.cssText =
          'display:block;width:100%;height:100%;object-fit:cover;border-radius:${radius}px;'
          'background:#000;transition:opacity .35s ease';
    // Safari only autoplays when these are attributes, not just properties.
    video
      ..setAttribute('muted', '')
      ..setAttribute('playsinline', '');
    root.append(video);

    video.addEventListener(
      'loadeddata',
      ((web.Event _) {
        root.style.opacity = '1';
        shown.value = video.getAttribute('src');
      }).toJS,
    );
    video.addEventListener('playing', ((web.Event _) => video.style.opacity = '1').toJS);
    // On to the next clip: fade out, swap, and fade back in once it plays.
    video.addEventListener(
      'ended',
      ((web.Event _) {
        video.style.opacity = '0';
        Timer(const Duration(milliseconds: 350), () => _show(_clip + 1));
      }).toJS,
    );
    _show(0);
    _observer.observe(root);
  }

  /// The clip on show, once its first frame is in: [HeroGlow] glows with it.
  static final shown = ValueNotifier<String?>(null);

  final root = web.HTMLDivElement();
  final video = web.HTMLVideoElement();
  int _clip = 0;
  bool _visible = false;

  /// With "reduce motion" on, the first clip's still stays put.
  static final _reduceMotion = web.window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  late final _observer = web.IntersectionObserver(
    ((JSArray<web.IntersectionObserverEntry> entries, web.IntersectionObserver _) {
      // Not in the page (yet, or any more, e.g. while it's being swapped in
      // after Back): just wait, so it plays again once it's back on screen.
      _visible = root.isConnected && entries.toDart.last.isIntersecting;
      _update();
    }).toJS,
  );

  void _show(int index) {
    final clips = SiteConfig.heroVideos;
    _clip = index % clips.length;
    video
      ..poster = _posterOf(clips[_clip])
      ..src = clips[_clip];
    _update();
  }

  /// Plays only while it's on screen: off screen it would still cost the
  /// browser decoding.
  void _update() {
    if (_visible && !_reduceMotion) {
      video.play().toDart.catchError((Object _) => null); // autoplay can be blocked, e.g. in Low Power Mode
    } else {
      video.pause();
    }
  }
}

/// A clip's still: the same name, as a .jpg.
String _posterOf(String clip) => clip.replaceFirst(RegExp(r'\.\w+$'), '.jpg');

/// The glow behind the showreel, made the way unrealengine.com makes it: the
/// clip blurred into a wash of its colours (80px on a 978px video there) that
/// fades out at twice the blur. Lay it out in a box the size of the video; the
/// glow spreads past it.
///
/// Each clip's glow is made once, from its poster, and cross-fades in when the
/// clip comes on. Unreal's follows every frame, but copying video frames out
/// and blurring them several times a second stalls Safari's GPU and redraws
/// the page each time, which made scrolling stutter. Blurred this much, a
/// clip's colours barely change while it plays.
class HeroGlow extends StatefulWidget {
  const HeroGlow({super.key, required this.bright});

  /// On a light page: dark parts fade out, so it reads as coloured light
  /// rather than a grey shadow.
  final bool bright;

  @override
  State<HeroGlow> createState() => _HeroGlowState();
}

class _HeroGlowState extends State<HeroGlow> {
  static const _width = 128;
  static const _height = 72;
  static const _sigma = _width * 80 / 978; // as on unrealengine.com
  static const _margin = 22; // twice the blur, where Unreal's glow ends

  /// Made glows, by clip and brightness: a few small pictures, kept for the visit.
  static final _glows = <(String, bool), Future<ui.Image?>>{};

  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _Showreel.shown.addListener(_update);
    _update();
  }

  @override
  void didUpdateWidget(HeroGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bright != widget.bright) _update();
  }

  @override
  void dispose() {
    _Showreel.shown.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final clip = _Showreel.shown.value;
    if (clip == null) return;
    final bright = widget.bright;
    _glows.putIfAbsent((clip, bright), () => _make(_posterOf(clip), bright)).then((image) {
      // Only if it's still the one wanted: clips can move on while one is made.
      if (image != null && mounted && clip == _Showreel.shown.value && bright == widget.bright) {
        setState(() => _image = image);
      }
    });
  }

  static Future<ui.Image?> _make(String poster, bool bright) async {
    try {
      final frame = await _decode(poster);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(
        frame,
        Rect.fromLTWH(0, 0, frame.width.toDouble(), frame.height.toDouble()),
        const Rect.fromLTWH(_margin + 0.0, _margin + 0.0, _width + 0.0, _height + 0.0),
        Paint()
          ..filterQuality = FilterQuality.medium
          // Decal: outside the frame is see-through, so the glow fades out
          // (the default would smear the frame's edges out to the corners).
          ..imageFilter = ui.ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma, tileMode: TileMode.decal)
          // Opacity from brightness, at most about a third.
          ..colorFilter =
              bright ? const ColorFilter.matrix([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, .18, .27, .15, 0, 0]) : null,
      );
      final picture = recorder.endRecording();
      try {
        return await picture.toImage(_width + 2 * _margin, _height + 2 * _margin);
      } finally {
        picture.dispose();
        frame.dispose();
      }
    } catch (_) {
      return null; // No poster, no glow.
    }
  }

  /// [source] decoded at the size it's blurred at.
  static Future<ui.Image> _decode(String source) {
    final completer = Completer<ui.Image>();
    final stream = ResizeImage(NetworkImage(source), width: _width).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        completer.complete(info.image.clone());
        info.dispose();
      },
      onError: (error, stack) {
        stream.removeListener(listener);
        completer.completeError(error, stack);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    // Its own picture: the cross-fade redraws only the glow, not the page.
    return RepaintBoundary(
      // The picture's margins hang out past the box, so the glow fades out around it.
      child: FractionallySizedBox(
        widthFactor: (_width + 2 * _margin) / _width,
        heightFactor: (_height + 2 * _margin) / _height,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
          child:
              image == null
                  ? const SizedBox.shrink()
                  : RawImage(key: ValueKey(image), image: image, fit: BoxFit.fill, filterQuality: FilterQuality.high),
        ),
      ),
    );
  }
}
