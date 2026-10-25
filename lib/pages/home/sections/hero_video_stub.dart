import 'package:flutter/material.dart';

/// Outside the browser (e.g. tests) the showreel is an empty frame.
class HeroVideo extends StatelessWidget {
  const HeroVideo({super.key, required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(radius)));
  }
}

/// No video to glow with outside the browser.
class HeroGlow extends StatelessWidget {
  const HeroGlow({super.key, required this.bright});

  final bool bright;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
