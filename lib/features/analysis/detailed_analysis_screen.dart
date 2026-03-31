import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/region_metrics.dart';
import '../../data/models/region_report.dart';
import '../../data/repositories/education_repository.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class DetailedAnalysisScreen extends StatelessWidget {
  const DetailedAnalysisScreen({
    super.key,
    required this.repository,
    required this.region,
    required this.report,
  });

  final EducationRepository repository;
  final RegionMetrics region;
  final RegionReport report;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final academyPercentile = repository.percentileOf(
      'academyCount',
      region.academyCount,
    );

    return Scaffold(
      body: Column(
        children: [
          BrandAppBar(
            trailing: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: AppColors.outline),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('상세 분석', style: textTheme.headlineLarge),
                  const SizedBox(height: 6),
                  Text('지역 교육 프로필', style: textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 720;
                      final panels = <Widget>[
                        Expanded(
                          child: _StatPanel(
                            title: '학원 수',
                            value: AppFormatters.compactCount(
                              region.academyCount,
                            ),
                            badge: AppFormatters.topPercent(academyPercentile),
                            bars: [
                              0.10,
                              0.46,
                              0.72,
                              repository.normalized(
                                'academyCount',
                                region.academyCount,
                              ),
                            ],
                            accent: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _StatPanel(
                            title: '학교 수',
                            value: AppFormatters.compactCount(
                              region.schoolCount,
                            ),
                            caption: '전국 평균 대비 비교',
                            bars: [
                              0.25,
                              repository.normalized(
                                'schoolCount',
                                region.schoolCount,
                              ),
                              0.38,
                              0.48,
                            ],
                            accent: AppColors.primaryContainer,
                            background: AppColors.surfaceLow,
                          ),
                        ),
                      ];

                      if (!wide) {
                        return Column(
                          children: [
                            panels[0],
                            const SizedBox(height: 14),
                            panels[1],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          panels[0],
                          const SizedBox(width: 14),
                          panels[1],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TonalCard(
                    background: AppColors.surfaceLowest,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('학생 수', style: textTheme.labelMedium),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    AppFormatters.compactCount(
                                      region.studentCount,
                                    ),
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.dangerContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '밀집도 주의',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _MiniBar(heightFactor: 0.45),
                              _MiniBar(heightFactor: 0.58),
                              _MiniBar(heightFactor: 0.74),
                              _MiniBar(
                                heightFactor: repository.normalized(
                                  'studentCount',
                                  region.studentCount,
                                ),
                                strong: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TonalCard(
                    background: AppColors.primaryContainer,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '추정 소득 지표',
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppFormatters.compactIncome(
                                  region.pensionAvgIncome,
                                ),
                                style: textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.payments_rounded,
                          color: Colors.white54,
                          size: 34,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('도출 지표', style: textTheme.titleLarge),
                  const SizedBox(height: 14),
                  _IndicatorTile(
                    icon: Icons.equalizer_rounded,
                    background: AppColors.secondaryContainer,
                    iconColor: AppColors.secondary,
                    title: '학생 1,000명당 학원 수',
                    value:
                        '${AppFormatters.decimal(region.academyPer1000Students)}개',
                  ),
                  const SizedBox(height: 12),
                  _IndicatorTile(
                    icon: Icons.groups_rounded,
                    background: Color(0xFFE0E0FF),
                    iconColor: AppColors.primaryContainer,
                    title: '학교당 학생 수',
                    value:
                        '${AppFormatters.decimal(region.avgStudentsPerSchool)}명',
                  ),
                  const SizedBox(height: 12),
                  _IndicatorTile(
                    icon: Icons.pie_chart_rounded,
                    background: AppColors.tertiaryContainer,
                    iconColor: AppColors.tertiary,
                    title: '인구 대비 학생 비율',
                    value:
                        '${AppFormatters.decimal(region.highSchoolStudentsPer1000Population / 10)}%',
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighest.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(28),
                      border: const Border(
                        left: BorderSide(color: AppColors.primary, width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '데이터 종합 해석',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _InterpretationRow(
                          color: AppColors.secondary,
                          icon: Icons.check_circle_rounded,
                          title: '강점',
                          body: report.strengthSummary,
                        ),
                        const SizedBox(height: 16),
                        _InterpretationRow(
                          color: AppColors.danger,
                          icon: Icons.warning_rounded,
                          title: '부족한 점',
                          body: report.weaknessSummary,
                        ),
                        const SizedBox(height: 16),
                        TonalCard(
                          background: Colors.white.withValues(alpha: 0.5),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '전문가 어드바이스',
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                report.expertAdvice,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const DecorativePoster(
                    title: '데이터로 보는 미래',
                    subtitle:
                        '지역마다 다른 교육 여건을 입체적으로 해석해, 실제 생활권에 맞는 전략으로 연결합니다.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({
    required this.title,
    required this.value,
    required this.bars,
    required this.accent,
    this.caption,
    this.badge,
    this.background = AppColors.surfaceLowest,
  });

  final String title;
  final String value;
  final List<double> bars;
  final Color accent;
  final String? caption;
  final String? badge;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TonalCard(
      background: background,
      child: SizedBox(
        height: 176,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.labelMedium),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: textTheme.headlineMedium?.copyWith(color: accent),
                  ),
                ),
                if (badge != null)
                  Text(
                    badge!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
              ],
            ),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(caption!, style: textTheme.labelSmall),
              ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars
                  .map(
                    (item) => _MiniBar(
                      heightFactor: item,
                      strong: identical(item, bars.last),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.heightFactor, this.strong = false});

  final double heightFactor;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 54 * heightFactor.clamp(0.0, 1.0),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: strong
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.18),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ),
    );
  }
}

class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TonalCard(
      background: AppColors.surfaceLowest,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterpretationRow extends StatelessWidget {
  const _InterpretationRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(body, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
