import 'package:flutter/material.dart';

import '../../widgets/layout/content_width.dart';
import 'sections/contact_section.dart';
import 'sections/features_section.dart';
import 'sections/hero_section.dart';
import 'sections/latest_posts_section.dart';
import 'sections/spotlight_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// The home page, top to bottom. Reorder, remove or add sections here.
  static const List<Widget> sections = [
    HeroSection(),
    FeaturesSection(),
    SpotlightSection(),
    LatestPostsSection(),
    ContactSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return const PageTitle(title: null, child: PageScroll(children: sections));
  }
}
