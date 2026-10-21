import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'content/content_repository.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  // Clean URLs: /docs/intro instead of /#/docs/intro.
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  final (content, theme, _) = await (
    ContentRepository.load(rootBundle),
    ThemeController.load(),
    AppTheme.preloadFonts(),
  ).wait;

  runApp(ElmarathApp(content: content, theme: theme));
}
