import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_image.dart';

/// A soft, heavily blurred copy of an image, for backgrounds.
///
/// The blur is worked out once per image and kept, then drawn like any other
/// picture. A live blur filter would be redone on every frame, which makes
/// scrolling stutter on the web.
class BlurredImage extends StatefulWidget {
  const BlurredImage(this.source, {super.key});

  /// An asset path or URL, like [AppImage.source].
  final String source;

  /// Blurs [source] ahead of time, so it shows right away when it's needed.
  static void precache(String source) => _blurred(source);

  // The image is drawn this wide when it's blurred: plenty for something this
  // soft, and quick to blur.
  static const _width = 128;
  static const _sigma = 6.0;

  static final _done = <String, ui.Image>{};
  static final _pending = <String, Future<ui.Image?>>{};

  static Future<ui.Image?> _blurred(String source) => _pending.putIfAbsent(source, () async {
    try {
      return _done[source] = await _blur(await _decode(AppImage.providerFor(source)));
    } catch (_) {
      return null; // A missing image just leaves the background empty.
    }
  });

  /// Gets the image the same way [AppImage] does, so the two share one download
  /// and one decoded copy.
  static Future<ui.Image> _decode(ImageProvider provider) {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        final image = info.image.clone();
        info.dispose();
        stream.removeListener(listener);
        completer.complete(image);
      },
      onError: (error, stack) {
        stream.removeListener(listener);
        completer.completeError(error, stack);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  static Future<ui.Image> _blur(ui.Image image) async {
    final height = (_width * image.height / image.width).roundToDouble();
    // The edges are cut off: blurring there mixes in the empty space around the image.
    const margin = _sigma * 2;
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(-margin, -margin, _width.toDouble(), height),
      Paint()
        ..filterQuality = FilterQuality.medium
        ..imageFilter = ui.ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
    );
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(
        (_width - margin * 2).round(),
        math.max(1, (height - margin * 2).round()),
      );
    } finally {
      picture.dispose();
      image.dispose();
    }
  }

  @override
  State<BlurredImage> createState() => _BlurredImageState();
}

class _BlurredImageState extends State<BlurredImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _show();
  }

  @override
  void didUpdateWidget(BlurredImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _show();
  }

  void _show() {
    final source = widget.source;
    _image = BlurredImage._done[source];
    if (_image != null) return;
    BlurredImage._blurred(source).then((image) {
      if (mounted && source == widget.source) setState(() => _image = image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _image == null ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      // Plain (bilinear) scaling is enough for something already this soft, and
      // much cheaper to draw on every frame than smoother (cubic) scaling.
      child: RawImage(image: _image, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
    );
  }
}
