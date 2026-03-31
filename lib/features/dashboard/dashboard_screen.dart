import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/region_metrics.dart';
import '../../data/models/region_report.dart';
import '../../data/models/student_scores.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.region,
    required this.report,
    required this.studentScores,
    required this.onEditRegion,
    required this.onEditScores,
    required this.onOpenDetailed,
    required this.onGoToAnalysis,
    required this.onGoToComparison,
    required this.onGoToRecommendations,
    required this.onOpenSources,
  });

  final RegionMetrics region;
  final RegionReport report;
  final StudentScores? studentScores;
  final VoidCallback onEditRegion;
  final VoidCallback onEditScores;
  final VoidCallback onOpenDetailed;
  final VoidCallback onGoToAnalysis;
  final VoidCallback onGoToComparison;
  final VoidCallback onGoToRecommendations;
  final VoidCallback onOpenSources;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        BrandAppBar(
          trailing: InkWell(
            onTap: onEditRegion,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.outline,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      region.regionName,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 126),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '우리 지역 교육 기회 수준',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${report.score}',
                                style: textTheme.displayLarge?.copyWith(
                                  fontSize: 68,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  '/100',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.72),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  report.opportunityLabel,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            report.summary,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth < 320 ? 1 : 2;
                    return GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: crossAxisCount == 1 ? 2.2 : 1.2,
                      children: [
                        _MetricTile(
                          icon: Icons.domain_rounded,
                          label: '학교 수',
                          value: AppFormatters.compactCount(
                            region.schoolCount,
                            suffix: '개',
                          ),
                        ),
                        _MetricTile(
                          icon: Icons.groups_rounded,
                          label: '학생 수',
                          value: AppFormatters.compactPeople(
                            region.studentCount,
                          ),
                        ),
                        _MetricTile(
                          icon: Icons.local_library_rounded,
                          label: '학원 수',
                          value: AppFormatters.compactCount(
                            region.academyCount,
                            suffix: '개',
                          ),
                        ),
                        _MetricTile(
                          icon: Icons.public_rounded,
                          label: '지역 인구',
                          value: AppFormatters.compactPeople(region.population),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                TonalCard(
                  background: AppColors.surfaceLowest,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('성적 기반 구체화', style: textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              studentScores == null
                                  ? '국영수 평균을 입력하면 추천 리소스와 AI 리포트가 과목별로 구체화됩니다.'
                                  : '국어 ${studentScores!.korean.toStringAsFixed(0)} · 영어 ${studentScores!.english.toStringAsFixed(0)} · 수학 ${studentScores!.math.toStringAsFixed(0)} · 평균 ${studentScores!.averageLabel()}',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ActionRowButton(
                  icon: Icons.auto_graph_rounded,
                  title: studentScores == null ? '국영수 평균 입력하기' : '국영수 평균 수정하기',
                  accent: AppColors.tertiary,
                  onTap: onEditScores,
                ),
                const SizedBox(height: 18),
                TonalCard(
                  background: AppColors.primaryContainer.withValues(alpha: 0.1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          report.highlight,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('맞춤형 탐색', style: textTheme.titleMedium),
                const SizedBox(height: 10),
                ActionRowButton(
                  icon: Icons.bar_chart_rounded,
                  title: '상세 분석 보기',
                  onTap: onOpenDetailed,
                ),
                const SizedBox(height: 12),
                ActionRowButton(
                  icon: Icons.compare_arrows_rounded,
                  title: '지역 비교하기',
                  accent: AppColors.secondary,
                  onTap: onGoToComparison,
                ),
                const SizedBox(height: 12),
                ActionRowButton(
                  icon: Icons.auto_awesome_rounded,
                  title: '추천 기회 보기',
                  accent: AppColors.tertiary,
                  onTap: onGoToRecommendations,
                ),
                const SizedBox(height: 12),
                ActionRowButton(
                  icon: Icons.analytics_rounded,
                  title: '분석 화면 바로가기',
                  accent: AppColors.primaryContainer,
                  onTap: onGoToAnalysis,
                ),
                const SizedBox(height: 22),
                InkWell(
                  onTap: onOpenSources,
                  borderRadius: BorderRadius.circular(28),
                  child: TonalCard(
                    background: AppColors.surfaceHigh,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 136,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0D6D7E), AppColors.primary],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '데이터 업데이트 기준\n공공데이터 통합 안내',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('정확한 정보를 확인하세요', style: textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          'EduBridge는 교육 관련 공공데이터를 기반으로 지역별 교육 여건을 해석합니다.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TonalCard(
      child: SizedBox(
        height: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const Spacer(),
            Text(label, style: textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
