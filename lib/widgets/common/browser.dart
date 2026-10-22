// Which browser the site is running in, where that changes what's worth doing.
export 'browser_stub.dart' if (dart.library.js_interop) 'browser_web.dart';
