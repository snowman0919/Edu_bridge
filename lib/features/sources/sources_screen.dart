import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  static const String _sourceSummary =
      'EduBridge 데이터 출처: 학교알리미, 지자체 학원·교습소 표준 인허가 데이터, '
      '행정안전부 주민등록 인구 통계, 국민연금공단 소득 및 고용 데이터';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          BrandAppBar(
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: _sourceSummary),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.fixed,
                          content: Text('출처 요약을 클립보드에 복사했습니다.'),
                        ),
                      );
                  },
                  icon: const Icon(
                    Icons.content_copy_rounded,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('데이터 정보 및 출처', style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'EduBridge가 제공하는 모든 데이터의 투명한 기준을 안내합니다.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  TonalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '서비스 소개',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '로그인 없이 바로 사용하는\n공공데이터 교육 분석',
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'EduBridge는 복잡한 가입 절차 없이 누구나 전국의 교육 환경 데이터를 직관적으로 비교하고 분석할 수 있는 열린 플랫폼입니다.',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text('데이터 출처', style: textTheme.titleLarge),
                      ),
                      Text('VERIFIED SOURCES', style: textTheme.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _SourceItem(
                    icon: Icons.location_city_rounded,
                    iconBackground: Color(0xFFE0E0FF),
                    title: '학교알리미',
                    subtitle: '전국 학교 현황 및 교육 통계',
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: _SourceItem(
                      icon: Icons.menu_book_rounded,
                      iconBackground: AppColors.secondaryContainer,
                      title: '지자체 학원/교습소',
                      subtitle: '지역별 표준 인허가 데이터',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SourceItem(
                    icon: Icons.groups_rounded,
                    iconBackground: AppColors.tertiaryContainer,
                    title: '행정안전부',
                    subtitle: '주민등록 인구 및 세대 통계',
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: _SourceItem(
                      icon: Icons.payments_rounded,
                      iconBackground: Color(0xFFE0E0FF),
                      title: '국민연금공단',
                      subtitle: '지역별 소득 및 고용 데이터',
                    ),
                  ),
                  const SizedBox(height: 24),
                  TonalCard(
                    background: AppColors.primaryContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.analytics_rounded,
                          color: Colors.white54,
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '주요 지표 산출 기준',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '학교 수, 학원 수 등을 학생 수 및 인구와 대조하여 상대적 접근성 지수를 계산합니다. 단순 절대 수치가 아니라 생활권 기준의 교육 기회 균형을 읽기 위한 방식입니다.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighest.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(24),
                      border: const Border(
                        left: BorderSide(color: AppColors.secondary, width: 4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '이용 안내',
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '본 정보는 공공데이터를 기반으로 한 참고용이며, 실제 조건과 차이가 있을 수 있습니다. 세부 입학 정보와 프로그램 운영 여부는 개별 기관을 통해 다시 확인해야 합니다.',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const DecorativePoster(
                    title: 'EMPOWERING EDUCATION\nTHROUGH OPEN DATA',
                    subtitle:
                        '정보의 출처를 드러내는 일 자체가 공공 서비스의 신뢰를 만드는 경험이 되도록 구성했습니다.',
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

class _SourceItem extends StatelessWidget {
  const _SourceItem({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;

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
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryContainer),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}
