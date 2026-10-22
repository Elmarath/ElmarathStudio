import 'dart:ui_web' as ui_web;

/// Safari, and every browser on iPhone and iPad (they all use Safari's engine).
/// It redraws the page noticeably slower than Chrome or Firefox.
final bool isSafariEngine = ui_web.browser.browserEngine == ui_web.BrowserEngine.webkit;
