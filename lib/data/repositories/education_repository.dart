import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../models/region_metrics.dart';
import '../models/region_report.dart';
import '../models/student_scores.dart';

class EducationRepository {
  EducationRepository._(this.regions)
    : _series = {
        'academyCount': regions.map((item) => item.academyCount).toList()
          ..sort(),
        'schoolCount': regions.map((item) => item.schoolCount).toList()..sort(),
        'studentCount': regions.map((item) => item.studentCount).toList()
          ..sort(),
        'population': regions.map((item) => item.population).toList()..sort(),
        'academyPer1000':
            regions.map((item) => item.academyPer1000Students).toList()..sort(),
        'schoolsPer100k':
            regions.map((item) => item.schoolsPer100kPopulation).toList()
              ..sort(),
        'avgStudentsPerClass':
            regions.map((item) => item.avgStudentsPerClass).toList()..sort(),
        'studentsPerTeacher':
            regions.map((item) => item.studentsPerTeacher).toList()..sort(),
        'income': regions.map((item) => item.pensionAvgIncome).toList()..sort(),
      };

  static const String _gangnam = '서울특별시 강남구';
  static const String _suwon = '경기도 수원시';

  final List<RegionMetrics> regions;
  final Map<String, List<double>> _series;

  static Future<EducationRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/data.csv');
    final lines = const LineSplitter()
        .convert(raw)
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return EducationRepository._(<RegionMetrics>[]);
    }

    final headers = _splitCsvLine(lines.first);
    final items = <RegionMetrics>[];
    for (final line in lines.skip(1)) {
      final values = _splitCsvLine(line);
      if (values.length != headers.length) {
        continue;
      }

      final row = <String, String>{};
      for (var index = 0; index < headers.length; index++) {
        row[headers[index]] = values[index];
      }
      items.add(RegionMetrics.fromCsv(row));
    }

    items.sort((a, b) {
      final province = a.province.compareTo(b.province);
      if (province != 0) {
        return province;
      }
      return a.district.compareTo(b.district);
    });

    return EducationRepository._(items);
  }

  static List<String> _splitCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        if (inQuotes && index + 1 < line.length && line[index + 1] == '"') {
          buffer.write('"');
          index++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    values.add(buffer.toString());
    return values;
  }

  String get defaultRegionName {
    if (regions.any((item) => item.regionName == _gangnam)) {
      return _gangnam;
    }
    return regions.isNotEmpty ? regions.first.regionName : '';
  }

  List<String> get provinces {
    final seen = <String>{};
    final ordered = <String>[];
    for (final item in regions) {
      if (seen.add(item.province)) {
        ordered.add(item.province);
      }
    }
    return ordered;
  }

  List<RegionMetrics> districtsForProvince(String province) {
    return regions.where((item) => item.province == province).toList();
  }

  RegionMetrics regionByName(String regionName) {
    return regions.firstWhere((item) => item.regionName == regionName);
  }

  String defaultComparisonFor(String regionName) {
    if (regionName == _gangnam &&
        regions.any((item) => item.regionName == _suwon)) {
      return _suwon;
    }

    final current = regionByName(regionName);
    final candidates = regions.where(
      (item) => item.regionName != current.regionName,
    );
    RegionMetrics? best;
    var smallestGap = double.infinity;

    for (final candidate in candidates) {
      final studentGap = (candidate.studentCount - current.studentCount).abs();
      final sameProvincePenalty = candidate.province == current.province
          ? 25000
          : 0;
      final scoreGap = studentGap + sameProvincePenalty;
      if (scoreGap < smallestGap) {
        smallestGap = scoreGap;
        best = candidate;
      }
    }

    return best?.regionName ?? defaultRegionName;
  }

  double percentileOf(
    String metric,
    double value, {
    bool higherIsBetter = true,
  }) {
    final series = _series[metric];
    if (series == null || series.length <= 1) {
      return 0.5;
    }
    final rank = series.where((entry) => entry <= value).length - 1;
    final percentile = rank / (series.length - 1);
    return higherIsBetter
        ? percentile.clamp(0.0, 1.0)
        : (1 - percentile).clamp(0.0, 1.0);
  }

  double normalized(String metric, double value) {
    final series = _series[metric];
    if (series == null || series.isEmpty) {
      return 0;
    }
    final maxValue = series.last;
    if (maxValue == 0) {
      return 0;
    }
    return (value / maxValue).clamp(0.08, 1.0);
  }

  RegionReport buildReport(String regionName, {StudentScores? studentScores}) {
    final region = regionByName(regionName);
    final academyAccess = percentileOf(
      'academyPer1000',
      region.academyPer1000Students,
    );
    final publicBase = percentileOf(
      'schoolsPer100k',
      region.schoolsPer100kPopulation,
    );
    final classDensity = percentileOf(
      'avgStudentsPerClass',
      region.avgStudentsPerClass,
    );
    final teacherLoad = percentileOf(
      'studentsPerTeacher',
      region.studentsPerTeacher,
    );
    final incomeLevel = percentileOf('income', region.pensionAvgIncome);

    final weightedScore =
        (academyAccess * 0.42) +
        (publicBase * 0.20) +
        ((1 - classDensity) * 0.12) +
        ((1 - teacherLoad) * 0.08) +
        (incomeLevel * 0.18);
    final score = (30 + (weightedScore * 60)).round().clamp(32, 96);

    final gapIssues = <GapIssue>[
      GapIssue(
        kind: IssueKind.competition,
        title: academyAccess >= 0.65 ? '학습 경쟁 압력' : '학원 접근성 불균형',
        description: academyAccess >= 0.65
            ? '학생 수 대비 학원 밀집도가 높아 경쟁과 사교육 부담이 커질 수 있습니다.'
            : '학생 수 대비 민간 학습 자원이 적어 과목 선택 폭이 좁을 수 있습니다.',
        severity: academyAccess >= 0.65 ? academyAccess : (1 - academyAccess),
      ),
      GapIssue(
        kind: IssueKind.density,
        title: '학생 밀집도 과부하',
        description: '학급당 학생 수가 높아 개별 피드백과 집중 지도가 부족해질 수 있습니다.',
        severity: classDensity,
      ),
      GapIssue(
        kind: IssueKind.access,
        title: '공교육 접근성 편차',
        description: '인구 대비 학교 수가 부족하면 통학 거리와 공교육 체감 접근성이 악화될 수 있습니다.',
        severity: 1 - publicBase,
      ),
      GapIssue(
        kind: IssueKind.teacherLoad,
        title: '교사 1인당 부담',
        description: '교사 한 명이 담당하는 학생 수가 많을수록 상담과 생활지도의 여유가 줄어듭니다.',
        severity: teacherLoad,
      ),
    ]..sort((a, b) => b.severity.compareTo(a.severity));

    final supports = _buildSupportDirections(gapIssues.take(3).toList());
    final recommendations = _buildRecommendations(
      region,
      gapIssues.take(3).toList(),
      studentScores,
    );

    final highlight = academyAccess >= 0.72
        ? '이 지역은 학생 수에 비해 학원 밀집도가 높아 경쟁이 치열해질 수 있습니다.'
        : publicBase <= 0.35
        ? '공교육 기반이 얇아 학교 선택지와 생활권 내 접근성이 제한될 수 있습니다.'
        : '공공 인프라와 민간 학습 자원이 비교적 균형 있게 유지되고 있습니다.';

    final strength = academyAccess >= publicBase
        ? '민간 학습 자원이 풍부하고 학생이 선택할 수 있는 보충 학습 옵션이 넓습니다.'
        : '생활권 내 학교 기반이 안정적이어서 공교육 접근성이 비교적 탄탄합니다.';

    final scoreSummary = _studentScoreSummary(studentScores);

    return RegionReport(
      score: score,
      opportunityLabel: _bandLabel(score),
      summary: _summaryFor(region, score, studentScores),
      highlight: highlight,
      gapIssues: gapIssues.take(3).toList(),
      supportDirections: supports,
      strengthSummary: strength,
      weaknessSummary: gapIssues.first.description,
      expertAdvice: scoreSummary == null
          ? supports.first.description
          : '${supports.first.description} $scoreSummary',
      recommendations: recommendations,
    );
  }

  List<SupportDirection> _buildSupportDirections(List<GapIssue> issues) {
    final result = <SupportDirection>[];

    void addIfMissing(SupportDirection direction) {
      final exists = result.any((item) => item.kind == direction.kind);
      if (!exists) {
        result.add(direction);
      }
    }

    for (final issue in issues) {
      switch (issue.kind) {
        case IssueKind.access:
          addIfMissing(
            const SupportDirection(
              kind: SupportKind.center,
              title: '지자체 학습 거점 연계',
              description: '생활권 안에서 이용 가능한 청소년 센터, 평생학습관, 공공 스터디 공간을 우선 연결합니다.',
            ),
          );
        case IssueKind.density:
          addIfMissing(
            const SupportDirection(
              kind: SupportKind.afterSchool,
              title: '학교 내 방과 후 심화 프로그램',
              description: '교실 과밀을 완화할 수 있도록 방과 후 보충 수업과 소규모 집중 지도를 묶어 제공합니다.',
            ),
          );
        case IssueKind.competition:
          addIfMissing(
            const SupportDirection(
              kind: SupportKind.online,
              title: '공공 온라인 학습 자원 활용',
              description: '검증된 무료 강의와 디지털 학습 자원으로 사교육 의존도를 낮추는 전략이 적합합니다.',
            ),
          );
        case IssueKind.teacherLoad:
          addIfMissing(
            const SupportDirection(
              kind: SupportKind.mentoring,
              title: '멘토링·상담 지원 보강',
              description: '대학생 멘토링, 진로 코칭, 학습 상담을 연결해 학교 밖 개별 지원을 확보합니다.',
            ),
          );
      }
    }

    addIfMissing(
      const SupportDirection(
        kind: SupportKind.online,
        title: '표준화된 디지털 학습 루트',
        description: '가정에서도 이어질 수 있는 무료 온라인 강의와 과제 관리 루틴을 함께 제안합니다.',
      ),
    );

    return result.take(3).toList();
  }

  List<RecommendationItem> _buildRecommendations(
    RegionMetrics region,
    List<GapIssue> issues,
    StudentScores? studentScores,
  ) {
    final titles = issues.map((item) => item.kind).toSet();
    final items = <RecommendationItem>[
      _subjectSpecificRecommendation(studentScores),
      RecommendationItem(
        category: RecommendationCategory.freeClass,
        title: 'EBSi 개념·기출 학습',
        description: '수능 개념, 기출 해설, 학평 대비 강좌를 한 곳에서 이어서 볼 수 있는 대표 무료 학습 경로입니다.',
        reason: titles.contains(IssueKind.competition)
            ? '사교육 의존도를 낮추면서도 과목별 개념과 문제 풀이를 동시에 보강하기 좋습니다.'
            : '지역 격차와 무관하게 동일한 품질의 고교 학습 자원에 접근할 수 있습니다.',
        ctaLabel: 'EBSi 열기',
        provider: 'EBSi',
        resourceLabel: '공식 사이트 바로가기',
        resourceUrl: 'https://www.ebsi.co.kr/ebs/pot/poti/main.ebs',
        tags: const ['#무료', '#온라인', '#기출'],
      ),
      RecommendationItem(
        category: RecommendationCategory.publicProgram,
        title: '커리어넷 진로심리검사',
        description: '학습 동기와 진로 방향을 함께 점검할 수 있는 공공 진로검사 서비스입니다.',
        reason: titles.contains(IssueKind.access)
            ? '생활권 안 학습 자원이 제한될수록 진로 목표를 먼저 좁혀 학습 우선순위를 세우는 방식이 유효합니다.'
            : '강점 과목을 진로와 연결하면 학습 지속성이 더 안정적으로 올라갑니다.',
        ctaLabel: '커리어넷 열기',
        provider: '커리어넷',
        resourceLabel: '진로심리검사 바로가기',
        resourceUrl:
            'https://www.career.go.kr/cnet/front/commbbs/ucc/commBbsList.do',
        tags: const ['#공공', '#온라인', '#진로'],
      ),
      RecommendationItem(
        category: RecommendationCategory.publicProgram,
        title: 'KOCW 심화 개념 보강',
        description: '대학 공개강의 기반으로 수학, 과학, 글쓰기 등 심화 개념을 넓게 탐색할 수 있습니다.',
        reason: '학교 수업에서 막히는 개념을 긴 호흡으로 다시 이해하는 데 도움이 됩니다.',
        ctaLabel: 'KOCW 열기',
        provider: 'KOCW',
        resourceLabel: '대학 공개강의 검색',
        resourceUrl: 'https://www.kocw.net/home/dcoll/dcollSearch.do',
        tags: const ['#무료', '#온라인', '#심화'],
      ),
      RecommendationItem(
        category: RecommendationCategory.support,
        title: '복지로 교육급여·교육비 확인',
        description:
            '${region.district} 생활권 학생이 확인할 수 있는 교육급여, 교육비 경감, 복지 연계 정보를 점검합니다.',
        reason: '교재비와 수강료 부담을 줄이면 지역 교육 자원 격차를 실제 학습 시간으로 전환하기 쉬워집니다.',
        ctaLabel: '복지로 열기',
        provider: '복지로',
        resourceLabel: '공식 사이트 바로가기',
        resourceUrl: 'https://www.bokjiro.go.kr',
        tags: const ['#지원', '#온라인', '#교육비'],
      ),
      const RecommendationItem(
        category: RecommendationCategory.selfDriven,
        title: '주간 자기주도 루틴 설계',
        description: '국영수 평균과 취약 과목을 기준으로 복습일, 오답 점검일, 모의평가 점검일을 나누어 설계합니다.',
        reason: '학습 자원을 많이 확보해도 실행 순서가 없으면 실제 성과로 연결되기 어렵습니다.',
        ctaLabel: '루틴 가이드 보기',
        provider: 'EduBridge',
        resourceLabel: '앱 안에서 실행 가이드 보기',
        resourceUrl: 'internal://study-routine',
        tags: <String>['#자기주도', '#루틴', '#국영수'],
      ),
    ];

    return items;
  }

  RecommendationItem _subjectSpecificRecommendation(StudentScores? scores) {
    if (scores == null) {
      return const RecommendationItem(
        category: RecommendationCategory.freeClass,
        title: 'EBSe 기초 영어 루트',
        description: '듣기, 문법, 독해를 짧은 단위로 쌓을 수 있는 공식 영어 학습 서비스입니다.',
        reason: '국영수 입력 전에도 가장 활용성이 높은 온라인 기반 보강 루트로 쓰기 좋습니다.',
        ctaLabel: 'EBSe 열기',
        provider: 'EBSe',
        resourceLabel: '영어 학습 사이트 열기',
        resourceUrl: 'https://www.ebse.co.kr',
        tags: <String>['#무료', '#온라인', '#영어'],
      );
    }

    switch (scores.weakestSubject) {
      case StudentSubject.korean:
        return const RecommendationItem(
          category: RecommendationCategory.freeClass,
          title: 'EBSi 국어 개념 보강',
          description:
              '문학, 독서, 화법과 작문 등 국어 영역을 단계별로 다시 잡을 수 있는 무료 강좌 중심 경로입니다.',
          reason: '국어는 개념과 지문 처리 루틴을 함께 정리해야 평균 회복 속도가 빨라집니다.',
          ctaLabel: '국어 강좌 보기',
          provider: 'EBSi',
          resourceLabel: '국어 무료 강좌 열기',
          resourceUrl: 'https://www.ebsi.co.kr/ebs/pot/poti/main.ebs',
          tags: <String>['#무료', '#온라인', '#국어'],
        );
      case StudentSubject.english:
        return const RecommendationItem(
          category: RecommendationCategory.freeClass,
          title: 'EBSe 영어 보강 루트',
          description: '듣기, 구문, 독해를 짧은 세션으로 반복할 수 있는 공공 영어 학습 플랫폼입니다.',
          reason: '영어 평균이 낮을 때는 짧은 반복 노출이 중요해 온라인 루트와의 궁합이 좋습니다.',
          ctaLabel: '영어 루트 열기',
          provider: 'EBSe',
          resourceLabel: '영어 학습 사이트 열기',
          resourceUrl: 'https://www.ebse.co.kr',
          tags: <String>['#무료', '#온라인', '#영어'],
        );
      case StudentSubject.math:
        return const RecommendationItem(
          category: RecommendationCategory.freeClass,
          title: 'EBSi 수학 개념 재정리',
          description: '개념 강의와 기출 문제를 한 흐름으로 묶어 수학 취약 단원을 다시 복원하는 데 적합합니다.',
          reason: '수학은 취약 단원 누적이 큰 과목이라 개념 재정리와 문제 적용을 함께 가져가야 합니다.',
          ctaLabel: '수학 강좌 보기',
          provider: 'EBSi',
          resourceLabel: '수학 무료 강좌 열기',
          resourceUrl: 'https://www.ebsi.co.kr/ebs/pot/poti/main.ebs',
          tags: <String>['#무료', '#온라인', '#수학'],
        );
    }
  }

  String _summaryFor(RegionMetrics region, int score, StudentScores? scores) {
    final studentSummary = _studentScoreSummary(scores);
    if (score >= 80) {
      return '전국 평균 대비 교육 인프라와 학습 선택지가 모두 강한 편입니다.${studentSummary == null ? '' : ' $studentSummary'}';
    }
    if (score >= 68) {
      return '기본 교육 인프라는 안정적이지만 일부 체감 격차는 여전히 존재합니다.${studentSummary == null ? '' : ' $studentSummary'}';
    }
    if (score >= 55) {
      return '공교육과 사교육 자원이 혼재되어 있어 지역별 편차 관리가 중요합니다.${studentSummary == null ? '' : ' $studentSummary'}';
    }
    return '${region.district}은 생활권 안 학습 자원을 촘촘하게 연결하는 보완 전략이 필요합니다.${studentSummary == null ? '' : ' $studentSummary'}';
  }

  String? _studentScoreSummary(StudentScores? scores) {
    if (scores == null) {
      return null;
    }
    return '국영수 평균은 ${scores.averageLabel()}점이며, ${StudentScores.subjectLabel(scores.weakestSubject)} 보강을 우선순위로 두는 편이 적절합니다.';
  }

  String _bandLabel(int score) {
    if (score >= 80) {
      return '매우 높음';
    }
    if (score >= 68) {
      return '높음';
    }
    if (score >= 55) {
      return '안정적';
    }
    if (score >= 42) {
      return '보완 필요';
    }
    return '집중 지원 필요';
  }

  double comparisonGap(double primary, double secondary) {
    final larger = math.max(primary, secondary);
    if (larger == 0) {
      return 0;
    }
    return (primary - secondary).abs() / larger;
  }
}
