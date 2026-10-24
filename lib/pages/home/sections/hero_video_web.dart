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
/// [glow] logical pixels around it for the glow.
class HeroVideo extends StatelessWidget {
  const HeroVideo({super.key, required this.glow, required this.radius});

  final double glow;
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
        return _Showreel(
          glow: (settings['glow']! as num).toDouble(),
          radius: (settings['radius']! as num).toDouble(),
          bright: bright,
        ).root;
      });
    }
    // Plain values: they travel through Flutter's platform view channel.
    return HtmlElementView(viewType: viewType, creationParams: {'glow': glow, 'radius': radius});
  }
}

final _registered = <String>{};

class _Showreel {
  _Showreel({required double glow, required double radius, required bool bright}) : _bright = bright {
    final clips = SiteConfig.heroVideos;
    // Decorative: clicks and scrolling go through to the page.
    root.style.cssText =
        'position:relative;width:100%;height:100%;pointer-events:none;opacity:0;transition:opacity .8s ease';
    // A tiny copy of the video, blown up past the frame and blurred by the
    // browser into a wash of its colours. It spreads [glow] pixels out at most,
    // so the blur fades out inside this element rather than being cut off.
    final spread = glow * 0.45;
    glowCanvas
      ..width = 32
      ..height = 18
      ..style.cssText =
          'position:absolute;left:${glow - spread}px;top:${glow - spread}px;'
          'width:calc(100% - ${2 * (glow - spread)}px);height:calc(100% - ${2 * (glow - spread)}px);'
          'filter:blur(${glow * 0.22}px) ${bright ? 'saturate(1.8);opacity:.6' : 'saturate(1.3);opacity:.75'}';
    video
      ..muted = true
      ..playsInline = true
      ..preload = 'auto'
      ..loop = clips.length == 1
      ..style.cssText =
          'position:absolute;left:${glow}px;top:${glow}px;'
          'width:calc(100% - ${2 * glow}px);height:calc(100% - ${2 * glow}px);'
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
      if (!root.isConnected) return _stop(); // gone with the page
      _visible = entries.toDart.last.isIntersecting;
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
      _paintGlow();
    }
  }

  void _paintGlow() {
    if (!root.isConnected) {
      if (_glowTimer != null) _stop(); // gone with the page
      return;
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

  void _stop() {
    _glowTimer?.cancel();
    _glowTimer = null;
    _observer.disconnect();
    video.pause();
  }
}
