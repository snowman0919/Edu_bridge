import 'dart:math' as math;

class AppFormatters {
  static final RegExp _grouping = RegExp(r'\B(?=(\d{3})+(?!\d))');

  static String wholeNumber(num value) {
    return value.round().toString().replaceAllMapped(_grouping, (match) => ',');
  }

  static String compactPeople(num value) {
    final absolute = value.abs();
    if (absolute >= 100000000) {
      return '${_trim(value / 100000000)}억명';
    }
    if (absolute >= 10000) {
      return '${_trim(value / 10000)}만명';
    }
    return '${wholeNumber(value)}명';
  }

  static String compactCount(num value, {String suffix = ''}) {
    return '${wholeNumber(value)}$suffix';
  }

  static String decimal(num value, {int digits = 1}) {
    return _trim(value.toDouble(), digits: digits);
  }

  static String percentFromRatio(num value, {int digits = 0}) {
    return '${_trim(value * 100, digits: digits)}%';
  }

  static String compactIncome(num value) {
    if (value.abs() >= 10000) {
      return '${_trim(value / 10000)}만원';
    }
    return '${wholeNumber(value)}원';
  }

  static String topPercent(double percentile) {
    final rank = math.max(1, ((1 - percentile) * 100).round());
    return 'TOP $rank%';
  }

  static String severityLabel(double severity) {
    if (severity >= 0.72) {
      return '높음';
    }
    if (severity >= 0.42) {
      return '보통';
    }
    return '낮음';
  }

  static String comparisonLabel(double primary, double secondary) {
    final larger = math.max(primary, secondary);
    final gap = larger == 0 ? 0 : (primary - secondary).abs() / larger;
    if (gap < 0.12) {
      return '비슷함';
    }
    if (primary > secondary) {
      return '비교 우세';
    }
    return '상대적으로 부족';
  }

  static String _trim(double value, {int digits = 1}) {
    final text = value.toStringAsFixed(digits);
    if (text.endsWith('.0')) {
      return text.substring(0, text.length - 2);
    }
    return text;
  }
}
