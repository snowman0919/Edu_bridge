import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label})>[
      (icon: Icons.home_rounded, label: '홈'),
      (icon: Icons.analytics_rounded, label: '분석'),
      (icon: Icons.compare_arrows_rounded, label: '비교'),
      (icon: Icons.auto_awesome_rounded, label: '추천'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                  blurRadius: 32,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: List.generate(items.length, (index) {
                    final selected = currentIndex == index;
                    final item = items[index];
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => onTap(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 22,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.outline,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
