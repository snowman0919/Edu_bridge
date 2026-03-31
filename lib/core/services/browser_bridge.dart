import 'browser_bridge_stub.dart'
    if (dart.library.html) 'browser_bridge_web.dart';

class BrowserLocationResult {
  const BrowserLocationResult({
    required this.regionName,
    required this.message,
    this.granted = true,
  });

  final String? regionName;
  final String message;
  final bool granted;
}

abstract class BrowserBridge {
  Future<BrowserLocationResult> detectCurrentRegion(
    Iterable<String> regionNames,
  );

  Future<bool> openExternalUrl(String url);

  Future<bool> downloadTextFile({
    required String filename,
    required String content,
  });
}

BrowserBridge createBrowserBridge() => createBrowserBridgeImpl();
