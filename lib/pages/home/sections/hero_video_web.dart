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
    current = this;
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

    video.addEventListener('loadeddata', ((web.Event _) => root.style.opacity = '1').toJS);
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

  /// The newest showreel: the one on the page, for [HeroGlow].
  static _Showreel? current;

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
      ..poster = clips[_clip].replaceFirst(RegExp(r'\.\w+$'), '.jpg')
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

/// The glow behind the showreel, made the way unrealengine.com makes it: the
/// frame playing, blurred into a wash of its colours (80px on a 978px video
/// there) that fades out at twice the blur. Lay it out in a box the size of
/// the video; the glow spreads past it.
///
/// Ten times a second while the video plays, the frame is copied into a small
/// canvas and blurred once into a picture, which Flutter then just draws: it
/// costs nothing while the page scrolls.
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

  final _frame = web.HTMLCanvasElement()
    ..width = _width
    ..height = _height;
  late final _context = _frame.getContext('2d')! as web.CanvasRenderingContext2D;
  late final Timer _timer;
  ui.Image? _image;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer.cancel();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final video = _Showreel.current?.video;
    // A new picture only while the video plays (it pauses off screen), and a
    // first one as soon as there's a frame.
    if (_busy || video == null || video.readyState < 2 || (video.paused && _image != null)) return;
    _busy = true;
    try {
      _context.drawImage(video, 0, 0, _width, _height);
      final frame = await ui_web.createImageFromTextureSource(_frame, width: _width, height: _height);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImage(
        frame,
        const Offset(_margin + 0.0, _margin + 0.0),
        Paint()
          // Decal: outside the frame is see-through, so the glow fades out
          // (the default would smear the frame's edges out to the corners).
          ..imageFilter = ui.ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma, tileMode: TileMode.decal)
          // Opacity from brightness, at most about a third.
          ..colorFilter =
              widget.bright
                  ? const ColorFilter.matrix([1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, .18, .27, .15, 0, 0])
                  : null,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(_width + 2 * _margin, _height + 2 * _margin);
      picture.dispose();
      frame.dispose();
      if (!mounted) return image.dispose();
      final old = _image;
      setState(() => _image = image);
      old?.dispose();
    } catch (_) {
      // No glow this time (e.g. the video isn't ready); the next tick tries again.
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) return const SizedBox.shrink();
    // The picture's margins hang out past the box, so the glow fades out around it.
    return FractionallySizedBox(
      widthFactor: (_width + 2 * _margin) / _width,
      heightFactor: (_height + 2 * _margin) / _height,
      child: RawImage(image: image, fit: BoxFit.fill, filterQuality: FilterQuality.high),
    );
  }
}
