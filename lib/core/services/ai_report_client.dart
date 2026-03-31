import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/models/region_metrics.dart';
import '../../data/models/region_report.dart';
import '../../data/models/student_scores.dart';

class AiReportClient {
  const AiReportClient();

  Future<String?> generateReport({
    required RegionMetrics region,
    required RegionReport report,
    StudentScores? studentScores,
  }) async {
    final response = await http.post(
      Uri(path: '/api/ai-report'),
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'prompt': _buildPrompt(
          region: region,
          report: report,
          studentScores: studentScores,
        ),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('AI report request failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid AI report response');
    }
    final content = json['content'];
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }
    return null;
  }

  String _buildPrompt({
    required RegionMetrics region,
    required RegionReport report,
    required StudentScores? studentScores,
  }) {
    final buffer = StringBuffer()
      ..writeln('당신은 한국 공공서비스형 교육 분석 리포트를 작성하는 정책 분석가이자 학습 코치다.')
      ..writeln('반드시 한국어로만 작성한다.')
      ..writeln('과장 없이, 행정 안내문처럼 정확하고 차분한 톤을 유지한다.')
      ..writeln('불필요한 서론 없이 바로 본문을 작성한다.')
      ..writeln('마크다운 제목과 불릿을 사용한다.')
      ..writeln()
      ..writeln('다음 형식으로만 작성한다:')
      ..writeln('1. 제목')
      ..writeln('2. 지역 진단 요약')
      ..writeln('3. 세부 수치 해설')
      ..writeln('4. 국영수 학습 전략')
      ..writeln('5. 우선 추천 리소스')
      ..writeln('6. 이번 주 실행 계획')
      ..writeln()
      ..writeln('지역 데이터:')
      ..writeln('- 지역명: ${region.regionName}')
      ..writeln('- 학교 수: ${region.schoolCount.toStringAsFixed(0)}')
      ..writeln('- 학생 수: ${region.studentCount.toStringAsFixed(0)}')
      ..writeln('- 학원 수: ${region.academyCount.toStringAsFixed(0)}')
      ..writeln(
        '- 학원 1,000명당 수: ${region.academyPer1000Students.toStringAsFixed(1)}',
      )
      ..writeln('- 학교당 학생 수: ${region.avgStudentsPerSchool.toStringAsFixed(1)}')
      ..writeln('- 학급당 학생 수: ${region.avgStudentsPerClass.toStringAsFixed(1)}')
      ..writeln(
        '- 교사 1인당 학생 수: ${region.studentsPerTeacher.toStringAsFixed(1)}',
      )
      ..writeln(
        '- 인구 10만명당 학교 수: ${region.schoolsPer100kPopulation.toStringAsFixed(1)}',
      )
      ..writeln('- 평균 소득 추정치: ${region.pensionAvgIncome.toStringAsFixed(0)}')
      ..writeln()
      ..writeln('현재 분석 요약:')
      ..writeln('- 교육 기회 점수: ${report.score}/100')
      ..writeln('- 상태: ${report.opportunityLabel}')
      ..writeln('- 요약: ${report.summary}')
      ..writeln('- 하이라이트: ${report.highlight}')
      ..writeln('- 강점: ${report.strengthSummary}')
      ..writeln('- 보완 필요: ${report.weaknessSummary}')
      ..writeln('- 전문가 조언: ${report.expertAdvice}')
      ..writeln()
      ..writeln('부족 지표:')
      ..writeln(
        report.gapIssues
            .map((issue) => '- ${issue.title}: ${issue.description}')
            .join('\n'),
      )
      ..writeln()
      ..writeln('추천 리소스:')
      ..writeln(
        report.recommendations
            .map(
              (item) =>
                  '- ${item.title} (${item.provider}): ${item.description} / 링크: ${item.resourceUrl}',
            )
            .join('\n'),
      );

    if (studentScores != null) {
      buffer
        ..writeln()
        ..writeln('학생 성적 정보:')
        ..writeln('- 국어 평균: ${studentScores.korean.toStringAsFixed(1)}')
        ..writeln('- 영어 평균: ${studentScores.english.toStringAsFixed(1)}')
        ..writeln('- 수학 평균: ${studentScores.math.toStringAsFixed(1)}')
        ..writeln('- 전체 평균: ${studentScores.average.toStringAsFixed(1)}')
        ..writeln(
          '- 가장 보완이 필요한 과목: ${StudentScores.subjectLabel(studentScores.weakestSubject)}',
        )
        ..writeln(
          '- 상대적으로 강한 과목: ${StudentScores.subjectLabel(studentScores.strongestSubject)}',
        );
    } else {
      buffer
        ..writeln()
        ..writeln('학생 성적 정보:')
        ..writeln('- 아직 입력되지 않았음. 일반 학생 기준으로 작성한다.');
    }

    buffer
      ..writeln()
      ..writeln('제약:')
      ..writeln('- 실존하는 리소스만 언급한다.')
      ..writeln('- 숫자를 본문 안에 자연스럽게 풀어 쓴다.')
      ..writeln('- 추천 리소스 섹션에는 반드시 3개만 고르고, 각 항목에 이유와 활용법을 1문장씩 적는다.')
      ..writeln('- 실행 계획은 월~일 기준 5개 이내의 짧은 체크리스트로 작성한다.');

    return buffer.toString();
  }
}
