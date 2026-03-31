import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/region_metrics.dart';
import '../../data/models/region_report.dart';
import '../../data/models/student_scores.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.region,
    required this.report,
    required this.studentScores,
    required this.bookmarkedTitles,
    required this.onToggleBookmark,
    required this.onOpenRegionPicker,
    required this.onOpenInsights,
    required this.onOpenExternalUrl,
  });

  final RegionMetrics region;
  final RegionReport report;
  final StudentScores? studentScores;
  final Set<String> bookmarkedTitles;
  final ValueChanged<String> onToggleBookmark;
  final VoidCallback onOpenRegionPicker;
  final VoidCallback onOpenInsights;
  final ValueChanged<String> onOpenExternalUrl;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  RecommendationCategory _selected = RecommendationCategory.all;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = widget.report.recommendations.where((item) {
      if (_selected == RecommendationCategory.all) {
        return true;
      }
      return item.category == _selected;
    }).toList();

    return Column(
      children: [
        BrandAppBar(
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onOpenRegionPicker,
                icon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.outline,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: widget.onOpenInsights,
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
                Text('추천 학습 기회', style: textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text('데이터 기반 맞춤형 학습을 시작하세요.', style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 120,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'PERSONALIZED',
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '${widget.region.district} 학생을 위한\n최적의 추천',
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '실시간 트렌드 반영 완료',
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.84),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: '전체',
                        selected: _selected == RecommendationCategory.all,
                        onTap: () => setState(
                          () => _selected = RecommendationCategory.all,
                        ),
                      ),
                      _FilterChip(
                        label: '무료 강의',
                        selected: _selected == RecommendationCategory.freeClass,
                        onTap: () => setState(
                          () => _selected = RecommendationCategory.freeClass,
                        ),
                      ),
                      _FilterChip(
                        label: '공공 프로그램',
                        selected:
                            _selected == RecommendationCategory.publicProgram,
                        onTap: () => setState(
                          () =>
                              _selected = RecommendationCategory.publicProgram,
                        ),
                      ),
                      _FilterChip(
                        label: '장학/지원',
                        selected: _selected == RecommendationCategory.support,
                        onTap: () => setState(
                          () => _selected = RecommendationCategory.support,
                        ),
                      ),
                      _FilterChip(
                        label: '자기 주도',
                        selected:
                            _selected == RecommendationCategory.selfDriven,
                        onTap: () => setState(
                          () => _selected = RecommendationCategory.selfDriven,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (widget.studentScores != null) ...[
                  TonalCard(
                    background: AppColors.surfaceLowest,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '국영수 평균 ${widget.studentScores!.averageLabel()}점을 반영해 ${StudentScores.subjectLabel(widget.studentScores!.weakestSubject)} 보강 리소스를 상단에 우선 배치했습니다.',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RecommendationCard(
                      item: item,
                      bookmarked: widget.bookmarkedTitles.contains(item.title),
                      onToggleBookmark: () =>
                          widget.onToggleBookmark(item.title),
                      onOpenDetail: () => _openRecommendationDetail(item),
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

  void _openRecommendationDetail(RecommendationItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final bookmarked = widget.bookmarkedTitles.contains(item.title);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.title, style: textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(item.description, style: textTheme.bodyLarge),
                const SizedBox(height: 16),
                TonalCard(
                  background: AppColors.surfaceLowest,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.provider,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.resourceLabel, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TonalCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 이유',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(item.reason, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('활용 팁', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._usageTipsFor(item).map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(tip, style: textTheme.bodyMedium)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onToggleBookmark(item.title);
                  },
                  child: Text(bookmarked ? '북마크 해제하기' : '북마크 저장하기'),
                ),
                if (!item.resourceUrl.startsWith('internal://'))
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onOpenExternalUrl(item.resourceUrl);
                    },
                    child: Text(item.resourceLabel),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openActionPlan(item);
                  },
                  child: Text(item.ctaLabel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _usageTipsFor(RecommendationItem item) {
    switch (item.category) {
      case RecommendationCategory.freeClass:
        return <String>[
          '공통 과목 1~2개를 먼저 고정해 주간 루틴으로 묶는 방식이 가장 안정적입니다.',
          '학교 과제와 겹치는 단원부터 우선 연결하면 체감 효과가 빠릅니다.',
        ];
      case RecommendationCategory.publicProgram:
        return <String>[
          '생활권 안에서 참여 가능한 프로그램을 먼저 선택하면 이동 부담을 줄일 수 있습니다.',
          '비교 화면에서 약했던 지표를 보완하는 체험형 프로그램을 우선 검토해 보세요.',
        ];
      case RecommendationCategory.support:
        return <String>[
          '신청 기간과 제출 서류를 미리 정리해 두면 놓치는 경우를 크게 줄일 수 있습니다.',
          '교재비, 수강료, 교통비 중 실제 도움이 큰 항목부터 우선 비교하세요.',
        ];
      case RecommendationCategory.selfDriven:
        return <String>[
          '3일 단위로 점검하는 짧은 루틴부터 시작하면 유지가 쉽습니다.',
          '분석 화면의 부족 지표 한 가지를 목표로 삼으면 실행력이 올라갑니다.',
        ];
      case RecommendationCategory.all:
        return const <String>[];
    }
  }

  void _openActionPlan(RecommendationItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final steps = _actionStepsFor(item);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.ctaLabel, style: textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  '${widget.region.district} 기준으로 바로 실행할 수 있는 순서를 정리했습니다.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ...steps.indexed.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TonalCard(
                      background: AppColors.surfaceLowest,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.$1 + 1}',
                              style: textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(entry.$2, style: textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: item.resourceUrl.startsWith('internal://')
                      ? () {
                          Navigator.of(context).pop();
                          widget.onOpenInsights();
                        }
                      : () {
                          Navigator.of(context).pop();
                          widget.onOpenExternalUrl(item.resourceUrl);
                        },
                  child: Text(
                    item.resourceUrl.startsWith('internal://')
                        ? '알림 및 안내에서 계속 보기'
                        : item.resourceLabel,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onOpenRegionPicker();
                  },
                  child: const Text('지역 다시 선택하기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _actionStepsFor(RecommendationItem item) {
    switch (item.category) {
      case RecommendationCategory.freeClass:
        return <String>[
          '무료 강의를 한 과목만 먼저 고르고, 주 3회 30분 단위로 시작합니다.',
          '비교 화면에서 약한 지표와 연결되는 단원을 우선 수강 대상으로 정합니다.',
          '2주 뒤 학습 유지 여부를 점검하고 필요하면 다른 지역 추천과 다시 비교합니다.',
        ];
      case RecommendationCategory.publicProgram:
        return <String>[
          '생활권 안에서 이동 가능한 기관인지 먼저 확인합니다.',
          '운영 시간, 모집 정원, 대상 학년을 체크해 실제 참여 가능성을 줄입니다.',
          '참여 후에는 분석 화면의 부족 지표가 얼마나 보완되는지 다시 확인합니다.',
        ];
      case RecommendationCategory.support:
        return <String>[
          '신청 기간과 제출 서류를 먼저 정리합니다.',
          '지원 항목이 교재비, 수강료, 교통비 중 어디에 직접 도움이 되는지 비교합니다.',
          '조건이 맞으면 가족 단위로 함께 신청 가능한 제도도 같이 검토합니다.',
        ];
      case RecommendationCategory.selfDriven:
        return <String>[
          '실행 난도가 가장 낮은 루틴 한 가지만 먼저 정합니다.',
          '3일 간격으로 체크할 수 있는 짧은 목표를 설정합니다.',
          '달성률이 떨어지면 추천 목록에서 무료 강의나 공공 프로그램을 함께 묶어 보완합니다.',
        ];
      case RecommendationCategory.all:
        return <String>[
          '현재 부족 지표와 가장 직접적으로 연결되는 추천부터 선택합니다.',
          '한 번에 여러 개를 시작하기보다 1개만 먼저 실행합니다.',
          '실행 후 지역 비교와 분석 화면을 다시 보며 다음 추천을 고릅니다.',
        ];
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceHigh,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: selected ? Colors.white : AppColors.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.item,
    required this.bookmarked,
    required this.onToggleBookmark,
    required this.onOpenDetail,
  });

  final RecommendationItem item;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(28),
      child: TonalCard(
        background: AppColors.surfaceLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tag.contains('무료')
                                  ? AppColors.secondaryContainer
                                  : tag.contains('장학')
                                  ? AppColors.tertiaryContainer
                                  : const Color(0xFFE0E0FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              tag,
                              style: textTheme.labelSmall?.copyWith(
                                color: tag.contains('무료')
                                    ? AppColors.secondary
                                    : tag.contains('장학')
                                    ? AppColors.tertiary
                                    : AppColors.primaryContainer,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                IconButton(
                  onPressed: onToggleBookmark,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: bookmarked ? AppColors.primary : AppColors.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(item.provider, style: textTheme.labelSmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.resourceLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(item.description, style: textTheme.bodyLarge),
            const SizedBox(height: 16),
            TonalCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '추천 이유',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.reason,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (item.ctaLabel == '프로그램 예약하기')
              FilledButton(
                onPressed: onOpenDetail,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(item.ctaLabel),
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpenDetail,
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    item.ctaLabel,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
