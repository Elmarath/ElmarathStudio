import 'package:flutter/material.dart';

/// Outside the browser (e.g. tests) the showreel is an empty frame.
class HeroVideo extends StatelessWidget {
  const HeroVideo({super.key, required this.glow, required this.radius});

  final double glow;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(glow),
      child: DecoratedBox(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(radius))),
    );
  }
}
