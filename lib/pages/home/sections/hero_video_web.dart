import 'dart:async';
import 'dart:js_interop';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../../config/site_config.dart';

/// The home page showreel, like the one on unrealengine.com: [SiteConfig.heroVideos]
/// play one after another on a loop in a rounded frame, with a soft glow of
/// the video behind it.
///
/// It's an HTML <video>, so the browser plays it (and blurs the glow) without
/// Flutter redrawing the page for every video frame. It covers the frame plus
/// room for the glow: twice [blur] around it, and [shift] more on the left.
class HeroVideo extends StatelessWidget {
  const HeroVideo({super.key, required this.blur, required this.shift, required this.radius});

  /// How much the glow is blurred.
  final double blur;

  /// How far left of the video the glow is centred.
  final double shift;
  final double radius;

  @override
  Widget build(BuildContext context) {
    // One view type per brightness, so switching themes makes a new element
    // with the right glow.
    final bright = Theme.of(context).brightness == Brightness.light;
    final viewType = bright ? 'hero-showreel-bright' : 'hero-showreel-dark';
    if (_registered.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId, {Object? params}) {
        final settings = params! as Map<Object?, Object?>;
        double setting(String name) => (settings[name]! as num).toDouble();
        return _Showreel(
          blur: setting('blur'),
          shift: setting('shift'),
          radius: setting('radius'),
          bright: bright,
        ).root;
      });
    }
    // Plain values: they travel through Flutter's platform view channel.
    return HtmlElementView(
      viewType: viewType,
      creationParams: {'blur': blur, 'shift': shift, 'radius': radius},
    );
  }
}

final _registered = <String>{};

class _Showreel {
  _Showreel({required double blur, required double shift, required double radius, required bool bright})
    : _bright = bright {
    final clips = SiteConfig.heroVideos;
    // Decorative: clicks and scrolling go through to the page.
    root.style.cssText =
        'position:relative;width:100%;height:100%;pointer-events:none;opacity:0;transition:opacity .8s ease';
    // The glow, made the way unrealengine.com makes it: a tiny copy of the
    // video, as big as the video but [shift]ed left, blurred by the browser into
    // a wash of its colours. The blur fades out within twice [blur], inside
    // this element rather than being cut off at its edge.
    final margin = 2 * blur;
    final size = 'width:calc(100% - ${shift + 2 * margin}px);height:calc(100% - ${2 * margin}px)';
    glowCanvas
      ..width = 32
      ..height = 18
      ..style.cssText =
          'position:absolute;left:${margin}px;top:${margin}px;$size;'
          // Unreal's own colours at full strength; on a light page, coloured light.
          'filter:blur(${blur}px)${bright ? ' saturate(1.8);opacity:.6' : ''}';
    video
      ..muted = true
      ..playsInline = true
      ..preload = 'auto'
      ..loop = clips.length == 1
      ..style.cssText =
          'position:absolute;left:${shift + margin}px;top:${margin}px;$size;'
          'object-fit:cover;border-radius:${radius}px;background:#000;transition:opacity .35s ease';
    // Safari only autoplays when these are attributes, not just properties.
    video
      ..setAttribute('muted', '')
      ..setAttribute('playsinline', '');
    root
      ..append(glowCanvas)
      ..append(video);

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

  final root = web.HTMLDivElement();
  final glowCanvas = web.HTMLCanvasElement();
  final video = web.HTMLVideoElement();
  final bool _bright;
  late final _glow =
      glowCanvas.getContext('2d', {'willReadFrequently': _bright}.jsify()!)! as web.CanvasRenderingContext2D;
  int _clip = 0;
  Timer? _glowTimer;
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
  /// browser decoding and the glow updates.
  void _update() {
    if (_visible && !_reduceMotion) {
      video.play().toDart.catchError((Object _) => null); // autoplay can be blocked, e.g. in Low Power Mode
      _glowTimer ??= Timer.periodic(const Duration(milliseconds: 100), (_) => _paintGlow());
    } else {
      video.pause();
      _glowTimer?.cancel();
      _glowTimer = null;
      if (root.isConnected) _paintGlow();
    }
  }

  void _paintGlow() {
    if (!root.isConnected) {
      _visible = false;
      return _update(); // gone with the page: stops playing until it's back
    }
    if (video.readyState < 2) return; // no frame yet
    _glow.drawImage(video, 0, 0, 32, 18);
    if (_bright) _fadeDarkPixels();
  }

  /// On a light page the video's dark parts would glow as a grey shadow, so
  /// each pixel fades out by how dark it is and only the colours are left.
  void _fadeDarkPixels() {
    final pixels = _glow.getImageData(0, 0, 32, 18).data.toDart;
    for (var i = 0; i < pixels.length; i += 4) {
      pixels[i + 3] = math.max(pixels[i], math.max(pixels[i + 1], pixels[i + 2]));
    }
    _glow.putImageData(web.ImageData(pixels.toJS, 32), 0, 0);
  }
}
