import 'package:flutter/material.dart';

/// Outside the browser (e.g. tests) the showreel is an empty frame.
class HeroVideo extends StatelessWidget {
  const HeroVideo({super.key, required this.blur, required this.shift, required this.radius});

  final double blur;
  final double shift;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(shift + 2 * blur, 2 * blur, 2 * blur, 2 * blur),
      child: DecoratedBox(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(radius))),
    );
  }
}
