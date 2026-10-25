import 'package:flutter/widgets.dart';

/// The few brand logos the site shows, from Font Awesome's brands font
/// (`assets/fonts/fa-brands-400.ttf`). The whole Font Awesome package would also
/// download its solid and regular fonts, which the page waits for on startup.
abstract final class BrandIcons {
  static const discord = IconData(0xf392, fontFamily: 'BrandIcons');
  static const github = IconData(0xf09b, fontFamily: 'BrandIcons');
  static const linkedin = IconData(0xf08c, fontFamily: 'BrandIcons');
  static const xTwitter = IconData(0xe61b, fontFamily: 'BrandIcons');
  static const youtube = IconData(0xf167, fontFamily: 'BrandIcons');
}
