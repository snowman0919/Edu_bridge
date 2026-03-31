import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({super.key, this.trailing});

  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context) {
    final trailingWidgets = trailing == null
        ? const <Widget>[]
        : <Widget>[trailing!];
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
        ).createShader(const Rect.fromLTWH(0, 0, 140, 40)),
    );

    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('EduBridge', style: textStyle),
                          ],
                        ),
                      ),
                      ...trailingWidgets,
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
