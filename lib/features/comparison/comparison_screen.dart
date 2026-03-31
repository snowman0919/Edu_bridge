import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/region_metrics.dart';
import '../../data/repositories/education_repository.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({
    super.key,
    required this.repository,
    required this.primaryRegion,
    required this.compareRegion,
    required this.onChanged,
    required this.onOpenInsights,
  });

  final EducationRepository repository;
  final RegionMetrics primaryRegion;
  final RegionMetrics compareRegion;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenInsights;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final compareOptions = repository.regions
        .where((item) => item.regionName != primaryRegion.regionName)
        .toList();

    return Column(
      children: [
        BrandAppBar(
          trailing: IconButton(
            onPressed: onOpenInsights,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 126),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('지역 비교', style: textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text(
                  '비교할 지역 선택',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: compareRegion.regionName,
                      icon: const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.outline,
                      ),
                      items: compareOptions
                          .map(
                            (region) => DropdownMenuItem<String>(
                              value: region.regionName,
                              child: Text(
                                region.regionName,
                                style: textTheme.titleMedium,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onChanged(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 720;
                    final primaryCard = _RegionCard(
                      region: primaryRegion,
                      dark: true,
                      label: 'Region A',
                    );
                    final secondaryCard = _RegionCard(
                      region: compareRegion,
                      label: 'Region B',
                      topOffset: wide ? 18 : 0,
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          primaryCard,
                          const SizedBox(height: 14),
                          secondaryCard,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: primaryCard),
                        const SizedBox(width: 14),
                        Expanded(child: secondaryCard),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                _ComparisonMetric(
                  title: '학원 수',
                  verdict: AppFormatters.comparisonLabel(
                    primaryRegion.academyCount,
                    compareRegion.academyCount,
                  ),
                  verdictColor:
                      primaryRegion.academyCount >= compareRegion.academyCount
                      ? AppColors.secondary
                      : AppColors.danger,
                  primaryLabel: primaryRegion.district,
                  primaryValue: primaryRegion.academyCount,
                  secondaryLabel: compareRegion.district,
                  secondaryValue: compareRegion.academyCount,
                ),
                const SizedBox(height: 24),
                _ComparisonMetric(
                  title: '학교 수',
                  verdict: AppFormatters.comparisonLabel(
                    primaryRegion.schoolCount,
                    compareRegion.schoolCount,
                  ),
                  verdictColor: AppColors.primaryContainer,
                  primaryLabel: primaryRegion.district,
                  primaryValue: primaryRegion.schoolCount,
                  secondaryLabel: compareRegion.district,
                  secondaryValue: compareRegion.schoolCount,
                ),
                const SizedBox(height: 24),
                _ComparisonMetric(
                  title: '학생 1,000명당 학원 수',
                  verdict: AppFormatters.comparisonLabel(
                    primaryRegion.academyPer1000Students,
                    compareRegion.academyPer1000Students,
                  ),
                  verdictColor:
                      primaryRegion.academyPer1000Students >=
                          compareRegion.academyPer1000Students
                      ? AppColors.secondary
                      : AppColors.danger,
                  primaryLabel: primaryRegion.district,
                  primaryValue: primaryRegion.academyPer1000Students,
                  secondaryLabel: compareRegion.district,
                  secondaryValue: compareRegion.academyPer1000Students,
                  suffix: '개',
                ),
                const SizedBox(height: 24),
                TonalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '비교 결과 요약',
                            style: textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${primaryRegion.district}는 ${compareRegion.district}보다 ${primaryRegion.academyPer1000Students >= compareRegion.academyPer1000Students ? '민간 학습 자원 접근성' : '공교육 기반 안정성'}에서 더 강한 편입니다.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${compareRegion.district}는 ${compareRegion.schoolCount >= primaryRegion.schoolCount ? '학교 수와 학생 분산 측면' : '학생 규모와 생활권 수요 측면'}에서 참고할 만한 비교 포인트가 있습니다.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TonalCard(
                        background: AppColors.surfaceLowest,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pro Suggestion',
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '학원 접근성이 낮은 지역은 무료 온라인 강의를 기본 축으로 두고, 지역 공공 프로그램을 보조 축으로 묶는 전략이 유효합니다.',
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TonalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '비교 해설',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${primaryRegion.district}은 ${compareRegion.district}보다 학원 1,000명당 밀도가 ${AppFormatters.decimal(primaryRegion.academyPer1000Students - compareRegion.academyPer1000Students)}개 차이납니다.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '비교 결과는 어느 지역이 절대적으로 우월한지를 말하기보다, 어떤 학습 전략을 우선 배치해야 하는지를 판단하는 기준으로 보는 편이 적절합니다.',
                        style: textTheme.bodyMedium,
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

class _RegionCard extends StatelessWidget {
  const _RegionCard({
    required this.region,
    required this.label,
    this.dark = false,
    this.topOffset = 0,
  });

  final RegionMetrics region;
  final String label;
  final bool dark;
  final double topOffset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: TonalCard(
        background: dark ? AppColors.primaryContainer : AppColors.surfaceLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: dark ? Colors.white70 : AppColors.outline,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              region.district,
              style: textTheme.headlineMedium?.copyWith(
                color: dark ? Colors.white : AppColors.primary,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: dark ? Colors.white70 : AppColors.outline,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    region.province,
                    style: textTheme.labelMedium?.copyWith(
                      color: dark ? Colors.white70 : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonMetric extends StatelessWidget {
  const _ComparisonMetric({
    required this.title,
    required this.verdict,
    required this.verdictColor,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
    this.suffix = '개',
  });

  final String title;
  final String verdict;
  final Color verdictColor;
  final String primaryLabel;
  final double primaryValue;
  final String secondaryLabel;
  final double secondaryValue;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final largest = primaryValue > secondaryValue
        ? primaryValue
        : secondaryValue;
    final primaryFactor = largest == 0
        ? 0.0
        : (primaryValue / largest).toDouble();
    final secondaryFactor = largest == 0
        ? 0.0
        : (secondaryValue / largest).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: textTheme.titleMedium)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: verdictColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                verdict,
                style: textTheme.labelSmall?.copyWith(color: verdictColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MetricBar(
          label: primaryLabel,
          value: primaryValue,
          factor: primaryFactor,
          color: AppColors.primary,
          suffix: suffix,
        ),
        const SizedBox(height: 10),
        _MetricBar(
          label: secondaryLabel,
          value: secondaryValue,
          factor: secondaryFactor,
          color: AppColors.outline,
          suffix: suffix,
        ),
      ],
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.factor,
    required this.color,
    required this.suffix,
  });

  final String label;
  final double value;
  final double factor;
  final Color color;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
            Text(
              '${AppFormatters.decimal(value)}$suffix',
              style: textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ProgressMeter(value: factor, color: color),
      ],
    );
  }
}
