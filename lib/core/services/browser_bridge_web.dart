// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'browser_bridge.dart';

class WebBrowserBridge implements BrowserBridge {
  static const Map<String, String> _provinceAlias = <String, String>{
    '서울': '서울특별시',
    '부산': '부산광역시',
    '대구': '대구광역시',
    '인천': '인천광역시',
    '광주': '광주광역시',
    '대전': '대전광역시',
    '울산': '울산광역시',
    '세종': '세종특별자치시',
    '경기': '경기도',
    '강원': '강원특별자치도',
    '충북': '충청북도',
    '충남': '충청남도',
    '전북': '전북특별자치도',
    '전남': '전라남도',
    '경북': '경상북도',
    '경남': '경상남도',
    '제주': '제주특별자치도',
  };

  @override
  Future<BrowserLocationResult> detectCurrentRegion(
    Iterable<String> regionNames,
  ) async {
    try {
      final position = await _getCurrentPosition();
      final coords = position.coords;
      final latitude = coords?.latitude;
      final longitude = coords?.longitude;
      if (latitude == null || longitude == null) {
        return const BrowserLocationResult(
          regionName: null,
          message: '현재 위치 좌표를 읽지 못했습니다. 지역을 직접 선택해 주세요.',
        );
      }
      final uri =
          Uri.https('nominatim.openstreetmap.org', '/reverse', <String, String>{
            'format': 'jsonv2',
            'lat': '$latitude',
            'lon': '$longitude',
            'zoom': '10',
            'addressdetails': '1',
            'accept-language': 'ko',
          });

      final response = await html.HttpRequest.request(
        uri.toString(),
        method: 'GET',
        requestHeaders: const <String, String>{'Accept': 'application/json'},
      );
      final body = response.responseText;
      if (body == null || body.isEmpty) {
        return const BrowserLocationResult(
          regionName: null,
          message: '위치 응답을 읽지 못했습니다. 지역을 직접 선택해 주세요.',
        );
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final address =
          (json['address'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};

      final provinceToken = _normalizeProvince(
        _firstNonEmpty(<dynamic>[
          address['state'],
          address['province'],
          address['region'],
        ]),
      );
      final districtCandidates = _districtCandidates(<dynamic>[
        address['city_district'],
        address['borough'],
        address['county'],
        address['city'],
        address['town'],
        address['municipality'],
        address['suburb'],
      ]);
      final districtToken = districtCandidates.isEmpty
          ? null
          : districtCandidates.first;

      final matched = _matchRegion(
        regionNames: regionNames,
        provinceToken: provinceToken,
        districtCandidates: districtCandidates,
      );
      if (matched != null) {
        return BrowserLocationResult(regionName: matched, message: matched);
      }

      return BrowserLocationResult(
        regionName: null,
        message: districtToken == null
            ? '브라우저 위치는 확인했지만 행정구역을 매칭하지 못했습니다.'
            : '현재 위치로 추정한 지역은 ${_humanizeProvince(provinceToken)} $districtToken 입니다. 직접 선택해 주세요.',
      );
    } on html.PositionError catch (error) {
      return BrowserLocationResult(
        regionName: null,
        granted: false,
        message: error.message ?? '위치 권한을 허용하지 않아 현재 위치를 사용할 수 없습니다.',
      );
    } catch (_) {
      return const BrowserLocationResult(
        regionName: null,
        message: '현재 위치를 가져오는 중 오류가 발생했습니다. 지역을 직접 선택해 주세요.',
      );
    }
  }

  @override
  Future<bool> downloadTextFile({
    required String filename,
    required String content,
  }) async {
    final blob = html.Blob(<String>[content], 'text/plain;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  }

  @override
  Future<bool> openExternalUrl(String url) async {
    html.window.open(url, '_blank');
    return true;
  }

  Future<html.Geoposition> _getCurrentPosition() {
    return html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 8),
      maximumAge: const Duration(minutes: 5),
    );
  }

  String? _matchRegion({
    required Iterable<String> regionNames,
    required String? provinceToken,
    required List<String> districtCandidates,
  }) {
    String? bestMatch;
    var bestScore = -1;

    for (final regionName in regionNames) {
      final simplified = _simplify(regionName);
      var score = 0;

      if (provinceToken != null) {
        final provinceName = _provinceAlias[provinceToken] ?? provinceToken;
        if (regionName.startsWith(provinceName) ||
            simplified.contains(provinceToken)) {
          score += 4;
        }
      }

      for (final districtToken in districtCandidates) {
        if (regionName.contains(districtToken)) {
          score += 10;
          break;
        }

        final simplifiedToken = _simplify(districtToken);
        if (simplified.contains(simplifiedToken)) {
          score += 8;
          break;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = regionName;
      }
    }

    return bestScore >= 8 ? bestMatch : null;
  }

  List<String> _districtCandidates(Iterable<dynamic> values) {
    final result = <String>[];
    final seen = <String>{};

    for (final value in values) {
      final normalized = _normalizeDistrict(value is String ? value : null);
      if (normalized == null) {
        continue;
      }
      if (seen.add(normalized)) {
        result.add(normalized);
      }
    }

    return result;
  }

  String _simplify(String value) {
    return value
        .replaceAll('특별자치도', '')
        .replaceAll('특별자치시', '')
        .replaceAll('특별시', '')
        .replaceAll('광역시', '')
        .replaceAll(RegExp(r'\s+'), '');
  }

  String? _normalizeProvince(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final simplified = _simplify(value);
    for (final entry in _provinceAlias.entries) {
      if (simplified.startsWith(entry.key)) {
        return entry.key;
      }
    }
    return simplified;
  }

  String? _normalizeDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final trimmed = value.replaceAll(RegExp(r'\s+'), '');
    if (trimmed == '대한민국' || trimmed == 'SouthKorea') {
      return null;
    }
    return trimmed;
  }

  String _humanizeProvince(String? provinceToken) {
    if (provinceToken == null) {
      return '현재 위치';
    }
    return _provinceAlias[provinceToken] ?? provinceToken;
  }

  String? _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

BrowserBridge createBrowserBridgeImpl() => WebBrowserBridge();
