import '../../data/models/region_metrics.dart';
import '../../data/models/region_report.dart';
import 'formatters.dart';

class ReportExportFormatter {
  static String buildRegionReport({
    required RegionMetrics region,
    required RegionReport report,
  }) {
    final buffer = StringBuffer()
      ..writeln('EduBridge 지역 교육 기회 리포트')
      ..writeln()
      ..writeln('지역: ${region.regionName}')
      ..writeln('교육 기회 점수: ${report.score}/100 (${report.opportunityLabel})')
      ..writeln('요약: ${report.summary}')
      ..writeln()
      ..writeln('[핵심 지표]')
      ..writeln(
        '- 학교 수: ${AppFormatters.compactCount(region.schoolCount, suffix: '개')}',
      )
      ..writeln('- 학생 수: ${AppFormatters.compactPeople(region.studentCount)}')
      ..writeln(
        '- 학원 수: ${AppFormatters.compactCount(region.academyCount, suffix: '개')}',
      )
      ..writeln('- 지역 인구: ${AppFormatters.compactPeople(region.population)}')
      ..writeln(
        '- 학생 1,000명당 학원 수: ${AppFormatters.decimal(region.academyPer1000Students)}개',
      )
      ..writeln(
        '- 학교당 학생 수: ${AppFormatters.decimal(region.avgStudentsPerSchool)}명',
      )
      ..writeln(
        '- 평균 소득 지표: ${AppFormatters.compactIncome(region.pensionAvgIncome)}',
      )
      ..writeln()
      ..writeln('[주요 해석]')
      ..writeln('- 하이라이트: ${report.highlight}')
      ..writeln('- 강점: ${report.strengthSummary}')
      ..writeln('- 보완 필요: ${report.weaknessSummary}')
      ..writeln('- 전문가 어드바이스: ${report.expertAdvice}')
      ..writeln()
      ..writeln('[부족할 수 있는 부분]');

    for (final issue in report.gapIssues) {
      buffer
        ..writeln('- ${issue.title}: ${issue.description}')
        ..writeln('  심각도: ${AppFormatters.severityLabel(issue.severity)}');
    }

    buffer
      ..writeln()
      ..writeln('[추천 지원 방향]');
    for (final direction in report.supportDirections) {
      buffer.writeln('- ${direction.title}: ${direction.description}');
    }

    buffer
      ..writeln()
      ..writeln('[추천 학습 기회]');
    for (final item in report.recommendations) {
      buffer
        ..writeln('- ${item.title}')
        ..writeln('  제공처: ${item.provider}')
        ..writeln('  설명: ${item.description}')
        ..writeln('  추천 이유: ${item.reason}')
        ..writeln('  연결: ${item.resourceLabel} (${item.resourceUrl})');
    }

    buffer
      ..writeln()
      ..writeln('출처 범위: ${region.sourceScope}');

    return buffer.toString();
  }
}
