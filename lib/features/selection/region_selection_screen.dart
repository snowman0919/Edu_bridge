import 'package:flutter/material.dart';

import '../../core/services/browser_bridge.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/region_metrics.dart';
import '../../data/repositories/education_repository.dart';
import '../../shared/widgets/brand_app_bar.dart';
import '../../shared/widgets/surface_widgets.dart';

class RegionSelectionScreen extends StatefulWidget {
  const RegionSelectionScreen({
    super.key,
    required this.repository,
    required this.initialRegionName,
  });

  final EducationRepository repository;
  final String initialRegionName;

  @override
  State<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends State<RegionSelectionScreen> {
  final BrowserBridge _browserBridge = createBrowserBridge();
  late String _selectedProvince;
  late String _selectedDistrict;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.repository.regionByName(widget.initialRegionName);
    _selectedProvince = initial.province;
    _selectedDistrict = initial.regionName;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = widget.repository.regionByName(_selectedDistrict);
    final districts = widget.repository.districtsForProvince(_selectedProvince);

    return Scaffold(
      body: Column(
        children: [
          BrandAppBar(
            trailing: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.outline,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('지역 선택', style: textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text('분석할 지역을 선택해 주세요.', style: textTheme.bodyLarge),
                  const SizedBox(height: 28),
                  Text(
                    'Step 1: 시/도 선택',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SelectionField(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedProvince,
                        icon: const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.primary,
                        ),
                        items: widget.repository.provinces
                            .map(
                              (province) => DropdownMenuItem<String>(
                                value: province,
                                child: Text(
                                  province,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          final items = widget.repository.districtsForProvince(
                            value,
                          );
                          setState(() {
                            _selectedProvince = value;
                            _selectedDistrict = items.first.regionName;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Step 2: 시/군/구 선택',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SelectionField(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedDistrict,
                        icon: const Icon(
                          Icons.expand_more_rounded,
                          color: AppColors.primary,
                        ),
                        items: districts
                            .map(
                              (region) => DropdownMenuItem<String>(
                                value: region.regionName,
                                child: Text(
                                  region.district,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedDistrict = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const TonalCard(padding: EdgeInsets.zero, child: _MapPanel()),
                  const SizedBox(height: 22),
                  TonalCard(
                    background: AppColors.surfaceLowest,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('선택된 지역', style: textTheme.labelMedium),
                              const SizedBox(height: 2),
                              Text(
                                selected.regionName,
                                style: textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showDistrictQuickPicker(districts),
                          icon: const Icon(
                            Icons.edit_rounded,
                            color: AppColors.primary,
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
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _locating
                            ? null
                            : () => Navigator.of(
                                context,
                              ).pop(selected.regionName),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(62),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _locating ? '현재 위치 반영 중...' : '이 지역 분석하기',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.analytics_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: _locating ? null : _useCurrentLocation,
                        icon: _locating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.my_location_rounded,
                                color: AppColors.primary,
                              ),
                        label: Text(
                          _locating ? '현재 위치 확인 중...' : '현재 위치 사용하기',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final result = await _browserBridge.detectCurrentRegion(
      widget.repository.regions.map((item) => item.regionName),
    );
    if (!mounted) {
      return;
    }

    setState(() => _locating = false);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    if (result.regionName != null) {
      final region = widget.repository.regionByName(result.regionName!);
      setState(() {
        _selectedProvince = region.province;
        _selectedDistrict = region.regionName;
      });
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('현재 위치를 기준으로 ${result.message}을(를) 선택했습니다.'),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(behavior: SnackBarBehavior.fixed, content: Text(result.message)),
    );
  }

  Future<void> _showDistrictQuickPicker(List<RegionMetrics> districts) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('시/군/구 빠르게 선택', style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  '$_selectedProvince 안에서 바로 바꿀 수 있습니다.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ...districts.map(
                  (region) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(region.district),
                    subtitle: Text(region.regionName),
                    trailing: region.regionName == _selectedDistrict
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(region.regionName),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedDistrict = selected);
    }
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _MapPanel extends StatelessWidget {
  const _MapPanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0F1F3), Color(0xFFD9DADD)],
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 24,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 8,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
