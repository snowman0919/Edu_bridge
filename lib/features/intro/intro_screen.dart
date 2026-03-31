import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/glass_bottom_nav.dart';
import '../../shared/widgets/surface_widgets.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          const BrandAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 128),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '데이터로 여는\n교육 기회, 에듀브리지',
                    style: textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                      height: 1.16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '공공데이터를 기반으로 우리 지역의 교육 환경을 분석하고 맞춤형 학습 기회를 찾아보세요.',
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const DecorativePoster(
                    title: '공공데이터를 해석하는\n프리미엄 교육 리포트',
                    subtitle:
                        '복잡한 수치를 카드 중심의 흐름으로 정리해, 지역별 교육 여건을 빠르게 이해할 수 있게 돕습니다.',
                    height: 260,
                  ),
                  const SizedBox(height: 40),
                  const TonalCard(
                    child: _IntroFeatureCard(
                      icon: Icons.analytics_rounded,
                      title: '우리 지역 분석',
                      description: '학교, 학원, 학생 수 데이터를 한눈에 읽는 공공 데이터 브리프',
                      accent: AppColors.primary,
                      darkIcon: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: TonalCard(
                          background: AppColors.primary,
                          child: _IntroFeatureCard(
                            icon: Icons.compare_arrows_rounded,
                            title: '교육 환경 비교',
                            description: '다른 지역과의 차이를 맥락 있게 비교',
                            accent: Colors.white,
                            darkText: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: TonalCard(
                          background: AppColors.surfaceHighest,
                          child: _IntroFeatureCard(
                            icon: Icons.auto_awesome_rounded,
                            title: '맞춤형 추천',
                            description: '부족한 부분을 메우는 학습 자원 큐레이션',
                            accent: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      '지역 선택하고 시작하기',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '로그인 없이 바로 사용 | 공공데이터 기반 분석 제공',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AbsorbPointer(
        child: const GlassBottomNav(currentIndex: 0, onTap: _noop),
      ),
    );
  }
}

void _noop(int _) {}

class _IntroFeatureCard extends StatelessWidget {
  const _IntroFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    this.darkIcon = false,
    this.darkText = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final bool darkIcon;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleColor = darkText ? Colors.white : AppColors.primary;
    final bodyColor = darkText
        ? Colors.white.withValues(alpha: 0.76)
        : AppColors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: darkIcon
                ? Colors.white.withValues(alpha: 0.14)
                : AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 24),
        ),
        const SizedBox(height: 18),
        Text(title, style: textTheme.titleMedium?.copyWith(color: titleColor)),
        const SizedBox(height: 6),
        Text(
          description,
          style: textTheme.bodyMedium?.copyWith(color: bodyColor),
        ),
      ],
    );
  }
}
