import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/region_metrics.dart';
import '../../data/models/region_report.dart';
import '../../data/models/student_scores.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({
    super.key,
    required this.region,
    required this.report,
    required this.studentScores,
    required this.onDownloadReport,
    required this.onEditScores,
    required this.onOpenRegionPicker,
    required this.onOpenInsights,
    required this.isGeneratingReport,
  });

  final RegionMetrics region;
  final RegionReport report;
  final StudentScores? studentScores;
  final VoidCallback onDownloadReport;
  final VoidCallback onEditScores;
  final VoidCallback onOpenRegionPicker;
  final VoidCallback onOpenInsights;
  final bool isGeneratingReport;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        BrandAppBar(
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onOpenRegionPicker,
                icon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.outline,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: onOpenInsights,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 126),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('교육 기회 분석', style: textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text('데이터 기반의 지역 맞춤형 교육 환경 진단', style: textTheme.bodyLarge),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '이 지역에서 부족할 수 있는 부분',
                        style: textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showIssueInfo(context),
                      icon: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...report.gapIssues.map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _IssueCard(issue: issue),
                  ),
                ),
                const SizedBox(height: 12),
                Text('핵심 파라미터', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 12.0;
                    final columns = constraints.maxWidth < 360 ? 1 : 2;
                    final cardWidth = columns == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - spacing) / 2;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _ParameterCard(
                            title: '학생 1,000명당 학원 수',
                            value:
                                '${AppFormatters.decimal(region.academyPer1000Students)}개',
                            caption: '민간 학습 자원 접근성',
                            icon: Icons.auto_stories_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _ParameterCard(
                            title: '학급당 학생 수',
                            value:
                                '${AppFormatters.decimal(region.avgStudentsPerClass)}명',
                            caption: '교실 밀집도',
                            icon: Icons.groups_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _ParameterCard(
                            title: '교사 1인당 학생 수',
                            value:
                                '${AppFormatters.decimal(region.studentsPerTeacher)}명',
                            caption: '지도 부담 지표',
                            icon: Icons.person_search_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _ParameterCard(
                            title: '인구 10만명당 학교 수',
                            value:
                                '${AppFormatters.decimal(region.schoolsPer100kPopulation)}개',
                            caption: '공교육 접근성',
                            icon: Icons.school_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                TonalCard(
                  background: AppColors.surfaceLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '국영수 평균 기반 구체화',
                              style: textTheme.titleMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: onEditScores,
                            child: Text(studentScores == null ? '입력하기' : '수정'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        studentScores == null
                            ? '학생 평균 점수를 입력하면 취약 과목 중심으로 추천 학습 기회와 AI 리포트를 다시 정리합니다.'
                            : '국어 ${studentScores!.korean.toStringAsFixed(0)} · 영어 ${studentScores!.english.toStringAsFixed(0)} · 수학 ${studentScores!.math.toStringAsFixed(0)} · 평균 ${studentScores!.averageLabel()}',
                        style: textTheme.bodyLarge,
                      ),
                      if (studentScores != null) ...[
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth < 360
                                ? 1
                                : 3;
                            return GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: crossAxisCount == 1
                                  ? 3.2
                                  : 1.02,
                              children: [
                                _SubjectScoreCard(
                                  label: '국어',
                                  score: studentScores!.korean,
                                  highlighted:
                                      studentScores!.weakestSubject ==
                                      StudentSubject.korean,
                                ),
                                _SubjectScoreCard(
                                  label: '영어',
                                  score: studentScores!.english,
                                  highlighted:
                                      studentScores!.weakestSubject ==
                                      StudentSubject.english,
                                ),
                                _SubjectScoreCard(
                                  label: '수학',
                                  score: studentScores!.math,
                                  highlighted:
                                      studentScores!.weakestSubject ==
                                      StudentSubject.math,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _PersonalizedFocusCard(scores: studentScores!),
                        const SizedBox(height: 10),
                        Text(
                          '현재는 ${StudentScores.subjectLabel(studentScores!.weakestSubject)} 보강 우선, ${StudentScores.subjectLabel(studentScores!.strongestSubject)} 확장 학습 권장 상태입니다.',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이 지역에 필요한 지원 방향',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...report.supportDirections.map(
                        (direction) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _supportIcon(direction.kind),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        direction.title,
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        direction.description,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.78,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FilledButton(
                        onPressed: isGeneratingReport ? null : onDownloadReport,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGeneratingReport) ...[
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              isGeneratingReport
                                  ? 'AI 리포트 작성 중...'
                                  : '맞춤형 리포트 다운로드',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ParameterCard extends StatelessWidget {
  const _ParameterCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TonalCard(
      background: AppColors.surfaceLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SubjectScoreCard extends StatelessWidget {
  const _SubjectScoreCard({
    required this.label,
    required this.score,
    required this.highlighted,
  });

  final String label;
  final double score;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = highlighted ? AppColors.warning : AppColors.primary;
    return TonalCard(
      background: highlighted
          ? AppColors.warning.withValues(alpha: 0.08)
          : AppColors.surfaceHigh,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelLarge),
          const Spacer(),
          Text(
            score.toStringAsFixed(0),
            style: textTheme.headlineMedium?.copyWith(color: accent),
          ),
          const SizedBox(height: 4),
          Text(
            highlighted ? '우선 보완' : '현재 점수',
            style: textTheme.labelSmall?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _PersonalizedFocusCard extends StatelessWidget {
  const _PersonalizedFocusCard({required this.scores});

  final StudentScores scores;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final weakest = StudentScores.subjectLabel(scores.weakestSubject);
    final strongest = StudentScores.subjectLabel(scores.strongestSubject);
    final guide = switch (scores.weakestSubject) {
      StudentSubject.korean =>
        '국어는 지문 독해와 오답 정리를 우선 두고, 영어·수학은 유지 학습으로 가져가는 편이 좋습니다.',
      StudentSubject.english =>
        '영어는 듣기와 독해를 짧게 자주 반복하고, 국어·수학은 기존 강점을 유지하는 전략이 적절합니다.',
      StudentSubject.math =>
        '수학은 취약 단원 개념 복구를 먼저 두고, 국어·영어는 문제 풀이 감각 유지에 집중하는 편이 좋습니다.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '개인화 해석',
            style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            '평균 ${scores.averageLabel()}점 기준으로 $weakest 보강을 우선하고, $strongest는 유지·확장 과목으로 보는 편이 적절합니다.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(guide, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

void _showIssueInfo(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      final textTheme = Theme.of(context).textTheme;
      return AlertDialog(
        title: const Text('부족 지표 해석 기준'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공교육 접근성, 학생 밀집도, 학원 집중도, 교사 부담을 함께 비교해 생활권에서 체감될 수 있는 압력을 추려냅니다.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '점수가 높을수록 해당 항목을 우선 보완해야 한다는 뜻이며, 아래 지원 방향과 추천 학습 기회에 직접 반영됩니다.',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      );
    },
  );
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.issue});

  final GapIssue issue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final severityColor = issue.severity >= 0.72
        ? AppColors.danger
        : issue.severity >= 0.42
        ? AppColors.warning
        : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(28),
        border: Border(
          left: BorderSide(
            color: severityColor.withValues(
              alpha: issue.severity >= 0.72 ? 1 : 0.72,
            ),
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        AppFormatters.severityLabel(issue.severity),
                        style: textTheme.labelSmall?.copyWith(
                          color: severityColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      issue.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLowest,
                  shape: BoxShape.circle,
                ),
                child: Icon(_issueIcon(issue.kind), color: severityColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(issue.description, style: textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ProgressMeter(
                  value: issue.severity,
                  color: severityColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(issue.severity * 100).round()}%',
                style: textTheme.labelMedium?.copyWith(color: severityColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _issueIcon(IssueKind kind) {
  switch (kind) {
    case IssueKind.access:
      return Icons.map_outlined;
    case IssueKind.density:
      return Icons.groups_rounded;
    case IssueKind.competition:
      return Icons.trending_up_rounded;
    case IssueKind.teacherLoad:
      return Icons.person_search_rounded;
  }
}

IconData _supportIcon(SupportKind kind) {
  switch (kind) {
    case SupportKind.online:
      return Icons.computer_rounded;
    case SupportKind.center:
      return Icons.hub_rounded;
    case SupportKind.afterSchool:
      return Icons.school_rounded;
    case SupportKind.mentoring:
      return Icons.diversity_3_rounded;
  }
}
