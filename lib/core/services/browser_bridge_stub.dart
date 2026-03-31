import 'browser_bridge.dart';

class StubBrowserBridge implements BrowserBridge {
  @override
  Future<BrowserLocationResult> detectCurrentRegion(
    Iterable<String> regionNames,
  ) async {
    return const BrowserLocationResult(
      regionName: null,
      granted: false,
      message: '현재 위치 자동 선택은 웹 브라우저 배포 환경에서 사용할 수 있습니다.',
    );
  }

  @override
  Future<bool> openExternalUrl(String url) async {
    return false;
  }

  @override
  Future<bool> downloadTextFile({
    required String filename,
    required String content,
  }) async {
    return false;
  }
}

BrowserBridge createBrowserBridgeImpl() => StubBrowserBridge();
